
resource "aws_api_gateway_vpc_link" "main" {
 depends_on = [ data.aws_lb.LoadBalancer ]
 name = "main-vpc-link-eks"
 description = "vpc link for api gateway"
 target_arns = [data.aws_lb.LoadBalancer.arn]
}

resource "aws_api_gateway_rest_api" "main" {
 name = "eks_gateway"
 description = "EKS API Gateway."
 endpoint_configuration {
   types = ["REGIONAL"]
 }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_authorizer" "lambda_auth" {
  depends_on = [ aws_api_gateway_rest_api.main, aws_lambda_function.auth_lambda ]
  name          = "LambdaAuth"
  rest_api_id   = aws_api_gateway_rest_api.main.id
  authorizer_uri = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.auth_lambda.arn}/invocations"
  type          = "TOKEN"  # Mantenha como TOKEN para JWT
  identity_source = "method.request.header.Authorization"
  
  # Adicione essas linhas:
  authorizer_credentials = data.aws_iam_role.labrole.arn
  authorizer_result_ttl_in_seconds = 300
}

resource "aws_lambda_permission" "allow_apigateway" {
  depends_on = [ aws_lambda_function.auth_lambda, aws_api_gateway_rest_api.main ]
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "proxy" {
  depends_on = [ aws_api_gateway_rest_api.main, aws_api_gateway_resource.proxy, aws_api_gateway_authorizer.lambda_auth ]
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.lambda_auth.id

  request_parameters = {
    "method.request.path.proxy"           = true
    "method.request.header.Authorization" = true
  }
}

resource "aws_api_gateway_integration" "proxy" {
  depends_on = [ data.aws_lb.LoadBalancer, aws_api_gateway_vpc_link.main ]
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${data.aws_lb.LoadBalancer.dns_name}:8080/{proxy}"
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"

  request_parameters = {
    "integration.request.path.proxy"           = "method.request.path.proxy"
    # Mapeia o userId do contexto do autorizador para um header X-User-Id
    "integration.request.header.X-User-Id" = "context.authorizer.userId"
    # Mapeia o email do contexto do autorizador para um header X-User-Email
    "integration.request.header.X-User-Email" = "context.authorizer.email"
    "integration.request.header.Accept"        = "method.request.header.Accept"
    "integration.request.header.Authorization" = "method.request.header.Authorization"
  }

  connection_type = "VPC_LINK"
  connection_id   = aws_api_gateway_vpc_link.main.id
}

resource "aws_api_gateway_stage" "dev_stage" {
  depends_on = [ aws_api_gateway_rest_api.main, aws_api_gateway_deployment.api_deployment ]
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [ aws_api_gateway_rest_api.main, aws_api_gateway_method.proxy ]
  rest_api_id = aws_api_gateway_rest_api.main.id
  triggers = {
    redeploy = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy.id,
      aws_api_gateway_integration.proxy.id,
      aws_api_gateway_authorizer.lambda_auth.id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}