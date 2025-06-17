resource "azurerm_resource_group" "rg1" {
    name = var.rgname
    location = var.location
}

module "servicePrincipal" {
    source = "./modeles/ServicePrincipal"
    service_principal_name = var.service_principal_name

    depends_on = [
        azurerm_resource_group.rg1
    ]
}

resource "azurerm_role_assignment" "rolespn" {
    scope = "./subscriptions/${var.SUB_ID}"
    role_definition_name = "Contributor"
    principal_id = module.ServicePrincipal.service_principal_object_id

    depends_on = [ module.servicePrincipal ]
}

module "keyvault" {
    source = "./modules/keyvault"
    keyvault_name = var.keyvault_name
    location = var.location
    resource_group_name = var.rgname
    service_principal_name = var.service_principle_name
    service_principal_object_id = module.ServicePrincipal.service_principal_object_id
    service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id

    depends_on = [ module.servicePrincipal ]
}

resource "azurerm_key_vault_secret" "example" {
    name = module.ServicePrincipal.client_id
    value = module.ServicePrincipal.client_secret
    key_vault_id = module.keyvault.keyvault_id

    depends_on = [ module.keyvault ]
}

module "aks" {
    source = "./modules/aks/"
    service_principal_name = var.service_principle_name
    client_id = module.ServicePrincipal.client_id
    client_secret = module.ServicePrincipal.client_secret
    location = var.location
    resource_group_name = var.rgname

    depends_on = [ module.ServicePrincipal ]
}

resource "local_file" "kubeconfig" {
  depends_on = [ module.aks ]
  filename = "./kubeconfig"
  content = module.aks.config
}