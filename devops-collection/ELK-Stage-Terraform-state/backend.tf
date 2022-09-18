terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/170/terraform/state/elk-stage"
    lock_address   = "https://git.zooket.ir/api/v4/projects/170/terraform/state/elk-stage/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/170/terraform/state/elk-stage/lock"
    username       = "kubadmin"
    password       = "6Gn9zn8PxqVKz_q2u9kE"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
