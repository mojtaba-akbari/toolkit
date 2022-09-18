 terraform {
  backend "kubernetes" {
     secret_suffix    = "elk"
    load_config_file = true
   }
 }
