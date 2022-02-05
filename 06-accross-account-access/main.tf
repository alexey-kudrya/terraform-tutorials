provider "aws" {
  region = "us-east-2"
}

provider "aws" {
  alias = "account-a"
  profile = "account-a"
  region = "us-east-2"
}

provider "aws" {
  alias = "account-b"
  profile = "account-b"
  region = "us-east-2"
}

resource "aws_s3_bucket" "demo-s3-bucket" {
  provider = aws.account-b
  bucket = var.bucket_name
  force_destroy = true
  acl    = "private"
}

resource "aws_iam_role" "demo_s3_accros_account_role" {
  provider = aws.account-b
  name = "demo_s3_accros_account_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.account-a.account_id}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF
}

resource "aws_iam_policy" "demo_s3_accros_account_policy" {
  provider = aws.account-b
  name = "demo_s3_accros_account_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": [
        "${aws_s3_bucket.demo-s3-bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "demo_s3_accros_account_attach" {
  provider = aws.account-b
  role       = aws_iam_role.demo_s3_accros_account_role.name
  policy_arn = aws_iam_policy.demo_s3_accros_account_policy.arn
}

resource "aws_iam_role" "demo_ec2_accros_account_role" {
  provider = aws.account-a
  name = "demo_ec2_accros_account_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "demo_ec2_accros_account_policy" {
  provider = aws.account-a
  name = "demo_ec2_accros_account_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": [
        "arn:aws:iam::${data.aws_caller_identity.account-b.account_id}:role/${aws_iam_role.demo_s3_accros_account_role.name}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "demo_ec2_accros_account_attach" {
  provider = aws.account-a
  role       = aws_iam_role.demo_ec2_accros_account_role.name
  policy_arn = aws_iam_policy.demo_ec2_accros_account_policy.arn
}

resource "aws_iam_instance_profile" "demo_ec2_profile" {
  provider = aws.account-a
  name = "demo_ec2_profile"
  role = aws_iam_role.demo_ec2_accros_account_role.name
}

resource "aws_instance" "demo_ec2" {
  provider = aws.account-a
  ami = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  security_groups = [aws_security_group.demo_ec2.name]
  key_name      = var.key_name
  iam_instance_profile = aws_iam_instance_profile.demo_ec2_profile.name

  tags = {
    Name = "demo_ec2"
  }
}

resource "aws_security_group" "demo_ec2" {
  provider = aws.account-a
  name = "demo_ec2"
  description = "demo_ec2"

  ingress {
    from_port = 22
    to_port = 22
    description = "SSH"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

data "aws_caller_identity" "account-a" {
  provider = aws.account-a
}

data "aws_caller_identity" "account-b" {
  provider = aws.account-b
}