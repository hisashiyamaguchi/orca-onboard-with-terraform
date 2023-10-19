{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": "arn:${partition}:ec2:*::snapshot/*",
            "Condition": {
                "ForAnyValue:StringEquals": {
                    "aws:TagKeys": [
                        "Orca"
                    ]
                },
                "StringEquals": {
                    "ec2:CreateAction": [
                        "CreateSnapshot",
                        "CreateSnapshots",
                        "CopySnapshot"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/Orca": "*"
                },
                "StringNotLikeIfExists": {
                    "ec2:ResourceTag/OrcaOptOut": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshots",
                "ec2:CreateSnapshot",
                "ec2:CopySnapshot",
                "ec2:ModifySnapshotAttribute"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotLikeIfExists": {
                    "ec2:ResourceTag/OrcaOptOut": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:ReEncryptFrom",
                "kms:ReEncryptTo",
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:CreateGrant"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotLikeIfExists": {
                    "aws:ResourceTag/OrcaOptOut": "*"
                },
                "StringLike": {
                    "kms:ViaService": "ec2.*.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "kms:PutKeyPolicy"
            ],
            "Resource": "*",
            "Condition": {
                "StringNotLikeIfExists": {
                    "aws:ResourceTag/OrcaOptOut": "*"
                }
            }
        }
    ]
}
