variable "create_resource_group" {
  description = "Whether to create resource group and use it for all resources"
  default     = false
  type        = bool
}

variable resource_group_name {
  type        = string
  default     = ""
  description = "Name of the Resource Group"
}

variable "location" {
  description = "The location/region to keep all your resources"
  default     = "australiaeast"
  type        = string
}

variable "location_short_ae" {
  description = "Short abbreviation of location"
  default     = "ae"
  type        = string
}

variable "environment" {
  description = "resources environment"
  default     = ""
  type        = string
}

variable "kv_name" {
  description = "Name of the keyvalut"
  default     = ""
  type        = string
}

variable "rbac_authorization_enabled" {
  type        = bool
  description = "Whether the Key Vault uses Role Based Access Control (RBAC) for authorization of data actions instead of access policies."
  default     = true
}

# variable "admin_objects_ids" {
#   description = "IDs of the objects that can do all operations on all keys, secrets and certificates."
#   type        = list(string)
#   default     = []
# }

# variable "reader_objects_ids" {
#   description = "IDs of the objects that can read all keys, secrets and certificates."
#   type        = list(string)
#   default     = []
# }

# variable "secrets_objects_ids" {
#   description = "IDs of the objects that can manage all secrets."
#   type        = list(string)
#   default     = []
# }

# variable "certs_objects_ids" {
#   description = "IDs of the objects that can manage all certificates."
#   type        = list(string)
#   default     = []
# }

variable "network_acls" {
  description = "Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. Set to `null` to disable. See https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#bypass for more information."
  type = object({
    bypass                     = optional(string, "None"),
    default_action             = optional(string, "Deny"),
    ip_rules                   = optional(list(string)),
    virtual_network_subnet_ids = optional(list(string)),
  })
  default = {}
}

variable "managed_hardware_security_module_enabled" {
  description = "Create a KeyVault Managed HSM resource if enabled. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable solution {
  type        = string
  default     = ""
  description = "Name of the service or application"
}

variable "common_tags" {
  description = "Common tags applied to all the resources created in this module"
  type        = map(string)
}

variable "role_assignments" {
  type        = any
  default     = {}
  description = <<EOF
    "Define a map of Roles (either Custom or Built-In) to Princpal IDs, scoped to the new Key Vault.
    EXAMPLE:
    role_assignments = {
        Secrets_User    = ["sfdsf", "fdsdvfsa"],
        Secrets_Officer = ["esrewfds", "wefsdsd"]
        Contributor     = ["879y9-ugbi", "iuhi39hy98hd"]
    }
EOF
}

variable private_endpoint_subnet_id {
  type        = string
  default     = ""
  description = "Private enpoint subnet ID"
}

variable kv_private_dns_zone_id {
  type        = string
  default     = "/subscriptions/ca095a5d-36c0-4d4f-82ff-83580d85ebba/resourceGroups/sha-infra-dns-rg-ae-1/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
  description = "Private enpoint subnet ID"
}