

resource "aws_efs_file_system" "couchdb_data" {
  encrypted = true
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

  tags = {
    Name = "CouchDB_Data"
  }

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}

# TODO aws_efs_backup_policy
# TODO aws_efs_file_system_policy
# TODO aws_efs_mount_target
# TODO security group
