################################################################################
#                                    Lambda                                    #
################################################################################

resource "random_string" "random_str" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

resource "aws_iam_role" "orca_eks_fetch_lambda_execution_role" {
  count = var.execution_role == "" ? 1 : 0
  name  = "OrcaEksFetchLambdaExecutionRole-${random_string.random_str.result}"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = { Service = ["lambda.amazonaws.com"] }
          Action    = ["sts:AssumeRole"]
        }
      ]
    }
  )

  inline_policy {
    name = "LambdaBasicPolicy"
    policy = jsonencode(
      {
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
            Resource = "*"
            Sid      = "LambdaBasicPolicy"
          }
        ]
      }
    )
  }

  inline_policy {
    name = "LambdaBaOrcaEc2ForLambdaExtendedPolicysicPolicy"
    policy = jsonencode(
      {
        Version = "2012-10-17"
        Statement = [{
          Effect   = "Allow"
          Action   = ["ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DeleteNetworkInterface", "lambda:GetLayerVersion"]
          Resource = "*"
          Sid      = "OrcaEc2ForLambdaExtendedPolicy"
          }
        ]
      }
    )
  }

  inline_policy {
    name = "OrcaLambdaForLambdaExtendedPolicy"
    policy = jsonencode(
      {
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["lambda:UpdateFunctionCode", "lambda:UpdateFunctionEventInvokeConfig", "lambda:UpdateFunctionConfiguration"]
            Resource = "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:orca*"
            Sid      = "OrcaLambdaForLambdaExtendedPolicy"
          }
        ]
      }
    )
  }

  tags = {
    Orca             = "True"
    TargetK8sCluster = local.self_managed_cluster.cluster_name
  }
}

module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "orca-k8s-collect-${random_string.random_str.result}"
  lambda_role   = var.execution_role != "" ? var.execution_role : aws_iam_role.orca_eks_fetch_lambda_execution_role[0].arn
  source_path   = "${path.module}/lambda/k8s-collect.py"

  handler     = "k8s-collect.lambda_handler"
  layers      = ["arn:aws:lambda:us-east-1:976280145156:layer:kubernator:3"]
  create_role = false
  runtime     = "python3.8"
  timeout     = 900
  publish     = true

  vpc_subnet_ids         = var.lambda_subnet_ids
  vpc_security_group_ids = var.lambda_security_group_ids

  tags = {
    Orca = "True"
  }
}


resource "aws_lambda_permission" "orca_invoke_permission" {
  function_name = module.lambda.lambda_function_arn
  action        = "lambda:InvokeFunction"
  principal     = local.role
}