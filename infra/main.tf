provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "dev_bucket" {
  bucket = "${local.repo}-dev-${local.sufix}"
}

resource "aws_s3_bucket" "prd_bucket" {
  bucket = "${local.repo}-prd-${local.sufix}"
}

resource "aws_iam_user" "dev_user" {
  name = "${local.repo}-dev-user"
}

resource "aws_iam_user" "prd_user" {
  name = "${local.repo}-prd-user"
}

resource "aws_dynamodb_table" "dev_table" {
  name         = "${local.repo}-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}
resource "aws_dynamodb_table" "prd_table" {
  name         = "${local.repo}-prd"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}
resource "aws_iam_policy" "dev_policy" {
  name        = "${local.repo}-dev-policy"
  description = "Policy to allow access to the dev bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.dev_bucket.arn],
      },
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:PutObject"],
        Resource = [aws_s3_bucket.dev_bucket.arn, "${aws_s3_bucket.dev_bucket.arn}/*"],
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:Query"],
        Resource = [aws_dynamodb_table.dev_table.arn],
      },
    ],
  })
}

resource "aws_iam_policy" "prd_policy" {
  name        = "${local.repo}-prd-policy"
  description = "Policy to allow access to both dev and prd buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = [aws_s3_bucket.dev_bucket.arn, aws_s3_bucket.prd_bucket.arn],
      },
      {
        Effect   = "Allow",
        Action   = ["s3:*Object"],
        Resource = [aws_s3_bucket.dev_bucket.arn, "${aws_s3_bucket.dev_bucket.arn}/*", aws_s3_bucket.prd_bucket.arn, "${aws_s3_bucket.prd_bucket.arn}/*"],
      },
      {
        Effect = "Allow",
        Action = ["dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
        "dynamodb:Query", ],
        Resource = [aws_dynamodb_table.dev_table.arn, aws_dynamodb_table.prd_table.arn],
      },
    ],
  })
}

resource "aws_iam_user_policy_attachment" "dev_attachment" {
  user       = aws_iam_user.dev_user.name
  policy_arn = aws_iam_policy.dev_policy.arn
}

resource "aws_iam_user_policy_attachment" "prd_attachment" {
  user       = aws_iam_user.prd_user.name
  policy_arn = aws_iam_policy.prd_policy.arn
}


output "s3_dev" {
  value = aws_s3_bucket.dev_bucket.bucket
}

output "s3_prd" {
  value = aws_s3_bucket.prd_bucket.bucket
}

output "iam_user_dev" {
  value = aws_iam_user.dev_user.name
}

output "iam_user_prd" {
  value = aws_iam_user.prd_user.name
}

output "dynamodb_dev" {
  value = aws_dynamodb_table.dev_table.name
}

output "dynamodb_prd" {
  value = aws_dynamodb_table.prd_table.name
}
