# Change Log

## [Unreleased]
### Added
- Log Analytics workspace deployment (`insights.tf`).
- Provider version constraints and Terraform required version.
- `.terraform.lock.hcl` committed for reproducible builds.
- Backend configuration for remote Terraform state.
- Domain join VM extension with variable-based credentials.

### Changed
- Updated AzureRM, AzureAD, Random, Local, AzAPI and Time providers to latest stable versions.
- Replaced deprecated `enable_https_traffic_only` with `https_traffic_only_enabled`.
- Removed external Insights module and inlined workspace resource.
- Simplified host VM extensions and ensured session hosts join the AAD DS domain.
- Updated Azure AD service principal data source to use `client_id`.

### Removed
- Legacy `readme.md` documentation in favour of streamlined `README.md`.
