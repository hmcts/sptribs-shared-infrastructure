
variable "common_tags" {
  type = map(string)
}

variable "product" {
  default = "sptribs"
}
variable "env" {}
variable "tenant_id" {}

variable "location" {
  default = "UK South"
}

variable "managed_identity_object_id" {
  default = ""
}

variable "jenkins_AAD_objectId" {
  description = "(Required) The Azure AD object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies."
}

variable "appinsights_location" {
  default     = "UK South"
  description = "Location for Application Insights"
}

variable "custom_alerts_enabled" {
  description = "If set to true, enable alerts"
  default     = false
}

variable "pgsql_sku" {
  description = "The PGSql flexible server instance sku"
  default     = "GP_Standard_D2s_v3"
}

variable "pgsql_storage_mb" {
  description = "Max storage allowed for the PGSql Flexibile instance"
  type        = number
  default     = 65536
}

variable "component" {}

variable "database-name" {
  default = "sptribs"
}
