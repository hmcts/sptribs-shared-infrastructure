provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azurerm" {
  features {}
  alias           = "postgres_network"
  subscription_id = var.aks_subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location
  tags     = var.common_tags
}

# FlexiServer v15
module "db-v15" {
  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source               = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  admin_user_object_id = var.jenkins_AAD_objectId
  business_area        = "CFT"
  name                 = "${var.product}-${var.env}-flexible-db-v15"
  product              = var.product
  env                  = var.env
  component            = var.component
  common_tags          = var.common_tags
  pgsql_version        = 15
  auto_grow_enabled    = true

  pgsql_databases = [
    {
      name = var.database-name
      report_privilege_schema : "public"
      report_privilege_tables : ["case_data", "case_event"]
    }
  ]
  pgsql_server_configuration = [
    {
      name  = "azure.extensions"
      value = "pg_stat_statements,pg_buffercache"
    },
    {
      name  = "log_lock_waits"
      value = "on"
    },
    {
      name  = "pg_qs.query_capture_mode"
      value = "ALL"
    },
    {
      name  = "pgms_wait_sampling.query_capture_mode"
      value = "ALL"
    },
    {
      name  = "logfiles.download_enable"
      value = "ON"
    },
    {
      name  = "logfiles.retention_days"
      value = "14"
    },
  ]

  pgsql_sku                      = var.pgsql_sku
  pgsql_storage_mb               = var.pgsql_storage_mb
  force_user_permissions_trigger = "1"
  user_secret_name               = azurerm_key_vault_secret.POSTGRES-USER.name
  pass_secret_name               = azurerm_key_vault_secret.POSTGRES-PASS.name
}



