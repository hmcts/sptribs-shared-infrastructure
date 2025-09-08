module "postgresql" {

  providers = {
    azurerm.postgres_network = azurerm.postgres_network
  }

  source            = "git@github.com:hmcts/terraform-module-postgresql-flexible?ref=master"
  name              = "${var.product}-${var.env}-flexible-db-v15"
  business_area     = "CFT"
  product           = var.product
  env               = var.env
  component         = var.component
  common_tags       = var.common_tags
  auto_grow_enabled = true

  # The original subnet is full, this is required to use the new subnet for new databases
  subnet_suffix = "expanded"

  pgsql_databases = [
    {
      name : var.database-name
    }
  ]

  pgsql_sku             = var.pgsql_sku
  pgsql_storage_mb      = var.pgsql_storage_mb
  pgsql_version         = "16"
  geo_redundant_backups = var.postgres_geo_redundant_backups

  force_user_permissions_trigger = "1"
  user_secret_name               = azurerm_key_vault_secret.POSTGRES-USER.name
  pass_secret_name               = azurerm_key_vault_secret.POSTGRES-PASS.name

  # Changing the value of the trigger_password_reset variable will trigger Terraform to rotate the password of the pgadmin user.
  trigger_password_reset = "1"

  # The ID of the principal to be granted admin access to the database server.
  # On Jenkins it will be injected for you automatically as jenkins_AAD_objectId.
  # Otherwise change the below:
  admin_user_object_id = var.jenkins_AAD_objectId
}