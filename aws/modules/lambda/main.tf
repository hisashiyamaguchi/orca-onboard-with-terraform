module "lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.function_name
  lambda_role   = var.lambda_role
  source_path   = var.source_file
  environment_variables = var.env_vars

  handler     = replace(basename(var.source_file), ".py", ".handler")
  create_role = false
  runtime     = "python3.8"
  timeout     = 300
  publish     = true
}

resource "aws_lambda_alias" "add_kms_grant_alias" {
  name             = var.alias
  function_version = "$LATEST"
  function_name    = module.lambda.lambda_function_arn
}
