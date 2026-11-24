terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

variable "project_id" {
  description = "GCP project ID where the monitoring resources are created."
  type        = string
}

variable "alert_email" {
  description = "Email address that receives CPU alerts."
  type        = string
}

resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "Operations email"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

resource "google_monitoring_alert_policy" "high_vm_cpu" {
  project               = var.project_id
  display_name          = "VM CPU above 75%"
  combiner              = "OR"
  notification_channels = [google_monitoring_notification_channel.email.name]

  conditions {
    display_name = "VM CPU above 75% for 5 minutes"

    condition_threshold {
      filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.75
      duration        = "300s"
    }
  }
}
