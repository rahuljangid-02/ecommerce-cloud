# Cloud-Deployed E-Commerce Web Application

A cloud-hosted e-commerce storefront built using HTML, CSS, JavaScript, Node.js, Express.js, and PostgreSQL. The application is deployed on Render with separate frontend and backend services.

**Live Website:** https://ecommerce-frontend-2582.onrender.com

**Backend API:** https://ecommerce-backend-0nyo.onrender.com/api/health

**GitHub Repository:** https://github.com/rahuljangid-02/ecommerce-cloud

## Project Overview

This project demonstrates full-stack web development, REST API integration, relational database connectivity, and cloud deployment.

Customers can browse products, add items to their shopping cart, modify quantities, remove items, and view dynamically calculated totals.

## Cloud Architecture

**Customer Browser → Render Static Site → Render Node.js Web Service → PostgreSQL Database**

- **Frontend:** Render Static Site hosting HTML, CSS, and JavaScript.
- **Backend:** Node.js and Express.js REST API deployed using Render Web Service.
- **Database:** PostgreSQL stores product information.
- **Communication:** HTTPS requests connect the frontend and backend.
- **Shopping Cart:** Browser localStorage retains shopping cart data across page refreshes.
- **Version Control:** Git and GitHub manage source code and deployment updates.

The repository also includes Terraform configurations for a separate Azure-based infrastructure architecture. The current live application is hosted on Render.

## Technology Stack

| Component | Technology |
|---|---|
| Frontend | HTML5, CSS3, JavaScript |
| Backend | Node.js, Express.js |
| Database | PostgreSQL |
| Cloud Hosting | Render |
| Version Control | Git, GitHub |
| Infrastructure as Code | Terraform (Azure configuration) |
| API Architecture | REST API |

## Features

- Product listing retrieved from PostgreSQL through REST APIs.
- Backend health-status monitoring.
- Add to Cart functionality.
- Increase and decrease product quantities.
- Remove individual products from the cart.
- Automatic shopping cart total calculation.
- Shopping cart persistence using localStorage.
- Responsive storefront layout.
- Cloud-based frontend and backend deployment.

## Project Structure

- `frontend/` — HTML, CSS, JavaScript, and shopping cart functionality.
- `backend/` — Express server and PostgreSQL integration.
- `infra/` — Terraform infrastructure configuration for Azure.
- `.github/workflows/` — GitHub Actions workflow configurations.
- `scripts/` — Deployment helper scripts.
- `README.md` — Project documentation.

## REST API Endpoints

| Endpoint | Purpose |
|---|---|
| `GET /api/health` | Check backend health |
| `GET /api/db-check` | Check database connectivity |
| `GET /api/products` | Retrieve all products |
| `GET /api/products/:id` | Retrieve a specific product |

## Render Deployment

**Backend Web Service**

- Root Directory: `backend`
- Build Command: `npm install`
- Start Command: `npm start`
- Runtime: Node.js

Database connection information is configured through Render environment variables: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD`.

**Frontend Static Site**

- Root Directory: `frontend`
- Build Command: `echo "No build needed"`
- Publish Directory: `.`

The frontend communicates with the deployed backend using its public HTTPS API URL.

## Screenshots

Screenshots of the deployed storefront, shopping cart, and cloud infrastructure will be added to demonstrate the working application.

## Current Limitations

- The shopping cart is stored in browser localStorage, not in PostgreSQL.
- Checkout, order processing, and online payment integration are not implemented.
- The application is intended for learning, cloud deployment demonstrations, and portfolio presentation.

## Future Enhancements

- User registration and authentication.
- Database-backed shopping carts and orders.
- Secure checkout and payment gateway integration.
- Product search and category filtering.
- Administrative dashboard.
- Automated testing and expanded CI/CD workflows.

## Learning Outcomes

This project provided practical experience with cloud application deployment, API integration, PostgreSQL connectivity, Git-based version control, environment variable configuration, CORS, and full-stack debugging.