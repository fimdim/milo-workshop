# Workshop Container Apps Demo

A .NET 10 Blazor Server app deployed to **Azure Container Apps** using **Terraform** for infrastructure and **GitHub Actions** for CI/CD.

See [architecture.md](architecture.md) for a full system diagram and component breakdown.

## Prerequisites

- [.NET 10 SDK](https://dotnet.microsoft.com/download)
- [Docker](https://www.docker.com/products/docker-desktop) (for container builds)
- [Terraform ≥ 1.6](https://developer.hashicorp.com/terraform/install)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)

## Layout

```
.
├── src/WorkshopWebApp/        # .NET 10 Blazor Server web app
├── infra/                     # Terraform — ACR, Log Analytics, Container Apps env + app
├── .github/workflows/         # ci, cd, and infra-init GitHub Actions workflows
├── Dockerfile                 # Multi-stage build targeting port 8080
└── WorkshopApp.slnx           # Solution file
```

## Local run

```powershell
dotnet restore WorkshopApp.slnx
dotnet run --project src/WorkshopWebApp/WorkshopWebApp.csproj
```

Open the app locally. The `/healthz` endpoint is mapped via ASP.NET Core health checks and is available for external health checks.

## Run with Docker

Build the image from the repository root:

```powershell
docker build -t workshop-webapp:local .
```

Run the container on port 8080:

```powershell
docker run --rm -p 8080:8080 workshop-webapp:local
```

Then browse to `http://localhost:8080` and `http://localhost:8080/healthz`.

## First-time Azure setup

Run the `infra-init` workflow manually once. It creates:

- A resource group (`rg-workshop-<github-user>` by default)
- An Azure Storage Account and a `tfstate` blob container for Terraform remote state
- A `Storage Blob Data Contributor` role assignment for the deployment service principal on that storage account

After that, all subsequent `ci` and `cd` runs can initialise the Terraform backend automatically.

## Terraform

```powershell
cd infra
az login
terraform init `
  -backend-config="resource_group_name=<resource-group>" `
  -backend-config="storage_account_name=<tf-storage-account>" `
  -backend-config="container_name=tfstate" `
  -backend-config="key=terraform.tfstate"
terraform fmt -recursive
terraform validate
terraform apply
```

Terraform state is stored in Azure Blob Storage through the `azurerm` backend.

**Resources created by Terraform:**

| Resource | Default name |
|---|---|
| Log Analytics Workspace | `law-milo-workshop` |
| Azure Container Registry (Basic) | `acrmiloworkshop<suffix>` |
| Container Apps Environment | `aca-env-milo-workshop` |
| Container App | `aca-workshop-milo-<suffix>` |

## GitHub Actions

| Workflow | Trigger | Purpose |
|---|---|---|
| `infra-init` | Manual | Bootstraps the Terraform state backend (run once) |
| `ci` | Pull request to `main` + manual | Builds .NET solution, checks Terraform fmt/validate |
| `cd` | Manual (input: `image_tag`) | Applies Terraform, builds & pushes image to ACR via `az acr build`, updates Container App |

### Required repository variables

| Variable | Description |
|---|---|
| `SANDBOX_CLIENT_ID` | Service principal client ID |
| `SANDBOX_TENANT_ID` | Azure tenant ID |
| `SANDBOX_SUBSCRIPTION_ID` | Azure subscription ID (optional; sets active subscription) |
| `RESOURCE_GROUP` | Target resource group (falls back to `rg-workshop-<github-user>`) |
| `TF_STORAGE_ACCOUNT` | Terraform state storage account (falls back to `strgworkshop<hash>`) |

### Required secret

| Secret | Description |
|---|---|
| `SANDBOX_CLIENT_SECRET` | Service principal client secret |

> All three workflows resolve `RESOURCE_GROUP` and `TF_STORAGE_ACCOUNT` identically: use the repository variable when set, otherwise derive a deterministic name from the GitHub actor/repository.