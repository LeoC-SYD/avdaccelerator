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
| `scenario_identity` | Identity scenario: `aadds`, `entra_id`, or `hybrid_ad` |
| `device_management` | Device management option: `intune` or `none` |
| `fslogix_storage` | FSLogix profile storage type |
| `fslogix_auth_mode` | FSLogix auth mode: `aadds_smb` or `entra_id_kerberos` |
| `join_method` | Session host join method |
| `aadds_domain_name` | Microsoft Entra Domain Services domain name |
| `aadds_username` | Username for the domain join account |
| `aadds_password` | (Optional) Password for the domain join account |
| `rdsh_count` | Number of session host VMs |
| `session_host_sku` | Size of the session host VMs |

See [variables.tf](variables.tf) for the full list of configurable values.

### Identity & Device Management Scenarios

| scenario_identity | join_method   | extensions                                  | fslogix_auth_mode   | DNS/PE requirements |
|-------------------|---------------|---------------------------------------------|---------------------|---------------------|
| `aadds`           | `domain_join` | `JsonADDomainExtension`, `DSC`               | `aadds_smb`         | Private DNS & PEs for Storage/Key Vault |
| `entra_id`        | `entra_join`  | `AADLoginForWindows`, `IntuneManagement`*   | `entra_id_kerberos` | Private DNS & PEs for Storage/Key Vault |
| `hybrid_ad`       | `domain_join` | `JsonADDomainExtension`, `DSC`               | `aadds_smb`         | Private DNS & route to on-prem DCs |

*`IntuneManagement` extension only when `device_management = "intune"`.

## Outputs

Key outputs expose the selected scenario details and the IDs of created session hosts.

## Change Log

See [CHANGELOG.md](CHANGELOG.md) for a list of modifications and updates.
