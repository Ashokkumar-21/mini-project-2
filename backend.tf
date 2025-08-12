terraform {
  backend "s3" {
    bucket         = "ak-mini-2"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}