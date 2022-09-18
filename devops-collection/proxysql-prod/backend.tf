terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/179/terraform/state/proxysql"
    lock_address   = "https://git.zooket.ir/api/v4/projects/179/terraform/state/proxysql/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/179/terraform/state/proxysql/lock"
    username       = "kubadmin"
    password       = "AtFfBe6CknJBcy5xWgH9"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
