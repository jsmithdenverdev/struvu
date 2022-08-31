terraform {
    experiments = [module_variable_optional_attrs]
}

locals {
  timestamp = formatdate("YYMMDDhhmmss", timestamp())
	root_dir = abspath("../dist")
}

# Compress source code
data "archive_file" "source" {
  type        = "zip"
  source_dir  = local.root_dir
  output_path = "/tmp/function-${var.function_name}-${local.timestamp}.zip"
}

# Create bucket that will host the source code
resource "google_storage_bucket" "bucket" {
  name      = "${var.project}-function"
  location  = var.region
}

# Add source code zip to bucket
resource "google_storage_bucket_object" "zip" {
  # Append file MD5 to force bucket to be recreated
  name   = "source.zip#${data.archive_file.source.output_md5}"
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.source.output_path
}

# Enable Cloud Functions API
resource "google_project_service" "cf" {
  project = var.project
  service = "cloudfunctions.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Enable Cloud Build API
resource "google_project_service" "cb" {
  project = var.project
  service = "cloudbuild.googleapis.com"

  disable_dependent_services = true
  disable_on_destroy         = false
}

# Create Cloud Function
resource "google_cloudfunctions2_function" "function" {
  name    = var.function_name
  location = var.region

  build_config {
    runtime = "nodejs16" # Switch to a different runtime if needed
    entry_point           = var.function_entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.zip.name
      }
    }
  }

  // TODO: move this into a variable named service_config (see below for example)
  service_config {
    available_memory   = "128Mi"
  }

  event_trigger {
    trigger = var.event_trigger.trigger
    trigger_region = var.event_trigger.trigger_region
    event_type      = var.event_trigger.event_type
    pubsub_topic = var.event_trigger.pubsub_topic
    service_account_email = var.event_trigger.service_account_email
    retry_policy  = var.event_trigger.retry_policy 
    event_filters {
      attribute = var.event_trigger.event_filters.attribute
      value = var.event_trigger.event_filters.value
    }
  }
}

# Create IAM entry so all users can invoke the function
resource "google_cloudfunctions2_function_iam_member" "invoker" {
  project        = google_cloudfunctions2_function.function.project
  location         = google_cloudfunctions2_function.function.location
  cloud_function = google_cloudfunctions2_function.function.name
  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}