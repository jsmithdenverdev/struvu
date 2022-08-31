resource "google_storage_bucket" "input_bucket" {
  name     = "${var.project}-input"
  location = var.region
}