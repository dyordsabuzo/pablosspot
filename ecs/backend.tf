terraform {
    backend "remote" {
        hostname = "api.terraform.io"
        organization = "pablosspot"

        workspaces {
            prefix = "ps-wordpress-ecs-"
        }
    }
}
