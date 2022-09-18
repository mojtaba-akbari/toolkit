terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/234/terraform/state/kasten"
    lock_address   = "https://git.zooket.ir/api/v4/projects/234/terraform/state/kasten/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/234/terraform/state/kasten/lock"
    username       = "kubadmin"
    password       = "9-EhPvkPsAfnNG94RnH4"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
