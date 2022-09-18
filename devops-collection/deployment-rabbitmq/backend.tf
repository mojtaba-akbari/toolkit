 terraform {
  backend "kubernetes" {
     secret_suffix    = "rabbitmq"
    load_config_file = true
   }
 }
