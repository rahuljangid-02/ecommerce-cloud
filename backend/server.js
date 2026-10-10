'use strict';

const os = require('os');
const express = require('express');
const { Pool } = require('pg');
const { DefaultAzureCredential } = require('@azure/identity');
const { SecretClient } = require('@azure/keyvault-secrets');

const PORT = Number(process.env.PORT || 8080);
const app = express();
app.use(express.json());

app.use((req, res, next) => {
  res.setHeader(
    "Access-Control-Allow-Origin",
    "https://ecommerce-frontend-2582.onrender.com"
  );

  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, PATCH, DELETE, OPTIONS"
  );

  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization"
  );

  if (req.method === "OPTIONS") {
    return res.sendStatus(204);
  }

  next();
});
// Tell the caller which instance answered (useful for watching the load balancer).
app.use((req, res, next) => {
  res.set('X-Served-By', os.hostname());
  next();
});

// ------------------------------------------------------------------ Database
// The app uses Azure Key Vault to resolve the database password at runtime.
// The database connection itself stays the same; only the secret acquisition changes.

let pool = null;

async function getDatabasePassword() {
  if (process.env.DB_PASSWORD) return process.env.DB_PASSWORD;

  const { AZURE_KEY_VAULT_URL, DB_PASSWORD_SECRET_NAME } = process.env;
  if (!AZURE_KEY_VAULT_URL || !DB_PASSWORD_SECRET_NAME) {
    return null;
  }

  const credential = new DefaultAzureCredential();
  const client = new SecretClient(AZURE_KEY_VAULT_URL, credential);
  const secret = await client.getSecret(DB_PASSWORD_SECRET_NAME);
  return secret.value || null;
}

async function getPool() {
  if (pool) return pool;

  const { DB_HOST, DB_PORT, DB_NAME, DB_USER } = process.env;
  if (!DB_HOST || !DB_NAME || !DB_USER) return null; // not configured (e.g. running locally)

  const password = await getDatabasePassword();
  if (!password) return null;

  const p = new Pool({
    host: DB_HOST,
    port: Number(DB_PORT || 5432),
    database: DB_NAME,
    user: DB_USER,
    password,
    // RDS requires TLS. For production, download the RDS CA bundle and set
    // rejectUnauthorized: true with ca: <bundle>.
    ssl: { rejectUnauthorized: false },
    max: 10,
  });

  await p.query(`
    CREATE TABLE IF NOT EXISTS products (
      id          SERIAL PRIMARY KEY,
      name        TEXT           NOT NULL,
      description TEXT           NOT NULL DEFAULT '',
      price       NUMERIC(10, 2) NOT NULL
    )
  `);

  const { rows } = await p.query('SELECT COUNT(*)::int AS n FROM products');
  if (rows[0].n === 0) {
    await p.query(`
      INSERT INTO products (name, description, price) VALUES
        ('Wireless Headphones', 'Noise-cancelling, 30-hour battery.', 79.99),
        ('Mechanical Keyboard', 'Hot-swappable switches, USB-C.', 109.00),
        ('Travel Backpack', '25L, water-resistant, laptop sleeve.', 54.50),
        ('Desk Lamp', 'Dimmable LED with warm and cool modes.', 32.25),
        
    `);
  }

  // Add new products only if they don't already exist
  await p.query(`
    INSERT INTO products (name, description, price)

    SELECT v.name, v.description, v.price
    FROM (VALUES
      ('Wireless Mouse',
       'Ergonomic wireless mouse with adjustable DPI.',
       24.99),

      ('Smartwatch',
       'Fitness tracking smartwatch with heart rate monitor.',
       149.00),

      ('Bluetooth Speaker',
       'Portable Bluetooth speaker with deep bass.',
       59.99),

      ('Laptop Stand',
       'Adjustable aluminum laptop stand for desks.',
       39.99)

    ) AS v(name, description, price)

    WHERE NOT EXISTS (
      SELECT 1
      FROM products existing
      WHERE existing.name = v.name
    )
  `);

  pool = p;
  return pool;
}

// -------------------------------------------------------------------- Routes

// The load balancer polls this. Keep it independent of the database so a DB
// hiccup does not make every instance look dead and trigger replacements.
app.get(['/health', '/api/health'], (req, res) => {
  res.json({ status: 'ok', host: os.hostname() });
});

// Confirms the app can reach RDS.
app.get('/api/db-check', async (req, res) => {
  try {
    const db = await getPool();
    if (!db) return res.status(503).json({ db: 'not configured' });
    await db.query('SELECT 1');
    res.json({ db: 'ok' });
  } catch (err) {
    console.error(err);
    res.status(503).json({ db: 'unreachable' });
  }
});

app.get('/api/products', async (req, res) => {
  try {
    const db = await getPool();
    if (!db) return res.status(503).json({ error: 'database not configured' });
    const { rows } = await db.query('SELECT id, name, description, price::float AS price FROM products ORDER BY id');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'internal error' });
  }
});

app.get('/api/products/:id', async (req, res) => {
  const id = Number.parseInt(req.params.id, 10);
  if (!Number.isInteger(id)) return res.status(400).json({ error: 'invalid id' });

  try {
    const db = await getPool();
    if (!db) return res.status(503).json({ error: 'database not configured' });
    const { rows } = await db.query(
      'SELECT id, name, description, price::float AS price FROM products WHERE id = $1',
      [id]
    );
    if (!rows.length) return res.status(404).json({ error: 'not found' });
    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'internal error' });
  }
});

app.use((req, res) => res.status(404).json({ error: 'not found' }));

app.listen(PORT, '0.0.0.0', () => console.log('backend listening on ' + PORT));
