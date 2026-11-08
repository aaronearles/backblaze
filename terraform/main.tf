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
variable "capabilities_bucket_writer" {}

provider "b2" {
  application_key_id = var.b2_application_key_id
  application_key    = var.b2_application_key
}

### DELETE SYNOLOGY HYPERBACKUP 12/19/2025 TO FIX FAILED 11/02 DEPLOY ###
# resource "b2_application_key" "app_key_synology-backup" {
#   key_name     = "synology-backup"
#   bucket_id    = b2_bucket.earles_backup.bucket_id
#   capabilities = var.capabilities_bucket_admin
# }

resource "b2_application_key" "app_key_synology-replicate" {
  key_name     = "synology-replicate"
  bucket_id    = b2_bucket.synology_replica.bucket_id
  capabilities = var.capabilities_bucket_admin
}

# bedrock LXC (aaronearles/mc-lan): world backups, world transfers and add-on artifacts.
# Read and upload, no delete: lifecycle rules on the bucket do the deleting.
resource "b2_application_key" "app_key_bedrock-lan" {
  key_name     = "bedrock-lan"
  bucket_id    = b2_bucket.earles-bedrock.bucket_id
  capabilities = var.capabilities_bucket_writer
}

resource "b2_application_key" "app_key_earles-public" {
  key_name     = "earles-public"
  bucket_id    = b2_bucket.earles-public.bucket_id
  capabilities = var.capabilities_bucket_admin
}

resource "b2_application_key" "app_key_earles-vw-backup" {
  key_name     = "earles-vw-backup"
  bucket_id    = b2_bucket.earles-vw-backup.bucket_id
  capabilities = var.capabilities_bucket_admin
}

resource "b2_application_key" "app_key_earles-health" {
  key_name     = "earles-health"
  bucket_id    = b2_bucket.earles-health.bucket_id
  capabilities = var.capabilities_bucket_admin
}

### DELETE SYNOLOGY HYPERBACKUP 11/02/2025 TO REDUCE COSTS ###
# resource "b2_bucket" "earles_backup" {
#   bucket_name = "earles-backup"
#   bucket_type = "allPrivate"
#   default_server_side_encryption {
#     algorithm = "AES256"
#     mode      = "SSE-B2"
#   }
# }

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
  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
  # Add-on artifacts and world transfers are kept; replaced or hidden versions go after 30 days.
  lifecycle_rules {
    file_name_prefix              = "addons/"
    days_from_uploading_to_hiding = null
    days_from_hiding_to_deleting  = 30
  }
  # Nightly world backups: hidden after 30 days, deleted 7 days later.
  lifecycle_rules {
    file_name_prefix              = "backups/"
    days_from_uploading_to_hiding = 30
    days_from_hiding_to_deleting  = 7
  }
  lifecycle_rules {
    file_name_prefix              = "worlds/"
    days_from_uploading_to_hiding = null
    days_from_hiding_to_deleting  = 30
  }
}

resource "b2_bucket" "earles-public" {
  bucket_name = "earles-public"
  bucket_type = "allPublic"
}

resource "b2_bucket" "earles-vw-backup" {
  bucket_name = "earles-vw-backup"
  bucket_type = "allPrivate"
  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
  lifecycle_rules {
    days_from_hiding_to_deleting = 60
    days_from_uploading_to_hiding = null
    file_name_prefix = ""
  }
  file_lock_configuration {
    is_file_lock_enabled = false
  }
}

resource "b2_bucket" "earles-health" {
  bucket_name = "earles-health"
  bucket_type = "allPrivate"
  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }
}
