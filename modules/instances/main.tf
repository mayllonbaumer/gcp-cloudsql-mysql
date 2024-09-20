locals{
  user_ip_map = { for user in var.users : user.user => user.ip }
}

resource "google_sql_database_instance" "mysql_instance" {
  name             = var.name
  database_version = "MYSQL_8_0"
  region           = var.region
  deletion_protection = false 
  settings {
    tier = var.tier

    backup_configuration {
      enabled = false
    }

    ip_configuration {
      ipv4_enabled = true

    dynamic "authorized_networks" {
        for_each = var.users

        content {
          name  = "network-${authorized_networks.value.user}"
          value = authorized_networks.value.ip
        }
      }
    }
  }

  # Assign root password for MySQL
  root_password = random_string.root_password.result
}

resource "random_string" "root_password" {
  length = 16
  special = true
}

resource "google_secret_manager_secret" "root_secret" {
  secret_id = "password-root"
  replication {
    user_managed {
      replicas {
        location = var.location
      }
    }
  }
}

resource "google_secret_manager_secret_version" "root_secret_version" {
  secret  = google_secret_manager_secret.root_secret.id
  secret_data = random_string.root_password.result
}

resource "google_sql_database" "developer_schema" {
  for_each = local.user_ip_map
  name      = "${each.key}_schema"
  instance  = google_sql_database_instance.mysql_instance.name
}

resource "google_sql_user" "developer_user" {
  for_each = local.user_ip_map
  name     = each.key
  instance = google_sql_database_instance.mysql_instance.name
  password = random_string.user_password[each.key].result
}

resource "random_string" "user_password" {
  for_each = local.user_ip_map
  length = 16
  special = true
}

resource "google_secret_manager_secret" "user_secret" {
  for_each = local.user_ip_map
  secret_id = "password-${each.key}"
  replication {
    user_managed {
      replicas {
        location = var.location
      }
    }
  }
}

resource "google_secret_manager_secret_version" "user_secret_version" {
  for_each = local.user_ip_map
  secret  = google_secret_manager_secret.user_secret[each.key].id
  secret_data = random_string.user_password[each.key].result
}