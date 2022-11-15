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



#data "azurerm_key_vault" "s2s_vault" {
#  name                = "s2s-${var.env}"
#  resource_group_name = "rpe-service-auth-provider-${var.env}"
#}
#
#data "azurerm_key_vault_secret" "sptribs_case_api_s2s_key" {
#  name         = "microservicekey-sptribs-case-api"
#  key_vault_id = data.azurerm_key_vault.s2s_vault.id
#}
#
#resource "azurerm_key_vault_secret" "sptribs_case_api_s2s_secret" {
#  name         = "s2s-case-api-secret"
#  value        = data.azurerm_key_vault_secret.sptribs_case_api_s2s_key.value
#  key_vault_id = module.key-vault.key_vault_id
#}
#
#data "azurerm_key_vault_secret" "sptribs_frontend_s2s_key" {
#  name         = "microservicekey-sptribs-frontend"
#  key_vault_id = data.azurerm_key_vault.s2s_vault.id
#}
#
#resource "azurerm_key_vault_secret" "sptribs_frontend_s2s_secret" {
#  name         = "frontend-secret"
#  value        = data.azurerm_key_vault_secret.sptribs_frontend_s2s_key.value
#  key_vault_id = module.key-vault.key_vault_id
#}
