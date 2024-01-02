
resource "azurerm_monitor_action_group" "appinsights" {
  name                = "sptribs-ag1"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "spt-alerts"
  email_receiver {
    name = "sendtoadmin"
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
  scopes              = [module.application_insights.id]
  description         = "Alert will be triggered when Exceptions are more than 2 per 5 mins"
  tags                = var.common_tags

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

/*
data "azurerm_key_vault_secret" "alerts_email" {
  name      = "alerts-email"
  key_vault_id = module.key-vault.key_vault_id
}
*/
#data "azurerm_key_vault_secret" "slack_monitoring_address" {
#  name         = "slack-monitoring-address"
#  key_vault_id = "${module.key-vault.key_vault_id}"
#}

#output "slack_monitoring_address" {
#  value = data.azurerm_key_vault_secret.slack_monitoring_address
#}

#module "sptribs-fail-alert" {
#  source            = "git@github.com:hmcts/cnp-module-metric-alert"
#  location          = azurerm_application_insights.appinsights.location
#  app_insights_name = azurerm_application_insights.appinsights.name
#
#  alert_name                 = "sptribs-fail-alert"
#  alert_desc                 = "Triggers when an sptribs exception is received in a 5 minute poll."
#  app_insights_query         = "requests | where toint(resultCode) >= 400 | sort by timestamp desc"
#  frequency_in_minutes       = 15
#  time_window_in_minutes     = 15
#  severity_level             = "3"
#  action_group_name          = module.sptribs-fail-action-group-slack.action_group_name
#  custom_email_subject       = "sptribs Service Exception"
#  trigger_threshold_operator = "GreaterThan"
#  trigger_threshold          = 0
#  resourcegroup_name         = azurerm_resource_group.rg.name
#  common_tags                = var.common_tags
#}

#module "sptribs-migration-alert" {
#  source            = "git@github.com:hmcts/cnp-module-metric-alert"
#  location          = azurerm_application_insights.appinsights.location
#  app_insights_name = azurerm_application_insights.appinsights.name
#
#  alert_name                 = "sptribs-migration-alert"
#  alert_desc                 = "Triggers when a migration fails."
#  app_insights_query         = "traces | where message contains \"Setting dataVersion to 0 for case id\" | sort by timestamp desc"
#  frequency_in_minutes       = 60
#  time_window_in_minutes     = 60
#  severity_level             = "1"
#  action_group_name          = module.sptribs-fail-action-group-slack.action_group_name
#  custom_email_subject       = "sptribs Migration Failed"
#  trigger_threshold_operator = "GreaterThan"
#  trigger_threshold          = 0
#  resourcegroup_name         = azurerm_resource_group.rg.name
#  common_tags                = var.common_tags
#}

#module "sptribs-fail-action-group-slack" {
#  source   = "git@github.com:hmcts/cnp-module-action-group"
#  location = "global"
#  env      = var.env
#
#  resourcegroup_name     = azurerm_resource_group.rg.name
#  action_group_name      = "sptribs Fail Slack Alert - ${var.env}"
#  short_name             = "spt_slack"
#  email_receiver_name    = "sptribs Alerts"
#  email_receiver_address = "${data.azurerm_key_vault_secret.slack_monitoring_address.value}"
#}
