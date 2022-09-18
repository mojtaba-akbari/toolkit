resource "helm_release" "rabbitmq" {
  name             = "rabbitmq"
  chart            = "bitnami/rabbitmq"
  version          = "8.19.1"
  namespace        = "vendor-auth"
  create_namespace = true
  wait             = "false"
  depends_on       = [null_resource.rabbitmq_community]
  values = [<<EOF
auth:
  ## @param auth.username RabbitMQ application username
  ## ref: https://github.com/bitnami/bitnami-docker-rabbitmq#environment-variables
  ##
  username: zooket

  ## @param auth.password RabbitMQ application password
  ## ref: https://github.com/bitnami/bitnami-docker-rabbitmq#environment-variables
  ##
  password: "zooket"
service:
  ## @param service.type Kubernetes Service type
  ##
  type: NodePort
  ## @param service.port Amqp port
  ## ref: https://github.com/bitnami/bitnami-docker-rabbitmq#environment-variables
  ##
  port: 5672

  ## @param service.portName Amqp service port name
  ##
  portName: amqp

  ## @param service.tlsPort Amqp TLS port
  ##
  tlsPort: 5671

  ## @param service.tlsPortName Amqp TLS service port name
  ##
  tlsPortName: amqp-ssl

  ## @param service.nodePort Node port override for `amqp` port, if serviceType is `NodePort` or `LoadBalancer`
  ## ref: https://github.com/bitnami/bitnami-docker-rabbitmq#environment-variables
  ## e.g:
  ## nodePort: 30672
  ##
  nodePort: "30672"

  ## @param service.tlsNodePort Node port override for `amqp-ssl` port, if serviceType is `NodePort` or `LoadBalancer`
  ## e.g:
  ## tlsNodePort: 30671
  ##
  tlsNodePort: ""

  ## @param service.distPort Erlang distribution server port
  ## ref: https://github.com/bitnami/bitnami-docker-rabbitmq#environment-variables
  ##
  distPort: 25672

  ## @param service.distPortName Erlang distribution service port name
  ##
  distPortName: dist

  ## @param service.distNodePort Node port override for `dist` port, if serviceType is `NodePort`
  ## e.g:
  ## distNodePort: 30676
  ##
  distNodePort: ""

  ## @param service.managerPortEnabled RabbitMQ Manager port
  ## ref: https://github.com/bitnami/bitnami-docker-rabbitmq#environment-variables
  ##
  managerPortEnabled: true

  ## @param service.managerPort RabbitMQ Manager port
  ##
  managerPort: 15672

  ## @param service.managerPortName RabbitMQ Manager service port name
  ##
  managerPortName: http-stats

  ## @param service.managerNodePort Node port override for `http-stats` port, if serviceType `NodePort`
  ## e.g:
  ## managerNodePort: 30673
  ##
  managerNodePort: "30005"

  ## @param service.metricsPort RabbitMQ Prometheues metrics port
  ##
  metricsPort: 9419

  ## @param service.metricsPortName RabbitMQ Prometheues metrics service port name
  ##
  metricsPortName: metrics

  ## @param service.metricsNodePort Node port override for `metrics` port, if serviceType is `NodePort`
  ## e.g:
  ## metricsNodePort: 30674
  ##
  metricsNodePort: ""

  ## @param service.epmdNodePort Node port override for `epmd` port, if serviceType is `NodePort`
  ## e.g:
  ## epmdNodePort: 30675
  ##
  epmdNodePort: ""

  ## @param service.epmdPortName EPMD Discovery service port name
  ##
  epmdPortName: epmd

  ## @param service.extraPorts Extra ports to expose in the service
  ## E.g.:
  ## extraPorts:
  ## - name: new_svc_name
  ##   port: 1234
  ##   targetPort: 1234
  ##
  extraPorts: []

  ## @param service.loadBalancerSourceRanges Address(es) that are allowed when service is `LoadBalancer`
  ## https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
  ## e.g:
  ## loadBalancerSourceRanges:
  ## - 10.10.10.0/24
  ##
  loadBalancerSourceRanges: []

  ## @param service.externalIPs Set the ExternalIPs
  ##
  externalIPs: []

  ## @param service.externalTrafficPolicy Enable client source IP preservation
  ## ref http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
  ##
  externalTrafficPolicy: Cluster

  ## @param service.loadBalancerIP Set the LoadBalancerIP
  ##
  loadBalancerIP: ""

  ## @param service.labels Service labels. Evaluated as a template
  ##
  labels: {}

  ## @param service.annotations Service annotations. Evaluated as a template
  ## Example:
  ## annotations:
  ##   service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0
  ##
  annotations: {}
  ## @param service.annotationsHeadless Headless Service annotations. Evaluated as a template
  ## Example:
  ## annotations:
  ##   external-dns.alpha.kubernetes.io/internal-hostname: rabbitmq.example.com
  ##
  annotationsHeadless: {}

## Configure the ingress resource that allows you to access the
## RabbitMQ installation. Set up the URL
## ref: http://kubernetes.io/docs/user-guide/ingress/
##
persistence:
  ## this enables PVC templates that will create one per pod
  enabled: true

  ## rabbitmq data Persistent Volume Storage Class
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
  ##   GKE, AWS & OpenStack)
  ##
  storageClass: "devspace-local-storage"
  accessMode: ReadWriteOnce

  ## Existing PersistentVolumeClaims
  ## The value is evaluated as a template
  ## So, for example, the name can depend on .Release or .Chart
  existingClaim: ""

  # If you change this value, you might have to adjust `rabbitmq.diskFreeLimit` as well.
  size: 1Gi

  # persistence directory, maps to the rabbitmq data directory
  path: /opt/bitnami/rabbitmq/var/lib/rabbitmq

## Configure resource requests and limits
## ref: http://kubernetes.io/docs/user-guide/compute-resources/
##
 EOF
  ]
}