locals {
  permissions = {
    in_account = [
      "compute.instances.create",
      "compute.instances.delete",
      "compute.instances.attachDisk",
      "compute.instances.detachDisk",
      "compute.instances.setDiskAutoDelete",
      "compute.instances.setMetadata",
      "compute.instances.stop",
      "compute.networks.create",
      "compute.networks.delete",
      "compute.networks.updatePolicy",
      "compute.subnetworks.create",
      "compute.subnetworks.delete",
      "compute.routers.create",
      "compute.routers.delete",
      "compute.routers.update",
      "compute.firewalls.create",
      "compute.firewalls.delete",
      "compute.disks.update",
      "compute.disks.create",
      "compute.disks.delete",
      "compute.disks.setLabels",
      "compute.disks.use",
      "compute.subnetworks.use",
      "compute.instances.setTags",
      "compute.instances.setServiceAccount"
    ]
    in_account_multiple = [
      "compute.snapshots.setLabels",
      "compute.disks.createSnapshot",
      "compute.snapshots.create",
      "compute.snapshots.delete",
      "storage.buckets.getIamPolicy",
      "storage.objects.get",
      "cloudsql.backupRuns.create",
      "cloudsql.backupRuns.delete"
    ]
    dspm_scanner_role = [
      "cloudsql.backupRuns.create",
      "cloudsql.backupRuns.delete"
    ]
  }

  apis_to_enable = {
    default = [
      "dns.googleapis.com",
      "apikeys.googleapis.com",
      "cloudkms.googleapis.com",
      "cloudasset.googleapis.com",
      "compute.googleapis.com",
      "container.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "sqladmin.googleapis.com",
      "iam.googleapis.com"
    ]
    multiple = [
      "dns.googleapis.com",
      "apikeys.googleapis.com",
      "cloudkms.googleapis.com",
      "cloudasset.googleapis.com",
      "compute.googleapis.com",
      "container.googleapis.com",
      "cloudresourcemanager.googleapis.com",
      "sqladmin.googleapis.com",
      "iam.googleapis.com"
    ]
    dspm = [
      "servicenetworking.googleapis.com"
    ]
  }

  roles = {
    in_account = [
      "${var.scanner_project_id}=>projects/${var.scanner_project_id}/roles/${google_project_iam_custom_role.this.role_id}",
      "${var.scanner_project_id}=>roles/viewer",
      "${var.scanner_project_id}=>roles/iam.serviceAccountUser"
    ]
    in_account_target = var.multiple == true ? [] : [
      "projects/${var.target_project_id}/roles/${var.target_account_role}",
      "roles/viewer",
      "roles/storage.objectViewer",
      "roles/iam.securityReviewer"
    ]
  }

  dspm = {
    target = var.multiple || !var.enable_dspm ? [] : [
      "projects/${var.target_project_id}/roles/${google_project_iam_custom_role.dspm_scanner_role[0].role_id}",
    ]
    scanner = [
      "roles/cloudsql.admin",
      "roles/servicenetworking.networksAdmin",
      "roles/iam.serviceAccountUser",
      "roles/compute.networkAdmin"
    ]
  }

  _permissions    = local.permissions.in_account
  _roles          = local.roles.in_account_target
  _apis_to_enable = concat(var.multiple ? local.apis_to_enable.multiple : local.apis_to_enable.default, var.enable_dspm ? local.apis_to_enable.dspm : [])
}
