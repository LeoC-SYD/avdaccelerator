# AADDS Terraform Scenario

This scenario deploys a greenfield Azure Virtual Desktop (AVD) environment with session hosts joined to Microsoft Entra Domain Services.

## Prerequisites
- Terraform CLI >= 1.3
- Azure subscription with sufficient permissions
- Existing Microsoft Entra Domain Services instance
- Custom image published to an Azure Compute Gallery
- Azure Storage account for Terraform state (see `backend.tfvars.sample`)
- Credentials for a domain user with permissions to join machines (`aadds_username` and `aadds_password`)

## Usage
```bash
cd workload/terraform/greenfield/AADDSscenario
terraform init -backend-config=backend.tfvars
terraform plan -out tfplan
terraform apply tfplan
```

## Destroy
```bash
terraform destroy
```

## Variables
See [`variables.tf`](variables.tf) for full list. Sample values, including domain join credentials, are provided in [`terraform.tfvars.sample`](terraform.tfvars.sample).

## Outputs
Key outputs are defined in [`output.tf`](output.tf) and include resource group names, host pool identifiers and networking information.

## Architecture
A high level architecture diagram is available at `docs/diagrams/avd-accelerator-terraform-baseline-image.png` in the repository.

## Change Log
See [CHANGELOG.md](CHANGELOG.md) for history of updates.
