variable "bucket_name" {
  default = "altsch-proj-tfstate"
}

variable "kms_master_key_id" {
  default = ""
}

variable "read_capacity" {
  default = 1
}

variable "write_capacity" {
  default = 1
}

variable "aws_dynamodb_table_enabled" {
  type = bool
  default = true
}

variable "aws_region" {
  default = "us-east-1"
}