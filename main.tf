#-------------------------------
# Local Declarations
#-------------------------------
locals {
  resource_group_name      = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  resource_group_id      = element(coalescelist(data.azurerm_resource_group.rgrp.*.id, azurerm_resource_group.rg.*.id, [""]), 0)
  location                 = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
}
#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------

data "azurerm_resource_group" "rgrp" {
    count = var.create_resource_group == false ? 1 : 0
    name = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge(
  var.common_tags, { 
  Name = format("%s", var.resource_group_name) 
  }
  )
}

#---------------------------------------------------------
# Key Vault Creation
#----------------------------------------------------------
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                = var.kv_name
  location            = local.location
  resource_group_name = local.resource_group_name

  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "premium"
  soft_delete_retention_days      = 30
  purge_protection_enabled        = "true"
  enabled_for_disk_encryption     = "true"
  enable_rbac_authorization       = var.rbac_authorization_enabled
  enabled_for_deployment          = "true"
  enabled_for_template_deployment = "true"

  dynamic "network_acls" {
    for_each = var.network_acls == null ? [] : [var.network_acls]
    iterator = acl

    content {
      bypass                     = acl.value.bypass
      default_action             = acl.value.default_action
      ip_rules                   = acl.value.ip_rules
      virtual_network_subnet_ids = acl.value.virtual_network_subnet_ids
    }
  }

  tags = merge(
    var.common_tags, {
      Name                = var.kv_name
    }
  )
}

#---------------------------------------------------------
# RBAC for ado service principal
#----------------------------------------------------------

resource "azurerm_role_assignment" "ado_users_identity_role_assignment_kva" {
  scope                = one(azurerm_key_vault.keyvault[*].id)
  role_definition_name = "Key Vault Administrator"
  principal_id         =  data.azurerm_client_config.current.object_id
}

#---------------------------------------------------------
# Create a new Private Endpoint for Keyvault
#----------------------------------------------------------

resource "azurerm_private_endpoint" "privateendpoint" {
  name                = "${var.environment}-${var.solution}-pep-${var.location_short_ae}-1"
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name = "${var.environment}-${var.solution}-pepdns-${var.location_short_ae}-1"
    private_dns_zone_ids = [var.kv_private_dns_zone_id]
  }

  private_service_connection {
    name = "${var.environment}-${var.solution}-pep-${var.location_short_ae}-1"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names = ["vault"]
    is_manual_connection = false
  }
tags     = merge(
var.common_tags, { 
Name = format("%s", "${var.environment}-${var.solution}-pep-${var.location_short_ae}-1")
} 
)
}
