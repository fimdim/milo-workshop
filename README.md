# Workshop Container Apps Demo

This repository contains a simple .NET 10 Blazor Web App, Terraform for the Azure resources, and GitHub Actions workflows for CI/CD.

## Layout

- `src/WorkshopWebApp` - the web app
- `infra` - Terraform for the resource group, ACR, Log Analytics, Container Apps environment, and Container App
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
terraform init
terraform fmt -recursive
terraform validate
terraform apply
```

## GitHub Actions

The `ci` workflow runs on pull requests and checks the .NET build plus Terraform formatting and validation.

The `cd` workflow is triggered manually after merge. It builds and pushes the container image to Azure Container Registry and then updates the Azure Container App to the selected image tag.

## Azure inputs

Set these repository variables before using the deployment workflow:

- `ACR_NAME`
- `ACR_LOGIN_SERVER`
- `CONTAINER_APP_NAME`
- `RESOURCE_GROUP`

Set this secret for Azure login:

- `AZURE_CREDENTIALS`