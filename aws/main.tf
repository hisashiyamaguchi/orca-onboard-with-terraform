terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.63.0"
    }
  }
}

################################################################################################################
#                                         Shared Resources                                                     #
################################################################################################################

################################################# Role ######################################################

resource "aws_iam_role" "role" {
  name = local.role_name
  assume_role_policy = local.orca_assume_role_policy
}

################################################### Policy  ####################################################

resource "aws_iam_policy" "policy" {
  count       = var.deployment_type == "inaccount_target_account" ? 0 : 1
  policy      = replace(data.http.iam_policy_template["policy"].response_body, "$${partition}" , var.aws_partition)
  name        = local.policy_name
  description = "Orca Security Account Policy"
}

resource "aws_iam_policy" "view_only_extras_policy" {
  policy      = replace(data.http.iam_policy_template["view_only_extras_policy"].response_body, "$${partition}" , var.aws_partition)
  name        = "OrcaSecurityViewOnlyExtrasPolicy"
  description = "Orca Security Extras For View Only Policy"
}

resource "aws_iam_policy" "secrets_manager_policy" {
  count       = (var.secrets_manager_access && (var.deployment_type == "saas" || var.deployment_type == "inaccount_target_account")) ? 1 : 0
  name        = "OrcaSecuritySecretsManagerPolicy"
  description = "Orca Security Secrets Manager Policy"
  policy      = replace(data.http.iam_policy_template["secrets_manager_policy"].response_body, "$${partition}" , var.aws_partition)
}

############################################# Policy Attachment ################################################

resource "aws_iam_role_policy_attachment" "orca-attach" {
  count      = var.deployment_type == "inaccount_target_account" ? 0 : 1
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy[0].arn
}

resource "aws_iam_role_policy_attachment" "attach_view_only" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:${var.aws_partition}:iam::aws:policy/job-function/ViewOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "attach_view_only_extras" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.view_only_extras_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_access" {
  count      = (var.secrets_manager_access && var.deployment_type == "saas") ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.secrets_manager_policy[0].arn
}



