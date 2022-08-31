provider "google" {
  project = var.project
  region  = var.region
}

module "file_info" {
  source               = "./modules/function"
  project              = var.project
  region               = var.region
  function_name        = "file-info"
  function_entry_point = "fileInfo"
  event_trigger = {
    event_type = "google.cloud.storage.object.v1.finalized"
    event_filters = {
      attribute = "bucket"
      value     = google_storage_bucket.input_bucket.name
    }
  }
}