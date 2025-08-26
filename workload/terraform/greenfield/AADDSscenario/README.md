# AADDS Scenario - Azure Virtual Desktop Terraform Deployment

This Terraform configuration deploys an Azure Virtual Desktop (AVD) environment joined to Microsoft Entra Domain Services (AADDS). It provisions core network components, session hosts, monitoring, and supporting resources following Terraform best practices.

![Architecture](../../../docs/diagrams/avd-accelerator-terraform-baseline-image.png)

## Prerequisites

- Azure subscription with permission to create resources
- Existing Microsoft Entra Domain Services instance
- Custom AVD image available in a Shared Image Gallery
- [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.13 or later
- Azure CLI logged in with the target subscription

## Deployment

```bash
cd workload/terraform/greenfield/AADDSscenario
terraform init
terraform plan -out avd.plan
terraform apply avd.plan
```

## Destroy

```bash
terraform destroy
```

## Key Variables

| Name | Description |
|------|-------------|
| `avdLocation` | Azure region for all resources |
| `prefix` | Short prefix used in resource names |
| `aadds_domain_name` | Microsoft Entra Domain Services domain name |
| `dc_admin_username` | Username for the domain join account |
| `rdsh_count` | Number of session host VMs |
| `vm_size` | Size of the session host VMs |

See [variables.tf](variables.tf) for the full list of configurable values.

## Outputs

This scenario does not export outputs by default. Resources can be referenced directly using the Terraform state.

## Change Log

See [CHANGELOG.md](CHANGELOG.md) for a list of modifications and updates.
