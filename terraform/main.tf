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

provider "b2" {
  application_key_id = var.b2_application_key_id
  application_key    = var.b2_application_key
}

# resource "b2_application_key" "app_key_synology-backups" {
#   key_name = "synology-backups"
#   # bucket_id    = b2_bucket.earles_backup.bucket_id
#   capabilities = ["deleteFiles", "listBuckets", "listFiles", "readFiles", "writeFiles", "readBuckets", "readBucketEncryption", "readBucketNotifications", "readBucketReplications", "readBucketRetentions", "readFileLegalHolds", "readFileRetentions", "bypassGovernance", "deleteBuckets", "deleteKeys", "listKeys", "writeKeys", "shareFiles", "writeBucketEncryption", "writeBucketNotifications", "writeBucketReplications", "writeBucketRetentions", "writeBuckets", "writeFileLegalHolds", "writeFileRetentions", ]
# } //Removed due to unencrypted bucket.

resource "b2_bucket" "earles_backup" {
  bucket_name = "earles-backup"
  bucket_type = "allPrivate"
  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}

