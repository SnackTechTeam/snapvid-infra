resource "aws_lambda_function" "auth_lambda" {
  filename         = "../lambda_auth/lambda_authorizer.js.zip"  # Arquivo ZIP contendo apenas o JS
  source_code_hash = filebase64sha256("../lambda_auth/lambda_authorizer.js.zip")
  function_name    = "lambda_authorizer"
  role             = data.aws_iam_role.labrole.arn
  handler          = "lambda_authorizer.handler"  # Mudou para o export do JS
  runtime          = "nodejs18.x"  # Ou a versão mais recente disponível

  environment {
    variables = {
      COGNITO_USERPOOL_ID = aws_cognito_user_pool.main.id
      COGNITO_REGION      = var.regionDefault
      CALLBACK_URL        = var.cognito_callback_url
    }
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Permissões para Lambda Authorizer"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "cognito-idp:ListUsers"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "execute-api:Invoke"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_cognito_user_pool" "main" {
  name = "auth-user-pool"

  username_attributes = ["email"]
  auto_verified_attributes = ["email"]

  schema {
    attribute_data_type = "String"
    name               = "email"
    required           = true
  }
}

resource "aws_cognito_user_pool_client" "app_client" {
  name = "auth-client"
  user_pool_id = aws_cognito_user_pool.main.id
  generate_secret = true

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true
  callback_urls = [var.cognito_callback_url] 
  supported_identity_providers = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "custom_domain" {
  domain         = var.cognito_domain_name
  user_pool_id   = aws_cognito_user_pool.main.id
}