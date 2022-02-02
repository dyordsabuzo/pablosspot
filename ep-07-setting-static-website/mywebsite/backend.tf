terraform {
  backend "s3" {
    bucket               = "pablosspot-terraform-backend"
    key                  = "terraform.tfstate"
    region               = "ap-southeast-2"
    workspace_key_prefix = "mywebsite"
    dynamodb_table       = "pablosspot-db-backend"
    encrypt              = true
  }
}
