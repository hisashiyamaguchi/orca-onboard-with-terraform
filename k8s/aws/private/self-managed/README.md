<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.57.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.18.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.18.1 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda"></a> [lambda](#module\_lambda) | terraform-aws-modules/lambda/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.orca_eks_fetch_lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/iam_role) | resource |
| [aws_lambda_permission.orca_invoke_permission](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/resources/lambda_permission) | resource |
| [kubernetes_cluster_role.this](https://registry.terraform.io/providers/hashicorp/kubernetes/2.18.1/docs/resources/cluster_role) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/2.18.1/docs/resources/namespace) | resource |
| [kubernetes_role_binding.this](https://registry.terraform.io/providers/hashicorp/kubernetes/2.18.1/docs/resources/role_binding) | resource |
| [kubernetes_secret_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/2.18.1/docs/resources/secret_v1) | resource |
| [kubernetes_service_account.this](https://registry.terraform.io/providers/hashicorp/kubernetes/2.18.1/docs/resources/service_account) | resource |
| [null_resource.get_api_server_url](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.random_str](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/caller_identity) | data source |
| [local_file.api_server_url](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.cluster_name](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [null_data_source.api_server_url](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_execution_role"></a> [execution\_role](#input\_execution\_role) | Custom execution role (If not provided, a new role will be created.) | `string` | `""` | no |
| <a name="input_lambda_security_group_ids"></a> [lambda\_security\_group\_ids](#input\_lambda\_security\_group\_ids) | List of security groups IDs with access to the kubernetes cluster API server endpoint for Orca lambda function | `list(string)` | n/a | yes |
| <a name="input_lambda_subnet_ids"></a> [lambda\_subnet\_ids](#input\_lambda\_subnet\_ids) | List of subnet IDs with access to the kubernetes cluster API server endpoint for Orca lambda function | `list(string)` | n/a | yes |
| <a name="input_orca_role_arn"></a> [orca\_role\_arn](#input\_orca\_role\_arn) | The ARN for Orca's IAM role | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_self_managed_cluster"></a> [self\_managed\_cluster](#output\_self\_managed\_cluster) | n/a |
<!-- END_TF_DOCS -->