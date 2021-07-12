provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

#terraform {
# backend "s3" {
#   bucket  = "bucket_name"
#   key     = "global/s3/terraform.tfstate"
#   region  = "us-east-2"

#   dynamodb_table  = "table_name"
#   encrypt         = "true"
# }
#}
