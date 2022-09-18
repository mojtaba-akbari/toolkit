#mysql helm repo config
resource "null_resource" "kibana_community" {
   triggers = { ts = "${timestamp()}" }
   provisioner "local-exec" {
     command = "helm repo add bitnami https://charts.bitnami.com/bitnami"
   }
 }
