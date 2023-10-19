<!-- BEGIN_TF_DOCS -->
## Requirements

[Authentication](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication)

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 4.84 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_scanner_account"></a> [scanner\_account](#module\_scanner\_account) | ./modules/scanner | n/a |
| <a name="module_service_accounts"></a> [service\_accounts](#module\_service\_accounts) | terraform-google-modules/service-accounts/google | ~> 4.2 |

## Resources

| Name | Type |
|------|------|
| [google_folder_iam_member.dspm_backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_folder_iam_member.kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_folder_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_organization_iam_custom_role.dspm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_custom_role.dspm_backup_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_custom_role.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_member.dspm_backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.kms](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_organization_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_binding.dspm_backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_member.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam.html#google_project_iam_member) | resource |
| [google_project_iam_custom_role.dspm_backup_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.dspm_scanner_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_service.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_dspm"></a> [enable\_dspm](#input\_enable\_dspm) | Add DSPM permissions | `bool` | `false` | no |
| <a name="input_enable_kms"></a> [enable\_kms](#input\_enable\_kms\_permissions) | Add KMS permissions to enable Orca to scan encrypted drives | `bool` | `false` | no |
| <a name="input_in_account"></a> [in\_account](#input\_in\_account) | Run the scanner inside my account (Not saas) | `bool` | `false` | no |
| <a name="input_multiple"></a> [multiple](#input\_multiple) | Connect multiple accounts | `bool` | `false` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | The GCP folder ID (only required if 'multiple' set to true. If not provided, by default applies to the entire organization) | `string` | `null` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | The GCP Organization ID (only required if 'multiple' set to true) | `string` | `null` | no |
| <a name="input_scanner_project_id"></a> [scanner\_project\_id](#input\_scanner\_project\_id) | The Scanner GCP Project ID (only required if 'in\_account' set to true) | `string` | `null` | no |
| <a name="input_scanner_project_number"></a> [scanner\_project\_number](#input\_scanner\_project\_number) | The Scanner GCP Project Number (only required if 'in\_account' set to true) | `string` | `null` | no |
| <a name="input_target_project_id"></a> [target\_project\_id](#input\_target\_project\_id) | Provide the Project ID in which you created the service account | `string` | `null` | no |
| <a name="input_role_id"></a> [role\_id](#input\_role\_id) | The Role ID that will be created | `string` | `orca_security_side_scanner_role_tf` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | The name of the Service Account that will be created (must be between 6 and 30 characters) | `string` | `orca-security-side-scanner-tf` | no |
| <a name="input_dspm_target_role_id"></a> [dspm\_target\_role\_id](#input\_dspm\_target\_role\_id)          | The DSPM target Role ID that will be created | `string` | `orca_security_dspm_scanner_role_tf`      | no |
| <a name="input_dspm_org_target_role_id"></a> [dspm\_org\_target\_role\_id](#input\_dspm\_org\_target\_role\_id) | The Org-level DSPM target role ID that will be created | `string` | `orca_security_dspm_scanner_role_org_tf`      | no |
| <a name="input_dspm_vendor_role_id"></a> [dspm\_vendor\_role\_id](#input\_dspm\_vendor\_role\_id)          | The DSPM vendor role ID that will be created | `string` | `orca_security_dspm_backup_role_tf`      | no |
| <a name="input_dspm_org_vendor_role_id"></a> [dspm\_org\_vendor\_role\_id](#input\_dspm\_org\_vendor\_role\_id) | The Org-level DSPM vendor role ID that will be created | `string` | `orca_security_dspm_backup_role_org_tf`      | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account_json_key"></a> [service\_account\_json\_key](#output\_service\_account\_json\_key) | Service account key (for single use). |
| <a name="target_project_id"></a> [target\_project\_id](#output\_target\_project\_id) | Target Project ID that will be onboarded. |
| <a name="scanner_project_id"></a> [scanner\_project\_id](#output\_scanner\_project\_id) | Scanner Project ID (In-Account mode). |
| <a name="gcp_organization_id"></a> [gcp\_organization\_id](#output\_gcp\_organization\_id) | GCP Organization ID (Multi onboarding). |
<!-- END_TF_DOCS -->
