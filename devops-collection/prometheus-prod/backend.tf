terraform {
  backend "http" {
    address        = "https://git.zooket.ir/api/v4/projects/110/terraform/state/prometheus-prod"
    lock_address   = "https://git.zooket.ir/api/v4/projects/110/terraform/state/prometheus-prod/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/110/terraform/state/prometheus-prod/lock"
    username       = "kubadmin"
    password       = "bxFqtV71XatRyEKyz-cd"
    lock_method    = "POST"
    unlock_method  = "DELETE"
    retry_wait_min = 5
  }
}
