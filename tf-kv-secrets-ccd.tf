data "azurerm_key_vault" "ccd_vault" {
  name                = "ccd-${var.env}"
  resource_group_name = "ccd-shared-${var.env}"
}


data "azurerm_key_vault_secret" "ccd_importer_username" {
  name         = "ccd-importer-username"
  key_vault_id = data.azurerm_key_vault.ccd_vault.id
}
resource "azurerm_key_vault_secret" "ccd_importer_username" {
  name         = "definition-importer-username"
  value        = azurerm_key_vault_secret.ccd_importer_username.value
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "Vault ${data.azurerm_key_vault.ccd_vault.name}"
  })
}


data "azurerm_key_vault_secret" "ccd_importer_password" {
  name         = "ccd-importer-password"
  key_vault_id = data.azurerm_key_vault.ccd_vault.id
}
resource "azurerm_key_vault_secret" "ccd_importer_password" {
  name         = "definition-importer-password"
  value        = azurerm_key_vault_secret.ccd_importer_password.value
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "Vault ${data.azurerm_key_vault.ccd_vault.name}"
  })
}