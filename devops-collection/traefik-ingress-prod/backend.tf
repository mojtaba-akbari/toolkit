terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/166/terraform/state/traefik-prod"
    lock_address   = "https://git.zooket.ir/api/v4/projects/166/terraform/state/traefik-prod/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/166/terraform/state/traefik-prod/lock"
    username       = "kubadmin"
    password       = "bfQgNSzcsV2o6RmxjyHe"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
