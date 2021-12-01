

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

resource "aws_efs_access_point" "couchdb_data" {
  file_system_id = aws_efs_file_system.couchdb_data.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/bitnami/couchdb"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
}

resource "aws_efs_mount_target" "couchdb_data" {
  for_each = data.aws_subnet.main_public

  file_system_id  = aws_efs_file_system.couchdb_data.id
  subnet_id       = each.value.id
  security_groups = [aws_security_group.couchdb_efs_data.id]
}

# TODO aws_efs_backup_policy
# TODO aws_efs_file_system_policy
