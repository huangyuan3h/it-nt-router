terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" 
    }
  }
}

provider "aws" {
  region = "us-east-1"

}

resource "aws_iam_role" "lambda_role" {
  name = "graphql-router-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid = ""
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-basic-execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "graphql_router" {
  function_name = "graphql-router-lambda"
  package_type = "Image"

  image_uri = "319653899185.dkr.ecr.us-east-1.amazonaws.com/it-t/graphql-router-lambda:latest"

  memory_size = 128
  timeout = 30
  role = aws_iam_role.lambda_role.arn
}

resource "aws_apigatewayv2_api" "graphql_api" {
  name          = "it-nt-graphql-router-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.graphql_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.graphql_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.graphql_router.invoke_arn
  payload_format_version = "2.0"

  request_parameters = {
    "append:header.X-Request-ID" = "$request.requestId"
  }

  response_parameters {
    status_code = "*" 
    mappings = {
      "application/json" = "$response.body"
    }
  }
}

resource "aws_apigatewayv2_route" "graphql_route" {
  api_id    = aws_apigatewayv2_api.graphql_api.id
  route_key = "POST /graphql" 
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigateway_lambda_permission" {
  function_name = aws_lambda_function.graphql_router.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.graphql_api.execution_arn}/*/*"
}
