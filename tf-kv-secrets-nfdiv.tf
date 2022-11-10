data "azurerm_key_vault" "nfdiv_vault" {
  name                = "nfdiv-${var.env}"
  resource_group_name = "nfdiv-shared-${var.env}"
}

locals {
  idam_secrets = [
    "idam-secret",
    "idam-solicitor-username",
    "idam-solicitor-password",
    "idam-systemupdate-username",
    "idam-systemupdate-password"
  ]
}

data "azurerm_key_vault_secret" "nfdiv_secrets" {
  for_each     = toset(local.idam_secrets)
  name         = each.key
  key_vault_id = data.azurerm_key_vault.nfdiv_vault.id
}
resource "azurerm_key_vault_secret" "nfdiv_importer_username" {
  for_each     = data.azurerm_key_vault_secret.nfdiv_secrets
  name         = each.key
  value        = each.value.value
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "Vault ${data.azurerm_key_vault.nfdiv_vault.name}"
  })
}

