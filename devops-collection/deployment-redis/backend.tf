 terraform {
  backend "kubernetes" {
     secret_suffix    = "redis"
    load_config_file = true
   }
 }
