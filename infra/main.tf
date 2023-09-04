provider "aws" {
  region = "us-east-1"
}
##############
###   S3   ###
##############

resource "aws_s3_bucket" "dev_bucket" {
  bucket = local.dev_name
}

resource "aws_s3_bucket" "prd_bucket" {
  bucket = local.prd_name
}


##############
##### SQS ####
##############

resource "aws_sqs_queue" "dev_queue" {
  name = local.dev_name
}

resource "aws_sqs_queue" "prd_queue" {
  name = local.prd_name
}

################
### DYNAMODB ###
################
resource "aws_dynamodb_table" "dev_table" {
  name         = local.dev_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}
resource "aws_dynamodb_table" "prd_table" {
  name         = local.prd_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
}

################
### IAM USER ###
################

resource "aws_iam_user" "dev_user" {
  name = local.dev_name
}

resource "aws_iam_user" "prd_user" {
  name = local.prd_name
}

################
#### POLICY #### 
################
resource "aws_iam_policy" "dev_policy" {
  name        = local.dev_name
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
        Action   = ["dynamodb:DescribeTable", "dynamodb:GetItem", "dynamodb:Query", "dynamodb:PutItem"],
        Resource = [aws_dynamodb_table.dev_table.arn],
      },
      {
        Effect   = "Allow",
        Action   = ["sqs:GetQueueUrl", "sqs:SendMessage"]
        Resource = [aws_sqs_queue.dev_queue.arn]
      }
    ],
  })
}

resource "aws_iam_policy" "prd_policy" {
  name        = local.prd_name
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
      {
        Effect   = "Allow",
        Action   = ["sqs:*"]
        Resource = [aws_sqs_queue.dev_queue.arn, aws_sqs_queue.prd_queue.arn]
      }
    ],
  })
}


################################
######  POLICY ATTACHMENT  ##### 
################################

resource "aws_iam_user_policy_attachment" "dev_attachment" {
  user       = aws_iam_user.dev_user.name
  policy_arn = aws_iam_policy.dev_policy.arn
}

resource "aws_iam_user_policy_attachment" "prd_attachment" {
  user       = aws_iam_user.prd_user.name
  policy_arn = aws_iam_policy.prd_policy.arn
}

################
###  OUTPUT  ### 
################
output "s3_dev" {
  value = aws_s3_bucket.dev_bucket.bucket
}

output "s3_prd" {
  value = aws_s3_bucket.prd_bucket.bucket
}
