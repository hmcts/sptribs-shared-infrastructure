# Azure Document Intelligence (FormRecognizer) account, for OCR of case
# documents (medical evidence, police reports, statements) before their text is
# sent to the HMCTS AI Gateway for interpretation.
#
# AAT only for now — this is the environment sptribs is onboarded to on the AI
# Gateway (hmcts/platform-ai-gateway-infra environments/stg).
#
# No model deployments: cognitive_deployments is for Azure OpenAI models, and
# Document Intelligence's prebuilt models (prebuilt-read, prebuilt-layout) are
# built into the service rather than deployed per-account.
#
# Configured for private-only access from the outset — no public network
# access, deny-all ACL default, and Entra-ID-only auth so no account key
# exists to leak. Following the same shape as cnp-plum-shared-infrastructure's
# ai-services.tf, no private endpoint is created here; sptribs has no subnet of
# its own in this repo, so the PE is attached separately.
module "document_intelligence" {
  count = var.env == "aat" ? 1 : 0

  source = "git@github.com:hmcts/terraform-module-ai-services?ref=main"

  providers = {
    azurerm.private_dns = azurerm # required alias; unused since enable_managed_network = false skips all PE/DNS lookups
  }

  env         = var.env
  product     = var.product
  project     = "cft"
  component   = "document-intelligence"
  common_tags = var.common_tags

  existing_resource_group_name = azurerm_resource_group.rg.name
  location                     = var.location

  create_ai_foundry        = false
  create_storage_account   = false
  create_cognitive_account = true
  enable_managed_network   = false

  cognitive_account_kind = "FormRecognizer"
  cognitive_account_sku  = var.document_intelligence_sku

  public_network_access_cognitive                      = false
  cognitive_account_network_acls_default_action        = "Deny"
  cognitive_account_local_auth_enabled                 = false
  cognitive_account_outbound_network_access_restricted = true
}

# sptribs-case-api calls the analyze API as itself, using its workload identity.
# Document Intelligence has no dedicated data-plane role, so "Cognitive Services
# User" is the least-privileged role that grants the data actions required to
# call analyze. local_auth_enabled = false above means this RBAC grant is the
# only way in — there is no account key.
resource "azurerm_role_assignment" "case_api_document_intelligence_user" {
  count = var.env == "aat" ? 1 : 0

  scope                = module.document_intelligence[0].cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = "c3481e83-d24c-4ddb-80c0-420a1327cb8a" # sptribs-aat-mi
}

# Endpoint only. There is deliberately no key secret: the account is
# Entra-ID-only, so the application authenticates with its managed identity.
resource "azurerm_key_vault_secret" "document_intelligence_endpoint" {
  count = var.env == "aat" ? 1 : 0

  name         = "document-intelligence-endpoint"
  value        = one(module.document_intelligence[0].cognitive_account_endpoint)
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

output "document_intelligence_account_id" {
  value       = length(module.document_intelligence) == 0 ? null : module.document_intelligence[0].cognitive_account_id
  description = "ID of the sptribs Document Intelligence account (aat only; null elsewhere)."
}

output "document_intelligence_endpoint" {
  value       = length(module.document_intelligence) == 0 ? null : one(module.document_intelligence[0].cognitive_account_endpoint)
  description = "Endpoint of the sptribs Document Intelligence account (aat only; null elsewhere)."
}
