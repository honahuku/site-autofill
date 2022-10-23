provider "google" {
  credentials = file("account.json")
  project     = "site-autofill"
  region      = "asia-northeast1"
}

terraform {
  required_version = "1.3.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.41.0"
    }
  }
  backend "gcs" {
    bucket = "hoahuku-tf-bucket"
  }
}

resource "google_project" "site-autofill" {
  name       = "site-autofill"
  labels     = {}
  project_id = "site-autofill"
}

resource "google_storage_bucket" "tf-bucket" {
  name     = "hoahuku-tf-bucket"
  location = "asia-northeast1"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}
