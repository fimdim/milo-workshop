# Workshop Container Apps Demo

This repository contains a simple .NET 10 Blazor Web App, Terraform for the Azure resources, and GitHub Actions workflows for CI/CD.

## Layout

- `src/WorkshopWebApp` - the web app
- `infra` - Terraform for ACR, Log Analytics, Container Apps environment, and Container App in an existing resource group
- `.github/workflows` - pull request validation and manual deployment

## Local run

```powershell
dotnet restore WorkshopApp.slnx
dotnet run --project src/WorkshopWebApp/WorkshopWebApp.csproj
```

Open the app locally and use `/healthz` to verify the container-ready endpoint.

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

Terraform state is stored in Azure Blob Storage through the `azurerm` backend. The repository's `infra-init` workflow can create the backend resource group, storage account, and `tfstate` container for you.

## GitHub Actions

The `ci` workflow runs on pull requests and checks the .NET build plus Terraform formatting and validation.

The `cd` workflow is triggered manually after merge. It builds and pushes the container image to Azure Container Registry and then updates the Azure Container App to the selected image tag.

## Azure inputs

Set these repository variables before using the deployment workflow:

- `SANDBOX_CLIENT_ID`
- `SANDBOX_TENANT_ID`
- `RESOURCE_GROUP` to target a specific resource group, or omit it to use the workflow fallback
- `TF_STORAGE_ACCOUNT` for the Terraform state storage account name

Set this secret for Azure login:

- `SANDBOX_CLIENT_SECRET`

The bootstrap, CI, and deployment workflows all resolve repository variables the same way as the infra bootstrap flow. They use `RESOURCE_GROUP` and `TF_STORAGE_ACCOUNT` when set, otherwise they fall back to `rg-workshop-<github-user>` and a deterministic `strgworkshop<hash>` storage account name.