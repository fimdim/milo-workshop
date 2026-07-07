variable "location" {
  description = "Azure region for all workshop resources."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name" {
  description = "Resource group name for the workshop."
  type        = string
  default     = "rg-workshop-milow"
}

variable "acr_name" {
  description = "Globally unique Azure Container Registry name."
  type        = string
  default     = "acrmiloworkshop"
}

variable "container_app_environment_name" {
  description = "Container Apps environment name."
  type        = string
  default     = "aca-env-workshop-milow"
}

variable "container_app_name" {
  description = "Container App name."
  type        = string
  default     = "aca-workshop-milow"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
  default     = "law-workshop-milow"
}

variable "image_name" {
  description = "Container image name inside ACR."
  type        = string
  default     = "milow-workshop-webapp"
}

variable "image_tag" {
  description = "Image tag used by the deployment workflow."
  type        = string
  default     = "latest"
}