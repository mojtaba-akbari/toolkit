terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/181/terraform/state/redis-cluster"
    lock_address   = "https://git.zooket.ir/api/v4/projects/181/terraform/state/redis-cluster/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/181/terraform/state/redis-cluster/lock"
    username       = "kubadmin"
    password       = "kYn6bDCBDchGfeczNrrD"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}