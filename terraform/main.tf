terraform {
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
  }
}

variable "b2_application_key_id" {}
variable "b2_application_key" {}

provider "b2" {
  application_key_id = var.b2_application_key_id
  application_key    = var.b2_application_key
}

resource "b2_bucket" "earles_backup" {
  bucket_name = "earles_backup"
  bucket_type = "allPrivate"
}
