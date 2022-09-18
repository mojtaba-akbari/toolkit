terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/182/terraform/state/haproxy"
    lock_address   = "https://git.zooket.ir/api/v4/projects/182/terraform/state/haproxy/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/182/terraform/state/haproxy/lock"
    username       = "kubadmin"
    password       = "y73yBzTsfzvST1GypKnj"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
