# E-commerce on Azure

A production-style, three-tier deployment defined entirely in Terraform. The infrastructure is the point of this repo; the app code is a thin starter you replace with your own e-commerce platform.

```
                      ┌──────────── Azure Blob stroage + CDN (HTTPS) ───────────────┐
   Browser ──────────►│  /*       ──► Azure Storage static website   │
                      │  /api/*   ──► Azure App Service backend 
                                    Virtual Machines with auto scaling enabled
                      └─────────────────────────┬────────────────────┘
                                                ▼
                                      Azure PostgreSQL Flexible Server
                                      Azure Database service
                                                ▼
                                      Networking(Virtual network setup)
                                                ▼
                                     Azure Key Vault (DB password)
```

| Piece | What it is | Where |
|---|---|---|
| Frontend | Azure Storage static website + Azure CDN | `infra/modules/frontend`, code in `frontend/` |
| Backend | Azure App Service + managed identity | `infra/modules/backend`, code in `backend/` |
| Database | Azure PostgreSQL Flexible Server | `infra/modules/database` |
| Secrets | Azure Key Vault secret for database password | `infra/modules/database` |
| Infra as code | Terraform root config wiring the modules | `infra/` |
| Networking | Azure VNet + application subnet + database subnet | `infra/modules/networking` |

## Project layout

```
infra/
  main.tf  variables.tf  outputs.tf  versions.tf
  terraform.tfvars.example     copy to terraform.tfvars
  backend.tf.example           remote state (Azure Storage), when you want it
  modules/
    networking/   database/   backend/   frontend/
frontend/         static storefront (HTML/CSS/JS)
backend/          Express API (Node 18+), talks to PostgreSQL
scripts/deploy-frontend.sh
```

## Quick start

Prerequisites: an Azure subscription, the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed and logged in (`az login`), and [Terraform](https://developer.hashicorp.com/terraform/install) 1.6+.

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars   # edit if you like
terraform init
terraform plan
terraform apply

cd ..
./scripts/deploy-frontend.sh        # uploads frontend/ to the Storage account
terraform -chdir=infra output frontend_url
```

Open the `frontend_url`. The page shows "API online" and a product list. Until you point the stack at your own repo, the products come from a built-in placeholder API on the App Service.

## Running your own backend

1. Push this repo to GitHub (public repo, or adapt the app deployment flow for private repos).
2. In `terraform.tfvars`, set the Azure app settings or repo source you want to deploy.
3. `terraform apply`.

The backend app reads the database password from Azure Key Vault using managed identity, creates a `products` table, and seeds sample rows. Check `https://<frontend_url>/api/db-check`.

App logs can be viewed in Azure App Service > Log stream. If you want to inspect the runtime app environment, use the Azure Portal or `az webapp log tail`.

## Cost: read before you apply

- Azure App Service, PostgreSQL Flexible Server, and Azure CDN all bill while running.
- Key Vault and storage also carry small charges depending on usage.
- **When you stop working: `cd infra && terraform destroy`.**

## What's already production-minded

- Azure VNet with separate app and database subnets.
- Managed identity gives the app access to Key Vault without embedding credentials.
- PostgreSQL password is generated and stored in Azure Key Vault.
- Azure Storage static website hosting is fronted by Azure CDN.
- App Service health checks keep the app healthy while serving traffic.

## Next steps as you learn

| Topic | What to try |
|---|---|
| HTTPS end to end | Add a custom domain in Azure Front Door or CDN and bind a TLS certificate. |
| Key Vault hardening | Restrict access to the app identity and rotate secrets regularly. |
| Remote state | Rename `backend.tf.example` to `backend.tf` and configure an Azure Storage backend. |
| Deploys from GitHub | Add a GitHub Actions workflow that runs Terraform and deploys the frontend artifacts. |
| Observability | Enable Azure Monitor, App Service logs, and PostgreSQL metrics. |
| Production database | Increase the PostgreSQL SKU and retention settings for multi-zone safety and backups. |
| SPA routing | If your frontend uses client-side routes, configure CDN rules so non-API paths resolve to `index.html`. |
