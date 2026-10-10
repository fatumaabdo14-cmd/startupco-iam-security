# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}

# IAM Groups
resource "aws_iam_group" "developers" {
  name = "Developer"
}

resource "aws_iam_group" "operations" {
  name = "Operations"
}

resource "aws_iam_group" "finance" {
  name = "Finance"
}

resource "aws_iam_group" "analysts" {
  name = "Analyst"
}

# Developer EC2 Dev Access Policy
resource "aws_iam_policy" "developer_ec2_dev_access" {
  name        = "DeveloperEC2DevAccess"
  description = "Allow developers to manage dev EC2 instances only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RunInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/environment" = "dev"
          }
        }
      }
    ]
  })
}

# Developer S3 Dev Access Policy
resource "aws_iam_policy" "developer_s3_dev_access" {
  name        = "DeveloperS3DevAccess"
  description = "Allow developers to read/write dev S3 buckets only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::dev-*",
          "arn:aws:s3:::dev-*/*"
        ]
      }
    ]
  })
}

# Attach Developer policies to Developer group
resource "aws_iam_group_policy_attachment" "developer_ec2_attachment" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_ec2_dev_access.arn
}

resource "aws_iam_group_policy_attachment" "developer_s3_attachment" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_s3_dev_access.arn
}

# Operations: read-only day to day (Level 2)
# Production changes go through the StartupCo-OpsProdAdmin role with MFA
resource "aws_iam_group_policy_attachment" "operations_ec2_readonly" {
  group      = aws_iam_group.operations.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "operations_rds_readonly" {
  group      = aws_iam_group.operations.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "operations_cloudwatch_readonly" {
  group      = aws_iam_group.operations.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# Finance: read-only billing and budgets
resource "aws_iam_group_policy_attachment" "finance_budgets" {
  group      = aws_iam_group.finance.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBudgetsReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "finance_billing" {
  group      = aws_iam_group.finance.name
  policy_arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
}

# Analysts: no direct data access (Level 2)
# Customer data is reached only through the StartupCo-AnalystData role with MFA

# Developer Users
resource "aws_iam_user" "dev_users" {
  count = 4
  name  = "dev-user-${count.index + 1}"
}

# Operations Users
resource "aws_iam_user" "ops_users" {
  count = 2
  name  = "ops-user-${count.index + 1}"
}

# Finance User
resource "aws_iam_user" "finance_user" {
  name = "finance-user-1"
}

# Analyst Users
resource "aws_iam_user" "analyst_users" {
  count = 3
  name  = "analyst-user-${count.index + 1}"
}

# Add developers to Developer group
resource "aws_iam_group_membership" "developers" {
  name  = "developer-membership"
  users = aws_iam_user.dev_users[*].name
  group = aws_iam_group.developers.name
}

# Add operations to Operations group
resource "aws_iam_group_membership" "operations" {
  name  = "operations-membership"
  users = aws_iam_user.ops_users[*].name
  group = aws_iam_group.operations.name
}

# Add finance to Finance group
resource "aws_iam_group_membership" "finance" {
  name  = "finance-membership"
  users = [aws_iam_user.finance_user.name]
  group = aws_iam_group.finance.name
}

# Add analysts to Analyst group
resource "aws_iam_group_membership" "analysts" {
  name  = "analyst-membership"
  users = aws_iam_user.analyst_users[*].name
  group = aws_iam_group.analysts.name
}
