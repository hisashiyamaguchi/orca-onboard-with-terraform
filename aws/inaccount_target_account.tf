################################################################################################################
#                                           Target Account                                                     #
################################################################################################################

################################################### Role #######################################################

resource "aws_iam_role" "side_scanner" {
  count = var.deployment_type == "inaccount_target_account" ? 1 : 0
  name  = "OrcaSideScannerRole"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          AWS : "arn:${var.aws_partition}:iam::${var.inaccount_scanner_account_id}:root"
        },
        Condition : {
          StringEquals : {
            "sts:ExternalId" : var.role_external_id
          }
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

################################################### Policy  ####################################################

resource "aws_iam_policy" "target_account_policy" {
  count       = var.deployment_type == "inaccount_target_account" ? 1 : 0
  policy      = replace(data.http.iam_policy_template["target_account_policy"].response_body, "$${partition}" , var.aws_partition)
  name        = "OrcaSecurityPolicy"
  description = "Orca Security Account Policy"
}

resource "aws_iam_policy" "target_account_rds_snapshot_create_policy" {
  count       = var.enable_dspm && var.deployment_type == "inaccount_target_account" ? 1 : 0
  policy      = replace(data.http.iam_policy_template["target_rds_snapshot_create_policy"].response_body, "$${partition}" , var.aws_partition)
  name        = "OrcaRdsSnapshotCreatePolicy"
  description = "Orca Security RDS Snapshot Creation Policy"
}

resource "aws_iam_policy" "target_account_rds_snapshot_reencrypt_policy" {
  count       = var.enable_dspm && var.deployment_type == "inaccount_target_account"  ? 1 : 0
  policy      = replace(data.http.iam_policy_template["target_rds_snapshot_reencrypt_policy"].response_body, "$${partition}" , var.aws_partition)
  name        = "OrcaRdsSnapshotReencryptPolicy"
  description = "Orca Security RDS Snapshot Re-Encryption Policy"
}

resource "aws_iam_policy" "target_account_rds_snapshot_share_policy" {
  count       = var.enable_dspm && var.deployment_type == "inaccount_target_account" ? 1 : 0
  policy      = replace(data.http.iam_policy_template["target_rds_snapshot_share_policy"].response_body, "$${partition}" , var.aws_partition)
  name        = "OrcaRdsSnapshotSharePolicy"
  description = "Orca Security RDS Snapshot Sharing Policy"
}

resource "aws_iam_policy" "side_scanner_policy" {
  count       = var.deployment_type == "inaccount_target_account" ? 1 : 0
  name        = "OrcaSideScannerPolicy"
  description = "Orca Side Scanner Account Policy"
  policy      = replace(data.http.iam_policy_template["side_scanner_policy"].response_body, "$${partition}" , var.aws_partition)
}


############################################# Policy Attachment ################################################



resource "aws_iam_role_policy_attachment" "target_account_attach" {
  count      = var.deployment_type == "inaccount_target_account" ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.target_account_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "side_scanner" {
  count      = var.deployment_type == "inaccount_target_account" ? 1 : 0
  role       = aws_iam_role.side_scanner[0].name
  policy_arn = aws_iam_policy.side_scanner_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "side_scanner_secrets_manager_access" {
  count      = var.secrets_manager_access && var.deployment_type == "inaccount_target_account" ? 1 : 0
  role       = aws_iam_role.side_scanner[0].name
  policy_arn = aws_iam_policy.secrets_manager_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "target_account_rds_snapshot_create_policy" {
  count      = var.enable_dspm && var.deployment_type == "inaccount_target_account" ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.target_account_rds_snapshot_create_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "target_account_rds_snapshot_reencrypt_policy" {
  count      = var.enable_dspm && var.deployment_type == "inaccount_target_account" ? 1 : 0
  role       = aws_iam_role.side_scanner[0].name
  policy_arn = aws_iam_policy.target_account_rds_snapshot_reencrypt_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "target_account_rds_snapshot_share_policy" {
  count      = var.enable_dspm && var.deployment_type == "inaccount_target_account" ? 1 : 0
  role       = aws_iam_role.side_scanner[0].name
  policy_arn = aws_iam_policy.target_account_rds_snapshot_share_policy[0].arn
}