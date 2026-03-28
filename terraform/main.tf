terraform {
  required_version = ">= 1.0"

  backend "local" {} # Change to "gcs" or "s3" if you want remote state

  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  # credentials = file(var.credentials) # Only if you don't want to set GOOGLE_APPLICATION_CREDENTIALS
}

locals {
  # Prefix for naming resources
  data_lake_bucket_prefix = "data-lake"
}

# -----------------------------
# Data Lake Bucket
# -----------------------------
resource "google_storage_bucket" "data_lake" {
  name     = "${local.data_lake_bucket_prefix}-${var.project}"
  location = var.region

  storage_class               = var.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  # Lifecycle rule: optional age for cleanup
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 # Optional: Remove objects older than 30 days to reduce storage costs
    }
  }

  # Allows Terraform to destroy bucket even if it contains objects
  force_destroy = true
}

# -----------------------------
# BigQuery Dataset
# -----------------------------
resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.BQ_DATASET
  project    = var.project
  location   = var.region

  # Optional: allow easy deletion of dataset with Terraform
  deletion_protection = false
}
