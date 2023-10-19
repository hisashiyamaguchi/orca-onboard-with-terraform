<!-- BEGIN_TF_DOCS -->
# Terraform module for onboarding AWS account to Orca
The account connection process is also referred to as account onboarding. It is the process of establishing a connection between an Orca account and your Cloud Service Provider (CSP) account.

When the connection between Orca and CSP is established, Orca can access your CSP infrastructure and scan it for vulnerabilities and other security issues.

## How to Connect AWS Accounts
There are several options for connecting your Orca account to the AWS account.
You can select one of the following [deployment modes](https://docs.orcasecurity.io/v1/docs/deployment-modes)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.57.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.56.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.3.0 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda"></a> [lambda](#module\_lambda) | ./modules/lambda | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack_set.this](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.this](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_iam_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rds_snapshot_create_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rds_snapshot_reencrypt_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rds_snapshot_share_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scanner_account_lambda_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scanner_account_lambda_extended_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.scanner_account_rds_scanning_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.secrets_manager_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.side_scanner_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.target_account_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.target_account_rds_snapshot_create_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.target_account_rds_snapshot_reencrypt_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.target_account_rds_snapshot_share_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_policy.view_only_extras_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_policy) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role) | resource |
| [aws_iam_role.scanner_account_add_kms_grant_role](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role) | resource |
| [aws_iam_role.scanner_account_common_lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role) | resource |
| [aws_iam_role.scanner_account_create_kms_key_role](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role) | resource |
| [aws_iam_role.side_scanner](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.attach_rds_snapshot_create_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_rds_snapshot_reencrypt_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_rds_snapshot_share_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_secrets_manager_access](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_view_only](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attach_view_only_extras](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.orca-attach](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.scanner_account_add_kms_grant_attach](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.scanner_account_attach](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.scanner_account_common_lambda_execution_attach_1](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.scanner_account_common_lambda_execution_attach_2](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.scanner_account_create_kms_key_attach](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.side_scanner](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.side_scanner_secrets_manager_access](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.target_account_attach](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.target_account_rds_snapshot_create_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.target_account_rds_snapshot_reencrypt_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.target_account_rds_snapshot_share_policy](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role_policy_attachment) | resource |
| [local_file.this](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/organizations_organization) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/region) | data source |
| [aws_s3_object.cloudformation_stack_set_inaccount](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/s3_object) | data source |
| [aws_s3_object.cloudformation_stack_set_saas](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/s3_object) | data source |
| [aws_s3_object.iam_policy_template](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/s3_object) | data source |
| [aws_s3_object.this](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/s3_object) | data source |
| [aws_s3_objects.this](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/s3_objects) | data source |
| [template_file.iam_policy](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deploy_stack_set"></a> [deploy\_stack\_set](#input\_deploy\_stack\_set) | Orca Organization-level stack set. This stack set will automatically deploy Orca permissions on OU or all Organization's accounts (Deploy in your organization MANAGEMENT ACCOUNT). | `bool` | `false` | no |
| <a name="input_enable_dspm"></a> [enable\_dspm](#input\_enable\_dspm) | Whether to add RDS scanner policy to Orca's role. Default: true | `bool` | `true` | no |
| <a name="input_secrets_manager_access"></a> [secrets\_manager\_access](#input\_secrets\_manager\_access) | Whether to attach SecretsManager policy to Orca's role. Default: true | `bool` | `true` | no |
| <a name="input_organizational_unit_ids"></a> [organizational\_unit\_ids](#input\_organizational\_unit\_ids) | When you choose to deploy a stack set, you can choose organizational unit ids to which it will apply (If not provided, the default is to apply to the entire organization). | `list(string)` | `null` | no |
| <a name="input_aws_partition"></a> [aws\_partition](#input\_aws\_partition) | AWS partition (aws / aws-cn / aws-us-gov) | `string` | `"aws"` | no |
| <a name="input_deployment_type"></a> [deployment\_type](#input\_deployment\_type) | Deployment type to install (Supported types: saas/inaccount\_scanner\_account/inaccount\_target\_account) | `string` | n/a | yes |
| <a name="input_inaccount_scanner_account_id"></a> [inaccount\_scanner\_account\_id](#input\_inaccount\_scanner\_account\_id) | When the "deployment\_type" is "inaccount\_target\_account" you must provide the Scanner account ID. | `string` | `null` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Policy Name is created with a default name, if you want changed it. | `string` | `"OrcaSecurityPolicy"` | no |
| <a name="input_role_external_id"></a> [role\_external\_id](#input\_role\_external\_id) | Role external ID. Will be supplied from Orca. | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Role Name is created with a default name, if you want changed it. | `string` | `"OrcaSecurityRole"` | no |
| <a name="input_vendor_account_id"></a> [vendor\_account\_id](#input\_vendor\_account\_id) | The vendor account id. This is supplied by Orca. | `string` | `"976280145156"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_customer_account_id"></a> [customer\_account\_id](#output\_customer\_account\_id) | This is the account id to be used for onboarding the account |
| <a name="output_orca_role_arn"></a> [orca\_role\_arn](#output\_orca\_role\_arn) | Role ARN to be used to onboard |
| <a name="output_orca_side_scanner_role_arn"></a> [orca\_side\_scanner\_role\_arn](#output\_orca\_side\_scanner\_role\_arn) | Side Scanner Role ARN to be used to onboard |
<!-- END_TF_DOCS -->