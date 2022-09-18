
resource "null_resource" "traefik_community" {
   triggers = { ts = "${timestamp()}" }
   provisioner "local-exec" {
     command = "helm repo add traefik https://helm.traefik.io/traefik"
   }
 }
