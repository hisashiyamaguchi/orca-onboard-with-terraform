locals {
  orca_production_project_number = "788120191304"

  permissions = {
    saas = [
      "compute.snapshots.setLabels",
      "compute.disks.createSnapshot",
      "compute.snapshots.create",
      "compute.snapshots.delete",
      "storage.buckets.getIamPolicy",
      "storage.objects.get",
      "compute.snapshots.setIamPolicy",
      "compute.snapshots.useReadOnly",
    ]
    saas_multiple = [
      "compute.snapshots.setLabels",
      "compute.disks.createSnapshot",
      "compute.snapshots.create",
      "compute.snapshots.delete",
      "storage.buckets.getIamPolicy",
      "storage.objects.get",
      "compute.snapshots.setIamPolicy",
      "compute.snapshots.useReadOnly",
      "serviceusage.services.enable",
      "servicemanagement.services.bind",
      "resourcemanager.folders.list"
    ]
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
    ]
    in_account_target = [
      "compute.snapshots.setLabels",
      "compute.disks.createSnapshot",
      "compute.snapshots.create",
      "compute.snapshots.delete",
      "storage.buckets.getIamPolicy",
      "storage.objects.get",
    ]
    in_account_target_multiple = [
      "compute.snapshots.setLabels",
      "compute.disks.createSnapshot",
      "compute.snapshots.create",
      "compute.snapshots.delete",
      "storage.buckets.getIamPolicy",
      "storage.objects.get",
      "serviceusage.services.enable",
      "servicemanagement.services.bind",
      "resourcemanager.folders.list"
    ]
    dspm_scanner_role = [
      "cloudsql.backupRuns.create",
      "cloudsql.backupRuns.delete"
    ]
    dspm_backup_role = [
      "cloudsql.backupRuns.get"
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
      "cloudresourcemanager.googleapis.com",
      "serviceusage.googleapis.com"
    ]
  }

  roles = {
    saas = var.multiple || var.in_account ? [] : [
      "${var.target_project_id}=>projects/${var.target_project_id}/roles/${google_project_iam_custom_role.this[0].role_id}",
      "${var.target_project_id}=>roles/viewer",
      "${var.target_project_id}=>roles/storage.objectViewer",
      "${var.target_project_id}=>roles/iam.securityReviewer"
    ]
    saas_multiple = var.multiple == false ? [] : [
      "organizations/${var.organization_id}/roles/${google_organization_iam_custom_role.this[0].role_id}",
      "roles/viewer",
      "roles/storage.objectViewer",
      "roles/iam.securityReviewer",
    ]
    in_account_multiple = var.multiple == false || var.in_account == false ? [] : [
      "organizations/${var.organization_id}/roles/${google_organization_iam_custom_role.this[0].role_id}",
      "roles/viewer",
      "roles/storage.objectViewer",
      "roles/iam.securityReviewer"
    ]
  }

  dspm = {
    default = var.multiple || var.in_account || !var.enable_dspm ? [] : [
      "${var.target_project_id}=>projects/${var.target_project_id}/roles/${google_project_iam_custom_role.dspm_scanner_role[0].role_id}"
    ]
    default_multiple = !var.multiple || !var.enable_dspm ? [] : [
      "organizations/${var.organization_id}/roles/${google_organization_iam_custom_role.dspm[0].role_id}"
    ]
  }

  orca_production_sa = "serviceAccount:orca-scan-account@production-252018.iam.gserviceaccount.com"

  _permissions    = ((var.multiple && var.in_account) ? local.permissions.in_account_target_multiple : (var.multiple ? local.permissions.saas_multiple : (var.in_account ? local.permissions.in_account_target : local.permissions.saas)))
  _roles          = (var.multiple && var.in_account) ? local.roles.in_account_multiple : (var.multiple ? local.roles.saas_multiple : local.roles.saas)
  _apis_to_enable = (!var.multiple ? local.apis_to_enable.default : !var.in_account ? local.apis_to_enable.multiple : [])
  _dspm           = (var.enable_dspm ? (var.multiple ? local.dspm.default_multiple : local.dspm.default) : [])
}
