terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/233/terraform/state/elk-prod-hist-kibana"
    lock_address   = "https://git.zooket.ir/api/v4/projects/233/terraform/state/elk-prod-hist-kibana/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/233/terraform/state/elk-prod-hist-kibana/lock"
    username       = "kubadmin"
    password       = "8y1BCFP59p4xSW7JNmGy"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
