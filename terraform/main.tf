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
    access_key = var.b2_application_key_id //B2 keyID
    secret_key = var.b2_application_key    //B2 applicationKey
    bucket     = "earles-tfstate"
    key        = "terraform_backblaze.tfstate"
    region     = "us-west-004"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
  }
}

variable "b2_application_key_id" {}
variable "b2_application_key" {}
variable "capabilities_all" {}
variable "capabilities_bucket_admin" {}

provider "b2" {
  application_key_id = var.b2_application_key_id
  application_key    = var.b2_application_key
}

resource "b2_application_key" "app_key_synology-backup" {
  key_name     = "synology-backup"
  bucket_id    = b2_bucket.earles_backup.bucket_id
  capabilities = var.capabilities_bucket_admin
}

resource "b2_application_key" "app_key_synology-replicate" {
  key_name     = "synology-replicate"
  bucket_id    = b2_bucket.synology_replica.bucket_id
  capabilities = var.capabilities_bucket_admin
}

resource "b2_application_key" "app_key_earles-bedrock" {
  key_name     = "earles-bedrock"
  bucket_id    = b2_bucket.earles-bedrock.bucket_id
  capabilities = var.capabilities_bucket_admin
}

resource "b2_bucket" "earles_backup" {
  bucket_name = "earles-backup"
  bucket_type = "allPrivate"
  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}

resource "b2_bucket" "synology_replica" {
  bucket_name = "synology-replica"
  bucket_type = "allPrivate"
  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}

resource "b2_bucket" "earles-bedrock" {
  bucket_name = "earles-bedrock"
  bucket_type = "allPrivate"
  # default_server_side_encryption {
  #   algorithm = "AES256"
  #   mode      = "SSE-B2"
  # }
}
