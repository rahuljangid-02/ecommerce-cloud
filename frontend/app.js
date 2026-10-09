// In production CloudFront serves this page AND forwards /api/* to the backend,
// so relative URLs just work. For local testing against another host, set
// window.API_BASE = 'http://localhost:8080' in the browser console first.
const API_BASE = window.API_BASE || '';

const statusEl = document.getElementById('status');
const productsEl = document.getElementById('products');
const servedByEl = document.getElementById('served-by');

function setStatus(text, kind) {
  statusEl.textContent = text;
  statusEl.className = 'status ' + kind;
}

function renderProducts(products) {
  productsEl.replaceChildren();

  if (!products.length) {
    const empty = document.createElement('p');
    empty.className = 'muted';
    empty.textContent = 'No products yet.';
    productsEl.append(empty);
    return;
  }

  for (const p of products) {
    const card = document.createElement('article');
    card.className = 'card';

    const title = document.createElement('h2');
    title.textContent = p.name;

    const desc = document.createElement('p');
    desc.textContent = p.description || '';

    const price = document.createElement('span');
    price.className = 'price';
    price.textContent = '$' + Number(p.price).toFixed(2);

    const button = document.createElement('button');
    button.type = 'button';
    button.textContent = 'Add to cart'; // TODO: wire this to your cart API

    card.append(title, desc, price, button);
    productsEl.append(card);
  }
}

async function checkHealth() {
  try {
    const res = await fetch(API_BASE + '/api/health');
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const data = await res.json();
    setStatus('API online', 'ok');
    // Refresh the page a few times: with more than one instance this changes.
    servedByEl.textContent = 'Served by ' + (data.host || res.headers.get('X-Served-By') || 'unknown');
  } catch (err) {
    setStatus('API unreachable', 'err');
  }
}

async function loadProducts() {
  try {
    const res = await fetch(API_BASE + '/api/products');
    if (!res.ok) throw new Error('HTTP ' + res.status);
    renderProducts(await res.json());
  } catch (err) {
    productsEl.replaceChildren();
    const msg = document.createElement('p');
    msg.className = 'muted';
    msg.textContent = 'Could not load products (' + err.message + ').';
    productsEl.append(msg);
  }
}

checkHealth();
loadProducts();
