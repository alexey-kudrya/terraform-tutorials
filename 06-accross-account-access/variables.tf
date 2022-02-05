variable "key_name" {
  description = "The name of your ssh-key."
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
  default = "demo-s3-bucket-for-across-acount-access"
}