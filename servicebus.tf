data "azurerm_servicebus_namespace" "ccd_namespace" {
  name                = "ccd-servicebus-${var.env}"
  resource_group_name = "ccd-shared-${var.env}"
}

data "azurerm_servicebus_topic" "ccd_case_events_topic" {
  name                = "ccd-case-events-${var.env}"
  namespace_name      = data.azurerm_servicebus_namespace.ccd_namespace.name
  resource_group_name = data.azurerm_servicebus_namespace.ccd_namespace.resource_group_name
}

resource "azurerm_servicebus_topic_authorization_rule" "ccd_case_events_topic_send" {
  name                = "${var.product}-sendonly"
  namespace_name      = data.azurerm_servicebus_namespace.ccd_namespace.name
  topic_name          = data.azurerm_servicebus_topic.ccd_case_events_topic.name
  resource_group_name = data.azurerm_servicebus_namespace.ccd_namespace.resource_group_name

  listen = false
  send   = true
  manage = false
}

resource "azurerm_key_vault_secret" "ccd_case_events_send_primary_connection_string" {
  name         = "ccd-case-events-sendonly-connection-string"
  value        = azurerm_servicebus_topic_authorization_rule.ccd_topic_send.primary_connection_string
  key_vault_id = module.key-vault.key_vault_id

  content_type = "terraform-managed"
  tags = merge(var.common_tags, {
    "source" : "ccd-case-events ${var.product}-sendonly"
  })
}

