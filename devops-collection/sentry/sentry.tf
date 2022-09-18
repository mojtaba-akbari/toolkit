resource "helm_release" "sentry" {
  name = "sentry"
  chart = "sentry/sentry"
  version = "12.0.0"
  namespace = "sentry"
  create_namespace = true
  wait = "false"
  depends_on = [null_resource.sentry_community]
  values = [<<EOF

prefix:

user:
  create: true
  email: admin@zooket.ir
  password: Z00ket@k0rg4x

# this is required on the first installation, as sentry has to be initialized first
# recommended to set false for updating the helm chart afterwards,
# as you will have some downtime on each update if it's a hook
# deploys relay & snuba consumers as post hooks
asHook: true

images:
  sentry:
    # repository: getsentry/sentry
    # tag: Chart.AppVersion
    # pullPolicy: IfNotPresent
    imagePullSecrets: []
  snuba:
    # repository: getsentry/snuba
    # tag: Chart.AppVersion
    # pullPolicy: IfNotPresent
    imagePullSecrets: []
  relay:
    # repository: getsentry/relay
    # tag: Chart.AppVersion
    # pullPolicy: IfNotPresent
    imagePullSecrets: []
  symbolicator:
    # repository: getsentry/symbolicator
    tag: 0.3.4
    # pullPolicy: IfNotPresent
    imagePullSecrets: []

serviceAccount:
  # serviceAccount.annotations -- Additional Service Account annotations.
  annotations: {}
  # serviceAccount.enabled -- If `true`, a custom Service Account will be used.
  enabled: false
  # serviceAccount.name -- The base name of the ServiceAccount to use. Will be appended with e.g. `snuba-api` or `web` for the pods accordingly.
  name: "sentry"
  # serviceAccount.automountServiceAccountToken -- Automount API credentials for a Service Account.
  automountServiceAccountToken: true

relay:
  replicas: 1
  mode: managed
  env: []
  probeFailureThreshold: 5
  probeInitialDelaySeconds: 10
  probePeriodSeconds: 10
  probeSuccessThreshold: 1
  probeTimeoutSeconds: 2
  resources: {}
  affinity: {}
  nodeSelector: {}
  securityContext: {}
  # tolerations: []
  # podLabels: []

  autoscaling:
    enabled: false
    minReplicas: 1
    maxReplicas: 1
    targetCPUUtilizationPercentage: 50
  sidecars: [ ]
  volumes: [ ]

sentry:
  singleOrganization: true
  web:
    # if using filestore backend filesystem with RWO access, set strategyType to Recreate
    strategyType: RollingUpdate
    replicas: 1
    env: []
    probeFailureThreshold: 5
    probeInitialDelaySeconds: 10
    probePeriodSeconds: 10
    probeSuccessThreshold: 1
    probeTimeoutSeconds: 2
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    # Mount and use custom CA
    # customCA:
    #   secretName: custom-ca
    #   item: ca.crt

    autoscaling:
      enabled: false
      minReplicas: 1
      maxReplicas: 1
      targetCPUUtilizationPercentage: 50
    sidecars: [ ]
    volumes: [ ]

  features:
    orgSubdomains: false
    vstsLimitedScopes: true

  worker:
    replicas: 1
    # concurrency: 4
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    # tolerations: []
    # podLabels: []

    # it's better to use prometheus adapter and scale based on
    # the size of the rabbitmq queue
    autoscaling:
      enabled: false
      minReplicas: 1
      maxReplicas: 1
      targetCPUUtilizationPercentage: 50
    livenessProbe:
      enabled: false
      periodSeconds: 60
      timeoutSeconds: 10
      failureThreshold: 3
    sidecars: [ ]
    volumes: [ ]

  ingestConsumer:
    replicas: 1
    # concurrency: 4
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    # maxBatchSize: ""

    # it's better to use prometheus adapter and scale based on
    # the size of the rabbitmq queue
    autoscaling:
      enabled: false
      minReplicas: 1
      maxReplicas: 1
      targetCPUUtilizationPercentage: 50
    sidecars: [ ]
    volumes: [ ]

    # volumeMounts:
    #   - mountPath: /dev/shm
    #     name: dshm

  cron:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    # tolerations: []
    # podLabels: []
    sidecars: [ ]
    volumes: [ ]
  subscriptionConsumerEvents:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    # commitBatchSize: 1
    sidecars: [ ]
    volumes: [ ]
  subscriptionConsumerTransactions:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    # commitBatchSize: 1
    sidecars: [ ]
    volumes: [ ]
  postProcessForward:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    # commitBatchSize: 1
    sidecars: [ ]
    volumes: [ ]
  cleanup:
    enabled: true
    schedule: "0 0 * * *"
    days: 90
    sidecars: []
    volumes: []

snuba:
  api:
    replicas: 1
    env: []
    probeInitialDelaySeconds: 10
    liveness:
      timeoutSeconds: 2
    readiness:
      timeoutSeconds: 2
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []

    autoscaling:
      enabled: false
      minReplicas: 1
      maxReplicas: 1
      targetCPUUtilizationPercentage: 50
    sidecars: [ ]
    volumes: [ ]

  consumer:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    autoOffsetReset: "earliest"
    # maxBatchSize: ""
    # processes: ""
    # inputBlockSize: ""
    # outputBlockSize: ""
    # maxBatchTimeMs: ""
    # queuedMaxMessagesKbytes: ""
    # queuedMinMessages: ""

    # volumeMounts:
    #   - mountPath: /dev/shm
    #     name: dshm
    # volumes:
    #   - name: dshm
    #     emptyDir:
    #       medium: Memory

  outcomesConsumer:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    autoOffsetReset: "earliest"
    maxBatchSize: "3"
    # processes: ""
    # inputBlockSize: ""
    # outputBlockSize: ""
    # maxBatchTimeMs: ""
    # queuedMaxMessagesKbytes: ""
    # queuedMinMessages: ""

    # volumeMounts:
    #   - mountPath: /dev/shm
    #     name: dshm
    # volumes:
    #   - name: dshm
    #     emptyDir:
    #       medium: Memory

  replacer:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    autoOffsetReset: "earliest"
    maxBatchSize: "3"
    # maxBatchTimeMs: ""
    # queuedMaxMessagesKbytes: ""
    # queuedMinMessages: ""

  subscriptionConsumerEvents:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    autoOffsetReset: "earliest"

  subscriptionConsumerTransactions:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    autoOffsetReset: "earliest"

  sessionsConsumer:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    autoOffsetReset: "earliest"
    # maxBatchSize: ""
    # processes: ""
    # inputBlockSize: ""
    # outputBlockSize: ""
    # maxBatchTimeMs: ""
    # queuedMaxMessagesKbytes: ""
    # queuedMinMessages: ""

    # volumeMounts:
    #   - mountPath: /dev/shm
    #     name: dshm
    # volumes:
    #   - name: dshm
    #     emptyDir:
    #       medium: Memory

  transactionsConsumer:
    replicas: 1
    env: []
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    autoOffsetReset: "earliest"
    # maxBatchSize: ""
    # processes: ""
    # inputBlockSize: ""
    # outputBlockSize: ""
    # maxBatchTimeMs: ""
    # queuedMaxMessagesKbytes: ""
    # queuedMinMessages: ""

    # volumeMounts:
    #   - mountPath: /dev/shm
    #     name: dshm
    # volumes:
    #   - name: dshm
    #     emptyDir:
    #       medium: Memory

  dbInitJob:
    env: []

  migrateJob:
    env: []

  cleanupErrors:
    enabled: true
    schedule: "0 * * * *"
    sidecars: []
    volumes: []

  cleanupTransactions:
    enabled: true
    schedule: "0 * * * *"
    sidecars: []
    volumes: []

hooks:
  enabled: true
  removeOnSuccess: true
  clickhouseInit:
    podAnnotations: {}
    affinity: {}
    nodeSelector: {}
    # tolerations: []
  dbCheck:
    image:
      # repository: subfuzion/netcat
      # tag: latest
      # pullPolicy: IfNotPresent
      imagePullSecrets: []
    env: []
    podAnnotations: {}
    resources:
      limits:
        memory: 64Mi
      requests:
        cpu: 100m
        memory: 64Mi
    affinity: {}
    nodeSelector: {}
    # tolerations: []
  dbInit:
    env: []
    podAnnotations: {}
    resources:
      limits:
        memory: 2048Mi
      requests:
        cpu: 300m
        memory: 2048Mi
    sidecars: [ ]
    volumes: [ ]
    affinity: {}
    nodeSelector: {}
    # tolerations: []
  snubaInit:
    podAnnotations: {}
    resources:
      limits:
        cpu: 2000m
        memory: 1Gi
      requests:
        cpu: 700m
        memory: 1Gi
    affinity: {}
    nodeSelector: {}
    # tolerations: []

system:
  ## be sure to include the scheme on the url, for example: "https://sentry.example.com"
  url: ""
  adminEmail: "admin@zooket.ir"
  ## This should only be used if you’re installing Sentry behind your company’s firewall.
  public: false
  ## This will generate one for you (it's must be given upon updates)
  #secretKey: "xx"

mail:
  backend: dummy # smtp
  useTls: true
  username: "devops@zooket.ir"
  password: "KF3A7GP7XUwtA7jGue"
  port: 587
  host: "smtp.zoho.com"
  from: "devops@zooket.ir"

symbolicator:
  enabled: false
  api:
    replicas: 1
    env: []
    probeInitialDelaySeconds: 10
    resources: {}
    affinity: {}
    nodeSelector: {}
    securityContext: {}
    # tolerations: []
    # podLabels: []
    # priorityClassName: "xxx"
    config: |-
      # See: https://getsentry.github.io/symbolicator/#configuration
      cache_dir: "/data"
      bind: "0.0.0.0:3021"
      logging:
        level: "warn"
      metrics:
        statsd: null
        prefix: "symbolicator"
      sentry_dsn: null
      connect_to_reserved_ips: true
      # caches:
      #   downloaded:
      #     max_unused_for: 1w
      #     retry_misses_after: 5m
      #     retry_malformed_after: 5m
      #   derived:
      #     max_unused_for: 1w
      #     retry_misses_after: 5m
      #     retry_malformed_after: 5m
      #   diagnostics:
      #     retention: 1w
    # TODO autoscaling in not yet implemented
    autoscaling:
      enabled: false
      minReplicas: 1
      maxReplicas: 1
      targetCPUUtilizationPercentage: 50
  # TODO The cleanup cronjob is not yet implemented
  cleanup:
    enabled: false
    # podLabels: []
    # affinity: {}
    # env: []

auth:
  register: true

service:
  name: sentry
  type: NodePort
  externalPort: 9000
  nodePort: 30618
  annotations: {}
  # externalIPs:
  # - 192.168.0.1
  # loadBalancerSourceRanges: []

github: {} # https://github.com/settings/apps (Create a Github App)
# github:
#   appId: "xxxx"
#   appName: MyAppName
#   clientId: "xxxxx"
#   clientSecret: "xxxxx"
#   privateKey: "-----BEGIN RSA PRIVATE KEY-----\nMIIEpA" !!!! Don't forget a trailing \n
#   webhookSecret:  "xxxxx`"

google: {} # https://developers.google.com/identity/sign-in/web/server-side-flow#step_1_create_a_client_id_and_client_secret
# google:
#   clientId:
#   clientSecret:

slack: {}
# slack:
#   clientId:
#   clientSecret:
#   signingSecret:
#   Reference -> https://develop.sentry.dev/integrations/slack/

nginx:
  enabled: true
  containerPort: 8080
  existingServerBlockConfigmap: '{{ template "sentry.fullname" . }}'
  resources: {}
  replicaCount: 1
  service:
    type: ClusterIP
    port: 80
  ## Use this to enable an extra service account
  # serviceAccount:
  #   create: false
  #   name: nginx

ingress:
  enabled: true
  # If you are using traefik ingress controller, switch this to 'traefik'
  # if you are using AWS ALB Ingress controller, switch this to 'aws-alb'
  # if you are using GKE Ingress controller, switch this to 'gke'
  regexPathStyle: traefik
  #If you are using AWS ALB Ingress controller, switch to true if you want activate the http to https redirection.
  alb:
    httpRedirect: false
  annotations:
  #   If you are using nginx ingress controller, please use at least those 2 annotations
    kubernetes.io/ingress.class: traefik
  #   nginx.ingress.kubernetes.io/use-regex: "true"
  #
  hostname: sentry.snappxtage.ir
  # additionalHostNames: []
  #
  # tls:
  # - secretName:
  #   hosts:

filestore:
  # Set to one of filesystem, gcs or s3 as supported by Sentry.
  backend: filesystem

  filesystem:
    path: /var/lib/sentry/files

    ## Enable persistence using Persistent Volume Claims
    ## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
    ##
    persistence:
      enabled: true
      ## database data Persistent Volume Storage Class
      ## If defined, storageClassName: <storageClass>
      ## If set to "-", storageClassName: "", which disables dynamic provisioning
      ## If undefined (the default) or set to null, no storageClassName spec is
      ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
      ##   GKE, AWS & OpenStack)
      ##
      storageClass: "devspace-local-storage35"
      accessMode: ReadWriteOnce
      size: 20Gi

      ## Whether to mount the persistent volume to the Sentry worker and
      ## cron deployments. This setting needs to be enabled for some advanced
      ## Sentry features, such as private source maps. If you disable this
      ## setting, the Sentry workers will not have access to artifacts you upload
      ## through the web deployment.
      ## Please note that you may need to change your accessMode to ReadWriteMany
      ## if you plan on having the web, worker and cron deployments run on
      ## different nodes.
      persistentWorkers: false

  gcs: {}
    ## Point this at a pre-configured secret containing a service account. The resulting
    ## secret will be mounted at /var/run/secrets/google
    # secretName:
    # credentialsFile: credentials.json
    # bucketName:

  ## Currently unconfigured and changing this has no impact on the template configuration.
  s3: {}
  #  accessKey:
  #  secretKey:
  #  bucketName:
  #  endpointUrl:
  #  signature_version:
  #  region_name:
  #  default_acl:

config:
  # No YAML Extension Config Given
  configYml: {}
  sentryConfPy: |
    # No Python Extension Config Given
  snubaSettingsPy: |
    # No Python Extension Config Given
  relay: |
    # No YAML relay config given
clickhouse:
  enabled: true
  clickhouse:
    replicas: 1
    imageVersion: "20.8.9.6"
    configmap:
      remote_servers:
        internal_replication: false
        replica:
          backup:
            enabled: false
      users:
        enabled: false
        user:
        # the first user will be used if enabled
        - name: default
          config:
            password: ""
            networks:
            - ::/0
            profile: default
            quota: default

    persistentVolumeClaim:
      enabled: true
      dataPersistentVolume:
        enabled: true
        accessModes:
        - "ReadWriteOnce"
        storageClassName: "devspace-local-storage42"
        storage: "20Gi"

  ## Use this to enable an extra service account
  # serviceAccount:
  #   annotations: {}
  #   enabled: false
  #   name: "sentry-clickhouse"
  #   automountServiceAccountToken: true

## This value is only used when clickhouse.enabled is set to false
##
externalClickhouse:
  ## Hostname or ip address of external clickhouse
  ##
  host: "clickhouse"
  tcpPort: 9000
  httpPort: 8123
  username: default
  password: ""
  database: default
  ## Cluster name, can be found in config
  ## (https://clickhouse.tech/docs/en/operations/server-configuration-parameters/settings/#server-settings-remote-servers)
  ## or by executing `select * from system.clusters`
  ##
  # clusterName: test_shard_localhost

# Settings for Kafka.
# See https://github.com/bitnami/charts/tree/master/bitnami/kafka
kafka:
  enabled: true
  persistence:
    enabled: true
    storageClass: "devspace-local-storage37"
  replicaCount: 1
  allowPlaintextListener: true
  defaultReplicationFactor: 1
  offsetsTopicReplicationFactor: 1
  transactionStateLogReplicationFactor: 1
  transactionStateLogMinIsr: 1
  # 50 MB
  maxMessageBytes: "50000000"
  # 50 MB
  socketRequestMaxBytes: "50000000"

  service:
    port: 9092

  ## Use this to enable an extra service account
  # serviceAccount:
  #   create: false
  #   name: kafka

  ## Use this to enable an extra service account
  zookeeper:
    persistence:
      enabled: true
      storageClass: "devspace-local-storage36"

  #   serviceAccount:
  #     create: false
  #     name: zookeeper

## This value is only used when kafka.enabled is set to false
##
externalKafka:
  ## Hostname or ip address of external kafka
  ##
  # host: "kafka-confluent"
  port: 9092

redis:
  enabled: true
  auth:
    enabled: false
    sentinel: false
  nameOverride: sentry-redis
  usePassword: false
  ## Just omit the password field if your redis cluster doesn't use password
  # password: redis
  master:
    persistence:
      enabled: true
      storageClass: "devspace-local-storage40"
  replica:
    persistence:
      enabled: true
      storageClass: "devspace-local-storage41"

  ## Use this to enable an extra service account
  # serviceAccount:
  #   create: false
  #   name: sentry-redis

## This value is only used when redis.enabled is set to false
##
externalRedis:
  ## Hostname or ip address of external redis cluster
  ##
  # host: "redis"
  port: 6379
  ## Just omit the password field if your redis cluster doesn't use password
  # password: redis

postgresql:
  enabled: true
  nameOverride: sentry-postgresql

  #postgresqlUsername: zooket
  
  postgresqlPostgresPassword: zooket
  postgresqlPassword: zooket
  
  postgresqlDatabase: sentry

  initdbUser: postgres
  initdbPassword: zooket

  global:
    storageClass: "devspace-local-storage39"
  replication:
    enabled: false
    readReplicas: 1
    synchronousCommit: "on"
    numSynchronousReplicas: 1
    applicationName: sentry
  ## Use this to enable an extra service account
  # serviceAccount:
  #   enabled: false

## This value is only used when postgresql.enabled is set to false
##
externalPostgresql:
  # host: postgres
  port: 5432
  username: postgres
  password: zooket
  database: sentry
  # sslMode: require

rabbitmq:
  ## If disabled, Redis will be used instead as the broker.
  enabled: true
  global:
    storageClass: "devspace-local-storage38"
  clustering:
    forceBoot: true
    rebalance: true
  replicaCount: 1
  auth:
    erlangCookie: pHgpy3Q6adTskzAT6bLHCFqFTF7lMxhA
    username: guest
    password: guest
  nameOverride: ""

  pdb:
    create: false
  persistence:
    enabled: true
  resources: {}
  memoryHighWatermark: {}
    # enabled: true
    # type: relative
    # value: 0.4

  extraSecrets:
    load-definition:
      load_definition.json: |
        {
          "users": [
            {
              "name": "{{ .Values.auth.username }}",
              "password": "{{ .Values.auth.password }}",
              "tags": "administrator"
            }
          ],
          "permissions": [{
            "user": "{{ .Values.auth.username }}",
            "vhost": "/",
            "configure": ".*",
            "write": ".*",
            "read": ".*"
          }],
          "policies": [
            {
              "name": "ha-all",
              "pattern": ".*",
              "vhost": "/",
              "definition": {
                "ha-mode": "all",
                "ha-sync-mode": "automatic",
                "ha-sync-batch-size": 1
              }
            }
          ],
          "vhosts": [
            {
              "name": "/"
            }
          ]
        }
  loadDefinition:
    enabled: true
    existingSecret: load-definition
  extraConfiguration: |
    load_definitions = /app/load_definition.json
  ## Use this to enable an extra service account
  # serviceAccount:
  #   create: false
  #   name: rabbitmq

## Prometheus Exporter / Metrics
##
metrics:
  enabled: false

  ## Configure extra options for liveness and readiness probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes)
  livenessProbe:
    enabled: true
    initialDelaySeconds: 30
    periodSeconds: 5
    timeoutSeconds: 2
    failureThreshold: 3
    successThreshold: 1
  readinessProbe:
    enabled: true
    initialDelaySeconds: 30
    periodSeconds: 5
    timeoutSeconds: 2
    failureThreshold: 3
    successThreshold: 1

  ## Metrics exporter resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  resources: {}
  #   limits:
  #     cpu: 100m
  #     memory: 100Mi
  #   requests:
  #     cpu: 100m
  #     memory: 100Mi

  nodeSelector: {}
  tolerations: []
  affinity: {}
  securityContext: {}
  # schedulerName:
  # Optional extra labels for pod, i.e. redis-client: "true"
  # podLabels: []
  service:
    type: ClusterIP
    labels: {}

  image:
    repository: prom/statsd-exporter
    tag: v0.17.0
    pullPolicy: IfNotPresent

  # Enable this if you're using https://github.com/coreos/prometheus-operator
  serviceMonitor:
    enabled: false
    additionalLabels: {}
    namespace: ""
    namespaceSelector: {}
    # Default: scrape .Release.Namespace only
    # To scrape all, use the following:
    # namespaceSelector:
    #   any: true
    scrapeInterval: 30s
    # honorLabels: true

revisionHistoryLimit: 10

# dnsPolicy: "ClusterFirst"
# dnsConfig:
#   nameservers: []
#   searches: []
#   options: []


  EOF
]
}