# resource "azurerm_role_assignment" "rbac_keyvault_administrator" {
#   for_each = toset(var.rbac_authorization_enabled && !var.managed_hardware_security_module_enabled ? var.admin_objects_ids : [])

#   scope                = one(azurerm_key_vault.keyvault[*].id)
#   role_definition_name = "Key Vault Administrator"
#   principal_id         = each.value
# }

# resource "azurerm_role_assignment" "rbac_keyvault_secrets_users" {
#   for_each = toset(var.rbac_authorization_enabled && !var.managed_hardware_security_module_enabled ? var.secrets_objects_ids : [])

#   scope                = one(azurerm_key_vault.keyvault[*].id)
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = each.value
# }

# resource "azurerm_role_assignment" "rbac_keyvault_cert_users" {
#   for_each = toset(var.rbac_authorization_enabled && !var.managed_hardware_security_module_enabled ? var.certs_objects_ids : [])

#   scope                = one(azurerm_key_vault.keyvault[*].id)
#   role_definition_name = "Key Vault Certificates Officer"
#   principal_id         = each.value
# }

# resource "azurerm_role_assignment" "rbac_keyvault_reader" {
#   for_each = toset(var.rbac_authorization_enabled && !var.managed_hardware_security_module_enabled ? var.reader_objects_ids : [])

#   scope                = one(azurerm_key_vault.keyvault[*].id)
#   role_definition_name = "Key Vault Reader"
#   principal_id         = each.value
# }


################################
# Create Role Assignments
################################
locals {
  principal_roles_list = flatten([ # Produce a list object, containing mapping of role names to principal IDs.
    for role, principals in var.role_assignments : [
      for principal in principals : {
        role      = role
        principal = principal
      }
    ]
  ])

  principal_roles_tuple = {
    for obj in local.principal_roles_list : "${obj.role}_${obj.principal}" => obj
  }

  principal_roles_map = tomap(local.principal_roles_tuple)

}

resource "azurerm_role_assignment" "role_assignments" {
  for_each             = local.principal_roles_map
  scope                = one(azurerm_key_vault.keyvault[*].id)
  role_definition_name = each.value.role
  principal_id         = each.value.principal
}