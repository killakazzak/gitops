terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc03"
    }
  }
}

provider "proxmox" {
  pm_api_url                  = var.proxmox_api_url
  pm_api_token_id             = var.proxmox_api_token_id
  pm_api_token_secret         = var.proxmox_api_token_secret
  pm_tls_insecure             = true
  pm_minimum_permission_check = false # отключем проверку прав
}

variable "proxmox_api_url" {
  type        = string
  description = "URL API Proxmox, например https://proxmox.tenda.local:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "API token id в формате user@realm!tokenid, например root@pam!terraform"
}

variable "proxmox_api_token_secret" {
  type        = string
  description = "Секретный ключ API токена"
  sensitive   = true
}
