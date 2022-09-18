 terraform {
  backend "kubernetes" {
     secret_suffix    = "kubernetes"
    load_config_file = true
   }
 }