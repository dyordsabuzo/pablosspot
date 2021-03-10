module "mywebsite" {
  source      = "../s3-static-website"
  endpoint    = "mywebsite.pablosspot.ml"
  domain_name = "pablosspot.ml"
  region      = var.region
  bucket_name = "mywebsite.pablosspot.ml"
}
