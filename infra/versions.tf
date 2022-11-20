terraform {
  cloud {
    organization = "honahuku"

    workspaces {
      name = "site-autofill"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.41.0"
    }
  }
    required_version = ">= 1.3.3"
}
