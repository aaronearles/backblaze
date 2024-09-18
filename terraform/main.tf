terraform {
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
  }
backend "s3" {
    endpoints = {
      s3 = "s3.us-west-004.backblazeb2.com"
    }
    bucket = "earles-tfstate"
    key    = "terraform_backblaze.tfstate"
    region = "us-west-1"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
}
}

variable "b2_application_key_id" {}
variable "b2_application_key" {}

provider "b2" {
  application_key_id = var.b2_application_key_id
  application_key    = var.b2_application_key
}

resource "b2_application_key" "app_key_synology-backups" {
  key_name = "synology-backups"
  bucket_id = b2_bucket.earles_backup.bucket_id
  capabilities = ["readFiles","writeFiles"]
}

resource "b2_bucket" "earles_backup" {
  bucket_name = "earles-backup"
  bucket_type = "allPrivate"
}