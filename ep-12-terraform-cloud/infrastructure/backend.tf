terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "my-pablosspot"

    workspaces {
      name = "ps-access-key-generator"
    }
  }
}
