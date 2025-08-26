# Change Log

## Unreleased
- Updated provider versions and removed deprecated `skip_provider_registration` flag to support current Terraform releases.
- Simplified Data Collection Rule module and fixed missing required arguments for compatibility with azurerm v4.
- Replaced deprecated `storage_account_name` with `storage_account_id` for storage share, improving future compatibility.
- Removed deprecated `retention_policy` blocks and switched diagnostic settings to dynamic categories to reduce warnings.
- Added domain join user creation and associated variables to enable automated AADDS joins.
- Added `source_image_id` for session host VMs and cleaned unused resources for clarity.
- Fixed missing variable declarations and corrected resource references to prevent runtime errors.
- Added comprehensive documentation in `README.md` for easier deployment and maintenance.
