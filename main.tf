provider azurerm {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location

  tags = var.common_tags
}

module "key-vault" {
  source              = "git@github.com:hmcts/cnp-module-key-vault?ref=master"
  product             = var.product
  env                 = var.env
  tenant_id           = var.tenant_id
  object_id           = var.jenkins_AAD_objectId
  resource_group_name = azurerm_resource_group.rg.name

  # dcd_platformengineering group object ID
  product_group_name = "dcd_sptribs"
  common_tags                = var.common_tags
  create_managed_identity    = true
}

resource "azurerm_key_vault_secret" "AZURE_APPINSIGHTS_KEY" {
  name         = "AppInsightsInstrumentationKey"
  value        = azurerm_application_insights.appinsights.instrumentation_key
  key_vault_id = module.key-vault.key_vault_id
}

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.product}-appinsights-${var.env}"
  location            = var.appinsights_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to appinsights as otherwise upgrading to the Azure provider 2.x
      # destroys and re-creates this appinsights instance..
      application_type,
    ]
  }
}

resource "azurerm_key_vault_secret" "AZURE_APPINSIGHTS_KEY_PREVIEW" {
  name         = "AppInsightsInstrumentationKey-Preview"
  value        = azurerm_application_insights.appinsights_preview[0].instrumentation_key
  key_vault_id = module.key-vault.key_vault_id
  count = var.env == "aat" ? 1 : 0
}

data "azurerm_key_vault" "s2s_vault" {
  name                = "s2s-${var.env}"
  resource_group_name = "rpe-service-auth-provider-${var.env}"
}

data "azurerm_key_vault_secret" "sptribs_case_api_s2s_key" {
  name         = "microservicekey-sptribs-case-api"
  key_vault_id = data.azurerm_key_vault.s2s_vault.id
}

resource "azurerm_key_vault_secret" "sptribs_case_api_s2s_secret" {
  name         = "s2s-case-api-secret"
  value        = data.azurerm_key_vault_secret.sptribs_case_api_s2s_key.value
  key_vault_id = module.key-vault.key_vault_id
}

data "azurerm_key_vault_secret" "sptribs_frontend_s2s_key" {
  name         = "microservicekey-sptribs-frontend"
  key_vault_id = data.azurerm_key_vault.s2s_vault.id
}

resource "azurerm_key_vault_secret" "sptribs_frontend_s2s_secret" {
  name         = "frontend-secret"
  value        = data.azurerm_key_vault_secret.sptribs_frontend_s2s_key.value
  key_vault_id = module.key-vault.key_vault_id
}

resource "azurerm_application_insights" "appinsights_preview" {
  name                = "${var.product}-appinsights-preview"
  location            = var.appinsights_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  count = var.env == "aat" ? 1 : 0

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to appinsights as otherwise upgrading to the Azure provider 2.x
      # destroys and re-creates this appinsights instance..
      application_type,
    ]
  }
}

/*
data "azurerm_key_vault_secret" "alerts_email" {
  name      = "alerts-email"
  key_vault_id = module.key-vault.key_vault_id
}
*/

resource "azurerm_monitor_action_group" "appinsights" {
  name                = "sptribs-ag1"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "sptribs-alrt"
  email_receiver {
    name          = "sendtoadmin"
//    email_address = data.azurerm_key_vault_secret.alerts_email.value
    email_address = "div-support2@HMCTS.NET"

  }

  webhook_receiver {
    name                    = "sptribs-l-app"
    service_uri             = "https://prod-00.uksouth.logic.azure.com:443/workflows/92968083557f446bb6acff64ea3afa69/triggers/manual/paths/invoke?api-version=2016-10-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=FWSXTSNydGuxnZy9q_34_QDp1IIsZeP8yRdpCmLOKc8"
    use_common_alert_schema = true
  }
}

  resource "azurerm_monitor_metric_alert" "metric_alert_exceptions" {
  name                = "exceptions_alert"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_application_insights.appinsights.id]
  description         = "Alert will be triggered when Exceptions are more than 2 per 5 mins"

  criteria {
    metric_namespace = "Microsoft.Insights/Components"
    metric_name      = "performanceCounters/exceptionsPerSecond"
    aggregation      = "Maximum"
    operator         = "GreaterThanOrEqual"
    threshold        = 2

  }

  action {
    action_group_id = azurerm_monitor_action_group.appinsights.id
  }
  count = var.custom_alerts_enabled ? 1 : 0  
}
