resource "helm_release" "proxysql" {
  name             = "proxysql"
  chart            = "proxysql/proxysql"
  version          = "1.5.0"
  namespace        = "proxy-gateway"
  create_namespace = true
  wait             = "false"
  depends_on       = [null_resource.kong_community]
  values = [<<EOF

#https://artifacthub.io/packages/helm/proxysql-cluster/proxysql

replicaCount: 1

image:
  repository: proxysql/proxysql
  tag: 2.3.0
  pullPolicy: IfNotPresent

imagePullSecrets: []
nameOverride: ""

fullnameOverride: ""

service:
  type: NodePort
  port: 443
  nodePort: 30543


proxysql:
    admin:
        user: admin
        password: admin
    port: 6032
    cluster:
        enabled: true
        user: cluster
        password: cluster
        claim:
            enabled: true
            accessModes: [ "ReadWriteOnce" ]
            storageClassName: "hiops"
            size: 20G
    web:
        user: sadmin
        pass: sadmin
    mysql:
        version:    5.7.34
        queryRetriesOnFailure: 2
        readWriteSplit: true
    servers:
        - hostname: 10.0.0.189

ingress:
  enabled: false
  annotations: {}
    # kubernetes.io/ingress.class: proxysql
    # kubernetes.io/tls-acme: "true"
  hosts:
    - host: 10.18.120.41
      paths: []

  tls: []
  #  - secretName: chart-example-tls
  #    hosts:
  #      - chart-example.local

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 1024Mi
  # requests:
  #   cpu: 100m
  #   memory: 1024Mi

nodeSelector:
    node-role.kubernetes.io/worker: "worker2"

tolerations: []

affinity: {}

EOF

  ]
}
