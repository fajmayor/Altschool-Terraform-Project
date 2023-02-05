terraform {
  backend "s3" {
    region = "us-east-1"
    bucket = "altsch-proj-tfstate"
    key = "altsch-proj-tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }
}