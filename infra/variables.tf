variable "resource_group_name" {
  description = "Resource group name for the workshop."
  type        = string
  default     = "rg-workshop-milo"
}

variable "acr_name" {
  description = "Globally unique Azure Container Registry name."
  type        = string
  default     = "acrmiloworkshop"
}

variable "container_app_environment_name" {
  description = "Container Apps environment name."
  type        = string
  default     = "aca-env-milo-workshop"
}

variable "container_app_name" {
  description = "Container App name."
  type        = string
  default     = "aca-workshop-milo"
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
  default     = "law-milo-workshop"
}

variable "image_name" {
  description = "Container image name inside ACR."
  type        = string
  default     = "milo-workshop-app"
}

variable "image_tag" {
  description = "Image tag used by the deployment workflow."
  type        = string
  default     = "latest"
}