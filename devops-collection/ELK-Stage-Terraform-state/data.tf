
resource "null_resource" "elasticsearch_community" {
  triggers = { ts = "${timestamp()}" }
  provisioner "local-exec" {
    command = "helm repo add bitnami https://charts.bitnami.com/bitnami"
  }
}
