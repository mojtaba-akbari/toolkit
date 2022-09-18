
resource "null_resource" "couchdb_community" {
  triggers = { ts = "${timestamp()}" }
  provisioner "local-exec" {
    command = "helm repo add kasten https://charts.kasten.io/kasten"
  }
}
