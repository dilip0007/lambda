provider "aws" {
  region = "us-east-1"
}

# S3 bucket for Lambda deployment package
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-poc5-bucket-${random_id.suffix.hex}"
  force_destroy = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda-poc5-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Lambda function
resource "aws_lambda_function" "poc5_lambda" {
  function_name = "poc5-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = "lambda-poc5.zip"
  depends_on    = [aws_s3_object.lambda_code]
}

# Upload Lambda code to S3
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda-poc5.zip"
  source = "lambda-poc5.zip"  # Path to zipped Lambda code
}