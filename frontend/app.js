// In production CloudFront serves this page AND forwards /api/* to the backend,
// so relative URLs just work. For local testing against another host, set
// window.API_BASE = 'http://localhost:8080' in the browser console first.
const API_BASE = "https://ecommerce-backend-0nyo.onrender.com";

const productImages = {
    "Wireless Headphones": "headphones.jpg",
    "Mechanical Keyboard": "keyboard.jpg",
    "Travel Backpack": "backpack.jpg",
    "Desk Lamp": "lamp.jpg",
    "Wireless Mouse": "mouse.jpg",
    "Smartwatch": "smartwatch.jpg",
    "Bluetooth Speaker": "speaker.jpg",
    "Laptop Stand": "laptop-stand.jpg"
};

function addToCart(product) {
    let cart = JSON.parse(
        localStorage.getItem("cart") || "[]"
    );

    let existingProduct = cart.find(
        item => item.id === product.id
    );

    if (existingProduct) {
        existingProduct.quantity += 1;
    } else {
        cart.push({
            id: product.id,
            name: product.name,
            price: Number(product.price),
            quantity: 1
        });
    }

    localStorage.setItem("cart", JSON.stringify(cart));
    renderCart();
    alert(product.name + " added to cart!");
}

function renderCart() {
    const cart = JSON.parse(
        localStorage.getItem("cart") || "[]"
    );

    const cartItems = document.getElementById("cart-items");
    const cartCount = document.getElementById("cart-count");
    const cartTotal = document.getElementById("cart-total");

    cartItems.replaceChildren();

    let total = 0;
    let count = 0;

    if (cart.length === 0) {
        const empty = document.createElement("p");
        empty.textContent = "Your cart is empty.";
        cartItems.appendChild(empty);
    }

    cart.forEach(item => {
        const quantity = Number(item.quantity);
        const price = Number(item.price);

        total += price * quantity;
        count += quantity;

        const row = document.createElement("div");
        row.className = "cart-item";

        const details = document.createElement("div");
        const name = document.createElement("strong");
        name.textContent = item.name;

        const subtotal = document.createElement("p");
        subtotal.textContent =
            "$" + price.toFixed(2) +
            " x " + quantity +
            " = $" + (price * quantity).toFixed(2);

        details.append(name, subtotal);

        const controls = document.createElement("div");
        controls.className = "cart-controls";

        const minus = document.createElement("button");
        minus.textContent = "-";
        minus.onclick = () => updateQuantity(item.id, -1);

        const qty = document.createElement("span");
        qty.textContent = quantity;

        const plus = document.createElement("button");
        plus.textContent = "+";
        plus.onclick = () => updateQuantity(item.id, 1);

        const remove = document.createElement("button");
        remove.textContent = "Remove";
        remove.onclick = () => removeItem(item.id);

        controls.append(minus, qty, plus, remove);
        row.append(details, controls);
        cartItems.appendChild(row);
    });

    cartCount.textContent = count;
    cartTotal.textContent = "$" + total.toFixed(2);
}

// Increase or decrease quantity
function updateQuantity(id, change) {
    let cart = JSON.parse(
        localStorage.getItem("cart") || "[]"
    );

    const item = cart.find(p => p.id === id);

    if (!item) return;

    item.quantity += change;

    cart = cart.filter(p => p.quantity > 0);

    localStorage.setItem("cart", JSON.stringify(cart));

    renderCart();
}

// Remove a product
function removeItem(id) {
    let cart = JSON.parse(
        localStorage.getItem("cart") || "[]"
    );

    cart = cart.filter(p => p.id !== id);

    localStorage.setItem("cart", JSON.stringify(cart));

    renderCart();
}

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
    
    const imageFile = productImages[p.name];

    if (imageFile) {
        const image = document.createElement('img');

        image.src = 'images/' + imageFile;
        image.alt = p.name;
        image.className = 'product-image';
        image.loading = 'lazy';

        card.append(image);
    }

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

    button.addEventListener('click', () => {addToCart(p);});
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
renderCart();