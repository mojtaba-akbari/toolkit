
resource "null_resource" "prometheus_community" {
   triggers = { ts = "${timestamp()}" }
   provisioner "local-exec" {
     command = "helm repo add prometheus-community https://prometheus-community.github.io/helm-charts"
   }
 }
