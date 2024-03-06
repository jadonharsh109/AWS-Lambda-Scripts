provider "aws" {
  region = "us-east-1" # or your preferred region
}

resource "aws_lambda_function" "stop_ec2_instances" {
  function_name = "stop_ec2_instances"
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  timeout       = 60

  role = aws_iam_role.lambda_exec.arn

  // Here 'filename' refers to the deployment package that contains your Python code.
  // Replace 'path_to_zip_file' with the actual path to the zip file containing your Python script.
  filename = "main.zip"

  source_code_hash = filebase64sha256("main.zip")

}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "IAM policy for lambda to stop EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "ec2:DescribeRegions"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

