locals {
  instances = yamldecode(file("${path.module}/settings/instances.yaml"))
}

module "instances" {
  for_each = { for instance in local.instances.instances : instance.name => instance }

  source = "./modules/instances"

  name     = each.value.name
  tier     = each.value.tier
  users    = each.value.users
  location = var.location

  region     = var.region
  project_id = var.project_id
}
