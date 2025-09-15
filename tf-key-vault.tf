module "key-vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  product             = var.product
  env                 = var.env
  tenant_id           = var.tenant_id
  object_id           = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name

  # dcd_platformengineering group object ID
  product_group_name      = "DTS Special Tribunals"
  common_tags             = var.common_tags
  create_managed_identity = true
}

data "azurerm_key_vault" "key_vault" {
  name                = "${var.product}-${var.env}"
  resource_group_name = "${var.product}-${var.env}"
}

data "azurerm_key_vault" "s2s_vault" {
  name                = "s2s-${var.env}"
  resource_group_name = "rpe-service-auth-provider-${var.env}"
}

data "azurerm_key_vault_secret" "key_from_vault" {
  name         = "microservicekey-sptribs-case-api"
  key_vault_id = data.azurerm_key_vault.s2s_vault.id
}

resource "azurerm_key_vault_secret" "s2s" {
  name         = "s2s-case-api-secret"
  value        = data.azurerm_key_vault_secret.key_from_vault.value
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault" "civil_vault" {
  name                = "civil-${var.env}"
  resource_group_name = "civil-service-${var.env}"
}

data "azurerm_key_vault" "em_key_vault" {
  name                = "em-stitching-${var.env}"
  resource_group_name = "em-stitching-${var.env}"
}

data "azurerm_key_vault_secret" "ccd_importer_username_civil" {
  name         = "ccd-importer-username"
  key_vault_id = data.azurerm_key_vault.civil_vault.id
}

data "azurerm_key_vault_secret" "ccd_importer_password_civil" {
  name         = "ccd-importer-password"
  key_vault_id = data.azurerm_key_vault.civil_vault.id
}

resource "azurerm_key_vault_secret" "ccd_importer_username_sptribs" {
  name         = "ccd-importer-username"
  value        = data.azurerm_key_vault_secret.ccd_importer_username_civil.value
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "ccd_importer_password_sptribs" {
  name         = "ccd-importer-password"
  value        = data.azurerm_key_vault_secret.ccd_importer_password_civil.value
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-USER" {
  name         = join("-", [var.product, "POSTGRES-USER"])
  value        = module.postgresql.username
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

resource "azurerm_key_vault_secret" "POSTGRES-PASS" {
  name         = join("-", [var.product, "POSTGRES-PASS"])
  value        = module.postgresql.password
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "docmosis_access_key" {
  key_vault_id = data.azurerm_key_vault.em_key_vault.id
  name         = "docmosis-access-key"
}

resource "azurerm_key_vault_secret" "docmosis_access_key" {
  name         = "docmosis-access-key"
  value        = data.azurerm_key_vault_secret.docmosis_access_key.value
  key_vault_id = data.azurerm_key_vault.key_vault.id
}
