
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
    random = {
      source = "hashicorp/random"
    }
    local = {
      source = "hashicorp/local"
    }
    azapi = {
      source = "Azure/azapi"
    }
    time = {
      source = "hashicorp/time"
    }
  }
  backend "azurerm" {
    use_azuread_auth     = true    
    client_id = "c3289f55-258c-4442-b42e-c4c51af48fb7"
    client_secret = var.client_secret
    tenant_id                  = "c05f7306-c76e-493f-8be0-c73c616ead5e"
    resource_group_name  = "rg-syd-tf-prod-frc-001"
    storage_account_name       = "stsydtfprod001"
    container_name             = "tfstate-defaults"
    key                        = "terraform.tfstate"
  }

}

provider "azurerm" {
  partner_id = "49f4cdfa-97bf-4dde-94b0-957dc9321bad"
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy      = false
      purge_soft_deleted_certificates_on_destroy = false
      purge_soft_deleted_keys_on_destroy         = false
      recover_soft_deleted_key_vaults            = true
      recover_soft_deleted_secrets               = true
      recover_soft_deleted_certificates          = true
      recover_soft_deleted_keys                  = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

provider "azurerm" {
  features {}
  alias           = "hub"
  subscription_id = var.hub_subscription_id
}

provider "azurerm" {
  features {}
  alias           = "spoke"
  subscription_id = var.spoke_subscription_id
}

provider "azurerm" {
  features {}
  alias           = "avdshared"
  subscription_id = var.avdshared_subscription_id
}

provider "azurerm" {
  features {}
  alias           = "identity"
  subscription_id = var.identity_subscription_id
}
