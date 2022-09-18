terraform {
  backend "http" {
    address = "https://git.zooket.ir/api/v4/projects/165/terraform/state/sentry"
    lock_address = "https://git.zooket.ir/api/v4/projects/165/terraform/state/sentry/lock"
    unlock_address = "https://git.zooket.ir/api/v4/projects/165/terraform/state/sentry/lock"
    username = "kubadmin"
    password = "fhr4tCnvjxPYDz-tfp2j"
    lock_method = "POST"
    unlock_method = "DELETE"
    retry_wait_min = 5
  }
}