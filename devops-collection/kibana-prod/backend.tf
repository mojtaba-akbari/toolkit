terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/111/terraform/state/kibana-prod"
    lock_address   = "https://git.zooket.ir/api/v4/projects/111/terraform/state/kibana-prod/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/111/terraform/state/kibana-prod/lock"
    username       = "kubadmin"
    password       = "L_Gxar5113kA5yDNT6fD"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
