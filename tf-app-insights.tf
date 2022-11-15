

resource "azurerm_application_insights" "appinsights" {
  name                = "${var.product}-appinsights-${var.env}"
  location            = var.appinsights_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      application_type,
    ]
  }
}

resource "azurerm_key_vault_secret" "appinsights_key" {
  name         = "AppInsightsInstrumentationKey"
  value        = azurerm_application_insights.appinsights.instrumentation_key
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "App Insights ${azurerm_application_insights.appinsights.name}"
  })
}

resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  name         = "AppInsightsConnectionString"
  value        = azurerm_application_insights.appinsights.connection_string
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "App Insights ${azurerm_application_insights.appinsights.name}"
  })
}


resource "azurerm_application_insights" "appinsights_preview" {
  count = var.env == "aat" ? 1 : 0

  name                = "${var.product}-appinsights-preview"
  location            = var.appinsights_location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"

  tags = var.common_tags

  lifecycle {
    ignore_changes = [
      application_type,
    ]
  }
}


resource "azurerm_key_vault_secret" "appinsights_preview_key" {
  count = var.env == "aat" ? 1 : 0

  name  = "AppInsightsInstrumentationKey-Preview"
  value = azurerm_application_insights.appinsights_preview[0].instrumentation_key

  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "App Insights ${azurerm_application_insights.appinsights_preview[0].name}"
  })
}

resource "azurerm_key_vault_secret" "appinsights_preview_connection_string" {
  count = var.env == "aat" ? 1 : 0

  name         = "AppInsightsConnectionString-Preview"
  value        = azurerm_application_insights.appinsights_preview[0].connection_string
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "App Insights ${azurerm_application_insights.appinsights_preview[0].name}"
  })
}
