#Redis helm repo config
resource "null_resource" "sentry_community" {
    triggers = { ts = "${timestamp()}" }
    provisioner "local-exec" {
    command = "helm repo add sentry https://sentry-kubernetes.github.io/charts"
  }
}
