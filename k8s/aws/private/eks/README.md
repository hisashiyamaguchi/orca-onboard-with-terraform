<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.57.1 |

**This Module requires HTTPS access to the EKS API server endpoint and awscli to be installed locally where Terraform is executed.**

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.57.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
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
| [kubernetes_cluster_role.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_namespace.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role_binding.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [random_string.random_str](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/eks_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/4.57.1/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The EKS cluster name | `string` | n/a | yes |
| <a name="input_execution_role"></a> [execution\_role](#input\_execution\_role) | Custom execution role (If not provided, a new role will be created.) | `string` | `""` | no |
| <a name="input_orca_role_arn"></a> [orca\_role\_arn](#input\_orca\_role\_arn) | The ARN for Orca's IAM role | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->