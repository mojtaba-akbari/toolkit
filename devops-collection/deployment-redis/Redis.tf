resource "helm_release" "redis" {
  name             = "redis"
  chart            = "bitnami/redis"
  version          = "14.8.7"
  namespace        = "vendor-auth"
  create_namespace = true
  wait             = "false"
  depends_on       = [null_resource.redis_community]
  values = [<<EOF
global:
  imageRegistry: ""
  imagePullSecrets: []
  storageClass: "devspace-local-storage3"
  redis:
    password: "zooket"
architecture: standalone
auth:
  enabled: false
  sentinel: false
  password: ""
  existingSecret: ""
  existingSecretPasswordKey: ""
  usePasswordFiles: false
persistence:
  enabled: true
  path: /opt/bitnami/rabbitmq/var/lib/redis
  subPath: ""
  storageClass: "devspace-local-storage3"
  accessModes:
  - ReadWriteOnce
  size: 8Gi
  annotations: {}
  selector: {}
  existingClaim: "devspace-local-storage3-test"
service:
  type: NodePort
  port: 6379
  nodePort: 30012
  externalTrafficPolicy: Cluster
  #clusterIP: ""
  loadBalancerIP: ""
  loadBalancerSourceRanges: []
  annotations: {}
terminationGracePeriodSeconds: 30
replica:
  replicaCount: 0
  configuration: ""
  disableCommands:
    - FLUSHDB
    - FLUSHALL
  service:
    ## @param replica.service.type Redis&trade; replicas service type
    ##
    type: NodePort
    ## @param replica.service.port Redis&trade; replicas service port
    ##
    port: 6379
    ## @param replica.service.nodePort Node port for Redis&trade; replicas
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
    ## NOTE: choose port between <30000-32767>
    ##
    nodePort: "300014"
    ## @param replica.service.externalTrafficPolicy Redis&trade; replicas service external traffic policy
    ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    ##
    externalTrafficPolicy: Cluster
    ## @param replica.service.clusterIP Redis&trade; replicas service Cluster IP
    ##
    #clusterIP: ""
    ## @param replica.service.loadBalancerIP Redis&trade; replicas service Load Balancer IP
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    loadBalancerIP: ""
    ## @param replica.service.loadBalancerSourceRanges Redis&trade; replicas service Load Balancer sources
    ## https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
    ## e.g.
    ## loadBalancerSourceRanges:
    ##   - 10.10.10.0/24
    ##
    loadBalancerSourceRanges: []
    ## @param replica.service.annotations Additional custom annotations for Redis&trade; replicas service
    ##
    annotations: {}
serviceAccount:
  ## Specifies whether a ServiceAccount should be created
  ##
  create: true
  ## The name of the ServiceAccount to use.
  ## If not 
   EOF
  ]
}