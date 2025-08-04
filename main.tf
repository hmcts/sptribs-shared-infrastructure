provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.product}-${var.env}"
  location = var.location
  tags     = var.common_tags
}

# FlexiServer v15
module "db-v15" {
  providers = {
    azurerm.postgres_network = azurerm.cft_vnet
  }

  source               = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  admin_user_object_id = var.jenkins_AAD_objectId
  business_area        = "CFT"
  name                 = "sptribs-db-v15"
  product              = var.product
  env                  = var.env
  component            = var.component
  common_tags          = var.common_tags
  pgsql_version        = 15

  pgsql_databases = [
    {
      name    = var.database-name
    }
  ]
  pgsql_server_configuration = [
    {
      name  = "azure.extensions"
      value = "plpgsql,pg_stat_statements,pg_buffercache"
    }
  ]

  pgsql_sku            = var.pgsql_sku
  pgsql_storage_mb     = var.pgsql_storage_mb
  force_user_permissions_trigger = "1"
}



