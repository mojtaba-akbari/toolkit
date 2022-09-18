resource "null_resource" "kong_community" {
   triggers = { ts = "${timestamp()}" }
   provisioner "local-exec" {
     command = "helm repo add proxysql https://flachesis.github.io/proxysql"
   }
 }
