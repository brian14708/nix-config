resource "google_storage_bucket" "ops_state" {
  name     = "ops-state"
  location = "us-west1"

  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true
}

#resource "google_cloud_run_service" "example" {
#  name     = "example"
#  location = "asia-east1"
#
#  template {
#    spec {
#      containers {
#        image = "nginx:latest"
#        ports {
#          name           = "http1"
#          container_port = 80
#        }
#      }
#    }
#  }
#
#  traffic {
#    percent         = 100
#    latest_revision = true
#  }
#}
#
#data "google_iam_policy" "noauth" {
#  binding {
#    role = "roles/run.invoker"
#    members = [
#      "allUsers",
#    ]
#  }
#}
#
#resource "google_cloud_run_service_iam_policy" "noauth" {
#  location = google_cloud_run_service.example.location
#  project  = google_cloud_run_service.example.project
#  service  = google_cloud_run_service.example.name
#
#  policy_data = data.google_iam_policy.noauth.policy_data
#}
#
#
#resource "google_cloud_run_domain_mapping" "example" {
#  location = google_cloud_run_service.example.location
#  name     = "example.brian14708.dev"
#
#  metadata {
#    namespace = google_cloud_run_service.example.project
#  }
#
#  spec {
#    route_name = google_cloud_run_service.example.name
#  }
#}
#
#resource "cloudflare_record" "example" {
#  zone_id = data.sops_file.vars.data["cloudflare_zone_id"]
#  name    = google_cloud_run_domain_mapping.example.status[0].resource_records[0].name
#  content = google_cloud_run_domain_mapping.example.status[0].resource_records[0].rrdata
#  type    = google_cloud_run_domain_mapping.example.status[0].resource_records[0].type
#}
