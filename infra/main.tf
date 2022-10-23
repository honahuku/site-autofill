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

variable "project_id" {
  default = "site-autofill"
}

variable "repo_name" {
  default = "honahuku/site-autofill"
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

# CIで利用するSA
resource "google_service_account" "github-actions-sa" {
  project      = var.project_id
  account_id   = "github-actions"
  display_name = "github actions"
  description  = "link to Workload Identity Pool used by github actions"
}

resource "google_project_service" "project" {
  project = var.project_id
  service = "iamcredentials.googleapis.com"
}

# GitHub Actions OIDC用のpool
resource "google_iam_workload_identity_pool" "github-actions-pool" {
  provider                  = google-beta
  project                   = var.project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "github-actions-pool"
  description               = "for github actions"
}

# GitHub Actions OIDC用のprovider
resource "google_iam_workload_identity_pool_provider" "github-actions-provider" {
  provider                           = google-beta
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github-actions-pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "github-actions-provider"
  description                        = "OIDC identity pool provider for execute github actions"
  # See. https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#understanding-the-oidc-token
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.owner"      = "assertion.repository_owner"
    "attribute.refs"       = "assertion.ref"
  }
  # Option: 特定のリポジトリオーナーのみトークン交換を許可
  attribute_condition = "attribute.owner=={honahuku}"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# WorkloadIdentityPoolへにSAへの権限借用を許可
resource "google_service_account_iam_member" "github_actions" {
  service_account_id = google_service_account.github-actions-sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github-actions-pool.name}/attribute.repository/${repo_name}"
}

output "service_account_github_actions_email" {
  description = "Actionsで使用するサービスアカウント"
  value       = google_service_account.github-actions-sa.email
}

output "google_iam_workload_identity_pool_provider_github_name" {
  description = "Workload Identity Pood Provider ID"
  value       = google_iam_workload_identity_pool_provider.github-actions-provider.name
}