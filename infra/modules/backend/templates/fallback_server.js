'use strict';
// Placeholder API baked into the instance by Terraform. It exposes the same
// routes as backend/server.js, so the frontend works before your real backend
// is deployed. Uses only Node's standard library (no npm install needed).

const http = require('http');
const os = require('os');

const PORT = process.env.PORT || 8080;

const products = [
  { id: 1, name: 'Wireless Headphones', price: 79.99, description: 'Noise-cancelling, 30-hour battery.' },
  { id: 2, name: 'Mechanical Keyboard', price: 109.0, description: 'Hot-swappable switches, USB-C.' },
  { id: 3, name: 'Travel Backpack', price: 54.5, description: '25L, water-resistant, laptop sleeve.' },
  { id: 4, name: 'Desk Lamp', price: 32.25, description: 'Dimmable LED with warm and cool modes.' },
];

function send(res, status, body) {
  res.writeHead(status, {
    'Content-Type': 'application/json',
    // Shows which instance answered, handy for watching the load balancer work.
    'X-Served-By': os.hostname(),
  });
  res.end(JSON.stringify(body));
}

http
  .createServer((req, res) => {
    const path = req.url.split('?')[0];

    if (path === '/health' || path === '/api/health') {
      return send(res, 200, { status: 'ok', mode: 'placeholder', host: os.hostname() });
    }
    if (path === '/api/products') {
      return send(res, 200, products);
    }
    return send(res, 404, { error: 'not found' });
  })
  .listen(PORT, '0.0.0.0', () => console.log('placeholder API listening on ' + PORT));
