#Redis helm repo config
resource "null_resource" "redis_community" {
  triggers = { ts = "${timestamp()}" }
  provisioner "local-exec" {
    command = "helm repo add bitnami https://charts.bitnami.com/bitnami"
  }
}