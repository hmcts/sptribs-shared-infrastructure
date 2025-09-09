module "application_insights" {
  source = "git@github.com:hmcts/terraform-module-application-insights?ref=DTSPO-27514"

  env                 = var.env
  product             = var.product
  name                = "${var.product}-appinsights"
  location            = var.appinsights_location
  resource_group_name = azurerm_resource_group.rg.name

  common_tags = var.common_tags
}

moved {
  from = azurerm_application_insights.appinsights
  to   = module.application_insights.azurerm_application_insights.this
}

resource "azurerm_key_vault_secret" "appinsights_key" {
  name         = "app-insights-instrumentation-key"
  value        = module.application_insights.instrumentation_key
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "App Insights ${var.product}-appinsights"
  })
}

resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  name         = "app-insights-connection-string"
  value        = module.application_insights.connection_string
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "App Insights ${var.product}-appinsights"
  })
}


module "application_insights_preview" {
  count  = var.env == "aat" ? 1 : 0
  source = "git@github.com:hmcts/terraform-module-application-insights?ref=DTSPO-27514"

  env                 = "preview"
  product             = var.product
  name                = "${var.product}-appinsights"
  location            = var.appinsights_location
  resource_group_name = azurerm_resource_group.rg.name

  common_tags = var.common_tags
}

moved {
  from = azurerm_application_insights.appinsights_preview[0]
  to   = module.application_insights_preview[0].azurerm_application_insights.this
}

resource "azurerm_key_vault_secret" "appinsights_preview_key" {
  count = var.env == "aat" ? 1 : 0

  name  = "app-insights-instrumentation-key-preview"
  value = module.application_insights_preview[0].instrumentation_key

  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "App Insights ${var.product}-appinsights-preview"
  })
}

resource "azurerm_key_vault_secret" "appinsights_preview_connection_string" {
  count = var.env == "aat" ? 1 : 0

  name         = "app-insights-connection-string-preview"
  value        = module.application_insights_preview[0].connection_string
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "App Insights ${var.product}-appinsights-preview"
  })
}
