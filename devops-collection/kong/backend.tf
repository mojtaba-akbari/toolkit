terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/159/terraform/state/kong"
    lock_address   = "https://git.zooket.ir/api/v4/projects/159/terraform/state/kong/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/159/terraform/state/kong/lock"
    username       = "kubadmin"
    password       = "seey7sTzATARUFJEYh4b"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
