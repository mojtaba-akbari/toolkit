
resource "null_resource" "fluent_community" {
   triggers = { ts = "${timestamp()}" }
   provisioner "local-exec" {
     command = "helm repo add fluent https://fluent.github.io/helm-charts"
   }
 }
