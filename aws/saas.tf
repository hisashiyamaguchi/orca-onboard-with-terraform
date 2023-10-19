################################################################################################################
#                                                 Saas                                                         #
################################################################################################################

################################################### Policy  ####################################################

resource "aws_iam_policy" "rds_snapshot_create_policy" {
  count       = (var.enable_dspm && var.deployment_type == "saas") ? 1 : 0
  name        = "OrcaRdsSnapshotCreatePolicy"
  description = "Orca Security RDS Snapshot Creation Policy"
  policy      = replace(data.http.iam_policy_template["rds_snapshot_create_policy"].response_body, "$${partition}" , var.aws_partition)
}

resource "aws_iam_policy" "rds_snapshot_reencrypt_policy" {
  count       = (var.enable_dspm && var.deployment_type == "saas") ? 1 : 0
  name        = "OrcaRdsSnapshotReencryptPolicy"
  description = "Orca Security RDS Snapshot Re-Encryption Policy"
  policy      = replace(data.http.iam_policy_template["rds_snapshot_reencrypt_policy"].response_body, "$${partition}" , var.aws_partition)
}

resource "aws_iam_policy" "rds_snapshot_share_policy" {
  count       = (var.enable_dspm && var.deployment_type == "saas") ? 1 : 0
  name        = "OrcaRdsSnapshotSharePolicy"
  description = "Orca Security RDS Snapshot Re-Encryption Policy"
  policy      = replace(data.http.iam_policy_template["rds_snapshot_share_policy"].response_body, "$${partition}" , var.aws_partition)
}

############################################# Policy Attachment ################################################

resource "aws_iam_role_policy_attachment" "attach_rds_snapshot_create_policy" {
  count      = (var.enable_dspm && var.deployment_type == "saas") ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.rds_snapshot_create_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "attach_rds_snapshot_reencrypt_policy" {
  count      = (var.enable_dspm && var.deployment_type == "saas") ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.rds_snapshot_reencrypt_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "attach_rds_snapshot_share_policy" {
  count      = (var.enable_dspm && var.deployment_type == "saas") ? 1 : 0
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.rds_snapshot_share_policy[0].arn
}