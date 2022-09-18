provider "kubernetes" {
  version        = "~> 1.13.3"
  config_context = var.kubectl_config_context_name
  config_path    = var.kubectl_config_path
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
