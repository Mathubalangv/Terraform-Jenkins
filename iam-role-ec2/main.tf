provider "aws" {
  region = "ap-south-1"
}

### Create IAM policy
resource "aws_iam_policy" "ec2_s3_full_access_policy" {
  name        = "ec2_s3_full_access_policy"
  description = "Permissions for EC2 and S3"
  policy      = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Action: "ec2:*",
        Effect: "Allow",
        Resource: "*"
      },
      {
        Action: "s3:*",
        Effect: "Allow",
        Resource: "*"
      }
    ]
  })
}

### Create IAM role
resource "aws_iam_role" "ec2_s3_full_access_role" {
  name = "ec2_s3_full_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "examplerole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

### Attach IAM policy to IAM role
resource "aws_iam_policy_attachment" "ec2_s3_policy_attachment" {
  name       = "ec2_s3_policy_attachment"
  roles      = [aws_iam_role.ec2_s3_full_access_role.name]
  policy_arn = aws_iam_policy.ec2_s3_full_access_policy.arn
}

### Create instance profile using role
resource "aws_iam_instance_profile" "ec2_s3_instance_profile" {
  name = "ec2_s3_instance_profile"
  role = aws_iam_role.ec2_s3_full_access_role.name
}

### Create EC2 instance and attach IAM role
resource "aws_instance" "ec2_instance_with_role" {
  instance_type        = "t2.medium"
  ami                  = "ami-05295b6e6c790593e"
  tags = {
    Name = "instance_with_role"
  }
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_instance_profile.name
}
