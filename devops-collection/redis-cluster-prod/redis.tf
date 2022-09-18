resource "helm_release" "redis" {
  name             = "redis"
  chart            = "bitnami/redis-cluster"
  version          = "7.0.9"
  namespace        = "redis-cluster"
  create_namespace = true
  wait             = "false"
  depends_on       = [null_resource.redis_community]
  values = [<<EOF
## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass

## @param global.imageRegistry Global Docker image registry
## @param global.imagePullSecrets Global Docker registry secret names as an array
## @param global.storageClass Global StorageClass for Persistent Volume(s)
## @param global.redis.password Redis&trade; password (overrides `password`)
##
global:
  imageRegistry: ""
  ## E.g.
  ## imagePullSecrets:
  ##   - myRegistryKeySecretName
  ##
  imagePullSecrets: []
  storageClass: ""
  redis:
    password: ""

## @section Redis&trade; Cluster Common parameters

## @param nameOverride String to partially override common.names.fullname template (will maintain the release name)
##
nameOverride: ""
## @param fullnameOverride String to fully override common.names.fullname template
##
fullnameOverride: ""
## @param commonAnnotations Annotations to add to all deployed objects
##
commonAnnotations: {}
## @param commonLabels Labels to add to all deployed objects
##
commonLabels: {}
## @param extraDeploy Array of extra objects to deploy with the release (evaluated as a template)
##
extraDeploy: []

## Enable diagnostic mode in the deployment
##
diagnosticMode:
  ## @param diagnosticMode.enabled Enable diagnostic mode (all probes will be disabled and the command will be overridden)
  ##
  enabled: false
  ## @param diagnosticMode.command Command to override all containers in the deployment
  ##
  command:
    - sleep
  ## @param diagnosticMode.args Args to override all containers in the deployment
  ##
  args:
    - infinity

## @section Redis&trade; Cluster Common parameters

## Bitnami Redis&trade; image version
## ref: https://hub.docker.com/r/bitnami/redis/tags/
## @param image.registry Redis&trade; cluster image registry
## @param image.repository Redis&trade; cluster image repository
## @param image.tag Redis&trade; cluster image tag (immutable tags are recommended)
## @param image.pullPolicy Redis&trade; cluster image pull policy
## @param image.pullSecrets Specify docker-registry secret names as an array
## @param image.debug Enable image debug mode
##
image:
  registry: docker.io
  repository: bitnami/redis-cluster
  ## Bitnami Redis&trade; image tag
  ## ref: https://github.com/bitnami/bitnami-docker-redis#supported-tags-and-respective-dockerfile-links
  ##
  tag: 6.2.6-debian-10-r21
  ## Specify a imagePullPolicy
  ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
  ## ref: http://kubernetes.io/docs/user-guide/images/#pre-pulling-images
  ##
  pullPolicy: IfNotPresent
  ## Optionally specify an array of imagePullSecrets.
  ## Secrets must be manually created in the namespace.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ## e.g:
  ## pullSecrets:
  ##   - myRegistryKeySecretName
  ##
  pullSecrets: []
  ## Enable debug mode
  ##
  debug: false
## Network Policy
## @param networkPolicy.enabled Enable NetworkPolicy
## @param networkPolicy.allowExternal The Policy model to apply. Don't require client label for connections
## @param networkPolicy.ingressNSMatchLabels Allow connections from other namespacess. Just set label for namespace and set label for pods (optional).
## @param networkPolicy.ingressNSPodMatchLabels For other namespaces match by pod labels and namespace labels
##
networkPolicy:
  enabled: false
  ## When set to false, only pods with the correct
  ## client label will have network access to the port Redis&trade; is listening
  ## on. When true, Redis&trade; will accept connections from any source
  ## (with the correct destination port).
  ##
  allowExternal: true
  ingressNSMatchLabels: {}
  ingressNSPodMatchLabels: {}

serviceAccount:
  ## @param serviceAccount.create Specifies whether a ServiceAccount should be created
  ##
  create: false
  ## @param serviceAccount.name The name of the ServiceAccount to create
  ## If not set and create is true, a name is generated using the fullname template
  ##
  name: ""
  ## @param serviceAccount.annotations Annotations for Cassandra Service Account
  ##
  annotations: {}
  ## @param serviceAccount.automountServiceAccountToken Automount API credentials for a service account.
  ##
  automountServiceAccountToken: false

rbac:
  ## @param rbac.create Specifies whether RBAC resources should be created
  ##
  create: false
  role:
    ## @param rbac.role.rules Rules to create. It follows the role specification
    ## rules:
    ##  - apiGroups:
    ##    - extensions
    ##    resources:
    ##      - podsecuritypolicies
    ##    verbs:
    ##      - use
    ##    resourceNames:
    ##      - gce.unprivileged
    ##
    rules: []
## Redis&trade; pod Security Context
## @param podSecurityContext.enabled Enable Redis&trade; pod Security Context
## @param podSecurityContext.fsGroup Group ID for the pods
## @param podSecurityContext.runAsUser User ID for the pods
## @param podSecurityContext.sysctls Set namespaced sysctls for the pods
##
podSecurityContext:
  enabled: true
  fsGroup: 1001
  runAsUser: 1001
  ## Uncomment the setting below to increase the net.core.somaxconn value
  ## e.g:
  ## sysctls:
  ##   - name: net.core.somaxconn
  ##     value: "10000"
  ##
  sysctls: []
## @param podDisruptionBudget Limits the number of pods of the replicated application that are down simultaneously from voluntary disruptions
## ref: https://kubernetes.io/docs/concepts/workloads/pods/disruptions
##
podDisruptionBudget: {}
## @param minAvailable Min number of pods that must still be available after the eviction
##
minAvailable: ""
## @param maxUnavailable Max number of pods that can be unavailable after the eviction
##
maxUnavailable: ""
## Containers Security Context
## @param containerSecurityContext.enabled Enable Containers' Security Context
## @param containerSecurityContext.runAsUser User ID for the containers.
## @param containerSecurityContext.runAsNonRoot Run container as non root
##
containerSecurityContext:
  enabled: true
  runAsUser: 1001
  runAsNonRoot: true
## @param usePassword Use password authentication
##
usePassword: false
## @param password Redis&trade; password (ignored if existingSecret set)
## Defaults to a random 10-character alphanumeric string if not set and usePassword is true
## ref: https://github.com/bitnami/bitnami-docker-redis#setting-the-server-password-on-first-run
##
password: ""
## @param existingSecret Name of existing secret object (for password authentication)
##
existingSecret: ""
## @param existingSecretPasswordKey Name of key containing password to be retrieved from the existing secret
##
existingSecretPasswordKey: ""
## @param usePasswordFile Mount passwords as files instead of environment variables
##
usePasswordFile: false
##
## TLS configuration
##
tls:
  ## @param tls.enabled Enable TLS support for replication traffic
  ##
  enabled: false
  ## @param tls.authClients Require clients to authenticate or not
  ##
  authClients: true
  ## @param tls.autoGenerated Generate automatically self-signed TLS certificates
  ##
  autoGenerated: false
  ## @param tls.existingSecret The name of the existing secret that contains the TLS certificates
  ##
  existingSecret: ""
  ## @param tls.certificatesSecret DEPRECATED. Use tls.existingSecret instead
  ##
  certificatesSecret: ""
  ## @param tls.certFilename Certificate filename
  ##
  certFilename: ""
  ## @param tls.certKeyFilename Certificate key filename
  ##
  certKeyFilename: ""
  ## @param tls.certCAFilename CA Certificate filename
  ##
  certCAFilename: ""
  ## @param tls.dhParamsFilename File containing DH params (in order to support DH based ciphers)
  ##
  dhParamsFilename: ""
## Redis&trade; Service properties for standalone mode.
##
service:
  ## @param service.ports.redis Kubernetes Redis service port
  ##
  ports:
    redis: 6379
  ## Node ports to expose
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
  ## @param service.nodePorts.redis Node port for Redis
  ##
  nodePorts:
    redis: ""
  ## @param service.extraPorts Extra ports to expose in the service (normally used with the `sidecar` value)
  ##
  extraPorts: []
  ## @param service.annotations Provide any additional annotations which may be required.
  ## This can be used to set the LoadBalancer service type to internal only.
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
  ##
  annotations: {}
  ## @param service.labels Additional labels for redis service
  ##
  labels: {}
  ## @param service.type Service type for default redis service
  ## Setting this to LoadBalancer may require corresponding service annotations for loadbalancer creation to succeed.
  ## Currently supported types are ClusterIP (default) and LoadBalancer
  ##
  type: ClusterIP
  ## @param service.clusterIP Service Cluster IP
  ## e.g.:
  ## clusterIP: None
  ##
  clusterIP: ""
  ## @param service.loadBalancerIP Load balancer IP if `service.type` is `LoadBalancer`
  ## If service.type is LoadBalancer, request a specific static IP address if supported by the cloud provider, otherwise leave blank
  loadBalancerIP: ""
  ## @param service.loadBalancerSourceRanges Service Load Balancer sources
  ## ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/#restrict-access-for-loadbalancer-service
  ## e.g:
  ## loadBalancerSourceRanges:
  ##   - 10.10.10.0/24
  ##
  loadBalancerSourceRanges: []
  ## @param service.externalTrafficPolicy Service external traffic policy
  ## ref http://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
  ##
  externalTrafficPolicy: Cluster
## Enable persistence using Persistent Volume Claims
## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
##
persistence:
  ## @param persistence.enabled Use a PVC to persist data.
  ##
  enabled: true
  ## @param persistence.path Path to mount the volume at, to use other images Redis&trade; images.
  ##
  path: /bitnami/redis/data
  ## @param persistence.subPath The subdirectory of the volume to mount to, useful in dev environments and one PV for multiple services
  ##
  subPath: ""
  ## @param persistence.storageClass Storage class of backing PVC
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
  ##   GKE, AWS & OpenStack)
  ##
  storageClass: "hiops"
  ## @param persistence.annotations Persistent Volume Claim annotations
  ##
  annotations: {}
  ## @param persistence.accessModes Persistent Volume Access Modes
  ##
  accessModes:
    - ReadWriteOnce
  ## @param persistence.size Size of data volume
  ##
  size: 30Gi
  ## @param persistence.matchLabels Persistent Volume selectors
  ## https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector
  ##
  matchLabels: {}
  ## @param persistence.matchExpressions matchExpressions Persistent Volume selectors
  ##
  matchExpressions: {}

## Init containers parameters:
## volumePermissions: Change the owner of the persist volume mountpoint to RunAsUser:fsGroup
##
volumePermissions:
  ## @param volumePermissions.enabled Enable init container that changes volume permissions in the registry (for cases where the default k8s `runAsUser` and `fsUser` values do not work)
  ##
  enabled: false
  ## @param volumePermissions.image.registry Init container volume-permissions image registry
  ## @param volumePermissions.image.repository Init container volume-permissions image repository
  ## @param volumePermissions.image.tag Init container volume-permissions image tag
  ## @param volumePermissions.image.pullPolicy Init container volume-permissions image pull policy
  ## @param volumePermissions.image.pullSecrets Specify docker-registry secret names as an array
  ##
  image:
    registry: docker.io
    repository: bitnami/bitnami-shell
    tag: 10-debian-10-r233
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## Container resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## @param volumePermissions.resources.limits The resources limits for the container
  ## @param volumePermissions.resources.requests The requested resources for the container
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 100m
    ##    memory: 128Mi
    limits: {}
    ## Examples:
    ## requests:
    ##    cpu: 100m
    ##    memory: 128Mi
    requests: {}
## PodSecurityPolicy configuration
## ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/
## @param podSecurityPolicy.create Whether to create a PodSecurityPolicy. WARNING: PodSecurityPolicy is deprecated in Kubernetes v1.21 or later, unavailable in v1.25 or later
##
podSecurityPolicy:
  create: false

## @section Redis&trade; statefulset parameters

redis:
  ## @param redis.command Redis&trade; entrypoint string. The command `redis-server` is executed if this is not provided
  ##
  command: []
  ## @param redis.args Arguments for the provided command if needed
  ##
  args: []
  ## @param redis.updateStrategy.type Argo Workflows statefulset strategy type
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ##
  updateStrategy:
    ## StrategyType
    ## Can be set to RollingUpdate or OnDelete
    ##
    type: RollingUpdate
    ## @param redis.updateStrategy.rollingUpdate.partition Partition update strategy
    ## https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#partitions
    ##
    rollingUpdate:
      partition: 0

  ## @param redis.podManagementPolicy Statefulset Pod management policy, it needs to be Parallel to be able to complete the cluster join
  ## Ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#pod-management-policies
  ##
  podManagementPolicy: Parallel
  ## @param redis.hostAliases Deployment pod host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param redis.useAOFPersistence Whether to use AOF Persistence mode or not
  ## It is strongly recommended to use this type when dealing with clusters
  ## ref: https://redis.io/topics/persistence#append-only-file
  ## ref: https://redis.io/topics/cluster-tutorial#creating-and-using-a-redis-cluster
  ##
  useAOFPersistence: "yes"
  ## @param redis.containerPorts.redis Redis&trade; port
  ## @param redis.containerPorts.bus The busPort should be obtained adding 10000 to the redisPort. By default: 10000 + 6379 = 16379
  ##
  containerPorts:
    redis: 6379
    bus: 16379
  ## @param redis.lifecycleHooks LifecycleHook to set additional configuration before or after startup. Evaluated as a template
  ##
  lifecycleHooks: {}
  ## @param redis.extraVolumes Extra volumes to add to the deployment
  ##
  extraVolumes: []
  ## @param redis.extraVolumeMounts Extra volume mounts to add to the container
  ##
  extraVolumeMounts: []
  ## @param redis.customLivenessProbe Override default liveness probe
  ##
  customLivenessProbe: {}
  ## @param redis.customReadinessProbe Override default readiness probe
  ##
  customReadinessProbe: {}
  ## @param redis.customStartupProbe Custom startupProbe that overrides the default one
  ##
  customStartupProbe: {}
  ## @param redis.initContainers Extra init containers to add to the deployment
  ##
  initContainers: []
  ## @param redis.sidecars Extra sidecar containers to add to the deployment
  ##
  sidecars: []
  ## @param redis.podLabels Additional labels for Redis&trade; pod
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param redis.priorityClassName Redis&trade; Master pod priorityClassName
  ##
  priorityClassName: ""
  ## @param redis.configmap Additional Redis&trade; configuration for the nodes
  ## ref: https://redis.io/topics/config
  ##
  configmap: ""
  ## @param redis.extraEnvVars An array to add extra environment variables
  ## For example:
  ##  - name: BEARER_AUTH
  ##    value: true
  ##
  extraEnvVars: []
  ## @param redis.extraEnvVarsCM ConfigMap with extra environment variables
  ##
  extraEnvVarsCM: ""
  ## @param redis.extraEnvVarsSecret Secret with extra environment variables
  ##
  extraEnvVarsSecret: ""
  ## @param redis.podAnnotations Redis&trade; additional annotations
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podAnnotations: {}
  ## Redis&trade; resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## @param redis.resources.limits The resources limits for the container
  ## @param redis.resources.requests The requested resources for the container
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 100m
    ##    memory: 128Mi
    limits: {}
    ## Examples:
    ## requests:
    ##    cpu: 100m
    ##    memory: 128Mi
    requests: {}
  ## @param redis.schedulerName Use an alternate scheduler, e.g. "stork".
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param redis.shareProcessNamespace Enable shared process namespace in a pod.
  ## If set to false (default), each container will run in separate namespace, redis will have PID=1.
  ## If set to true, the /pause will run as init process and will reap any zombie PIDs,
  ## for example, generated by a custom exec probe running longer than a probe timeoutSeconds.
  ## Enable this only if customLivenessProbe or customReadinessProbe is used and zombie PIDs are accumulating.
  ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/share-process-namespace/
  ##
  shareProcessNamespace: false
  ## Configure extra options for Redis&trade; liveness probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes)
  ## @param redis.livenessProbe.enabled Enable livenessProbe
  ## @param redis.livenessProbe.initialDelaySeconds Initial delay seconds for livenessProbe
  ## @param redis.livenessProbe.periodSeconds Period seconds for livenessProbe
  ## @param redis.livenessProbe.timeoutSeconds Timeout seconds for livenessProbe
  ## @param redis.livenessProbe.failureThreshold Failure threshold for livenessProbe
  ## @param redis.livenessProbe.successThreshold Success threshold for livenessProbe
  ##
  livenessProbe:
    enabled: false
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Configure extra options for Redis&trade; readiness probes
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/#configure-probes)
  ## @param redis.readinessProbe.enabled Enable readinessProbe
  ## @param redis.readinessProbe.initialDelaySeconds Initial delay seconds for readinessProbe
  ## @param redis.readinessProbe.periodSeconds Period seconds for readinessProbe
  ## @param redis.readinessProbe.timeoutSeconds Timeout seconds for readinessProbe
  ## @param redis.readinessProbe.failureThreshold Failure threshold for readinessProbe
  ## @param redis.readinessProbe.successThreshold Success threshold for readinessProbe
  ##
  readinessProbe:
    enabled: false
    initialDelaySeconds: 5
    periodSeconds: 5
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 5
  ## @param redis.startupProbe.enabled Enable startupProbe
  ## @param redis.startupProbe.path Path to check for startupProbe
  ## @param redis.startupProbe.initialDelaySeconds Initial delay seconds for startupProbe
  ## @param redis.startupProbe.periodSeconds Period seconds for startupProbe
  ## @param redis.startupProbe.timeoutSeconds Timeout seconds for startupProbe
  ## @param redis.startupProbe.failureThreshold Failure threshold for startupProbe
  ## @param redis.startupProbe.successThreshold Success threshold for startupProbe
  ##
  startupProbe:
    enabled: false
    path: /
    initialDelaySeconds: 300
    periodSeconds: 10
    timeoutSeconds: 5
    failureThreshold: 6
    successThreshold: 1
  ## @param redis.podAffinityPreset Redis&trade; pod affinity preset. Ignored if `redis.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param redis.podAntiAffinityPreset Redis&trade; pod anti-affinity preset. Ignored if `redis.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Redis&trade; node affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param redis.nodeAffinityPreset.type Redis&trade; node affinity preset type. Ignored if `redis.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param redis.nodeAffinityPreset.key Redis&trade; node label key to match Ignored if `redis.affinity` is set.
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## @param redis.nodeAffinityPreset.values Redis&trade; node label values to match. Ignored if `redis.affinity` is set.
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param redis.affinity Affinity settings for Redis&trade; pod assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: redis.podAffinityPreset, redis.podAntiAffinityPreset, and redis.nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param redis.nodeSelector Node labels for Redis&trade; pods assignment
  ## ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param redis.tolerations Tolerations for Redis&trade; pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param redis.topologySpreadConstraints Pod topology spread constraints for Redis&trade; pod
  ## https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
  ## The value is evaluated as a template
  ##
  topologySpreadConstraints: []

## @section Cluster update job parameters

## Cluster update job settings
##
updateJob:
  ## @param updateJob.activeDeadlineSeconds Number of seconds the Job to create the cluster will be waiting for the Nodes to be ready.
  ##
  activeDeadlineSeconds: 600
  ## @param updateJob.command Container command (using container default if not set)
  ##
  command: []
  ## @param updateJob.args Container args (using container default if not set)
  ##
  args: []
  ## @param updateJob.hostAliases Deployment pod host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param updateJob.annotations Job annotations
  ##
  annotations: {}
  ## @param updateJob.podAnnotations Job pod annotations
  ##
  podAnnotations: {}
  ## @param updateJob.podLabels Pod extra labels
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
  ##
  podLabels: {}
  ## @param updateJob.extraEnvVars An array to add extra environment variables
  ## For example:
  ##  - name: BEARER_AUTH
  ##    value: true
  ##
  extraEnvVars: []
  ## @param updateJob.extraEnvVarsCM ConfigMap containing extra environment variables
  ##
  extraEnvVarsCM: ""
  ## @param updateJob.extraEnvVarsSecret Secret containing extra environment variables
  ##
  extraEnvVarsSecret: ""
  ## @param updateJob.extraVolumes Extra volumes to add to the deployment
  ##
  extraVolumes: []
  ## @param updateJob.extraVolumeMounts Extra volume mounts to add to the container
  ##
  extraVolumeMounts: []
  ## @param updateJob.initContainers Extra init containers to add to the deployment
  ##
  initContainers: []
  ## @param updateJob.podAffinityPreset Update job pod affinity preset. Ignored if `updateJob.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param updateJob.podAntiAffinityPreset Update job pod anti-affinity preset. Ignored if `updateJob.affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: soft
  ## Update job node affinity preset
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ##
  nodeAffinityPreset:
    ## @param updateJob.nodeAffinityPreset.type Update job node affinity preset type. Ignored if `updateJob.affinity` is set. Allowed values: `soft` or `hard`
    ##
    type: ""
    ## @param updateJob.nodeAffinityPreset.key Update job node label key to match Ignored if `updateJob.affinity` is set.
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## @param updateJob.nodeAffinityPreset.values Update job node label values to match. Ignored if `updateJob.affinity` is set.
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param updateJob.affinity Affinity for update job pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: updateJob.podAffinityPreset, updateJob.podAntiAffinityPreset, and updateJob.nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param updateJob.nodeSelector Node labels for update job pods assignment
  ## ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param updateJob.tolerations Tolerations for update job pods assignment
  ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param updateJob.priorityClassName Priority class name
  ##
  priorityClassName: ""
  ## Container resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param updateJob.resources.limits The resources limits for the container
  ## @param updateJob.resources.requests The requested resources for the container
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 500m
    ##    memory: 1Gi
    limits: {}
    ## Examples:
    ## requests:
    ##    cpu: 250m
    ##    memory: 256Mi
    requests: {}

## @section Cluster management parameters

## Redis&trade; Cluster settings
##
cluster:
  ## @param cluster.init Enable the initialization of the Redis&trade; Cluster
  ##
  init: true
  ## Number of Redis&trade; nodes to be deployed
  ##
  ## Note:
  ## This is total number of nodes including the replicas. Meaning there will be 3 master and 3 replica
  ## nodes (as replica count is set to 1 by default, there will be 1 replica per master node).
  ## Hence, nodes = numberOfMasterNodes + numberOfMasterNodes * replicas
  ##
  ## @param cluster.nodes The number of master nodes should always be >= 3, otherwise cluster creation will fail
  ##
  nodes: 6
  ## @param cluster.replicas Number of replicas for every master in the cluster
  ## Parameter to be passed as --cluster-replicas to the redis-cli --cluster create
  ## 1 means that we want a replica for every master created
  ##
  replicas: 1
  ## Configuration to access the Redis&trade; Cluster from outside the Kubernetes cluster
  ##
  externalAccess:
    ## @param cluster.externalAccess.enabled Enable access to the Redis
    ##
    enabled: false
    service:
      ## @param cluster.externalAccess.service.type Type for the services used to expose every Pod
      ## At this moment only LoadBalancer is supported
      ##
      type: LoadBalancer
      ## @param cluster.externalAccess.service.port Port for the services used to expose every Pod
      ##
      port: 6379
      ## @param cluster.externalAccess.service.loadBalancerIP Array of load balancer IPs for each Redis&trade; node. Length must be the same as cluster.nodes
      ##
      loadBalancerIP: []
      ## @param cluster.externalAccess.service.annotations Annotations to add to the services used to expose every Pod of the Redis&trade; Cluster
      ##
      annotations: {}
  ## This section allows to update the Redis&trade; cluster nodes.
  ##
  update:
    ## @param cluster.update.addNodes Boolean to specify if you want to add nodes after the upgrade
    ## Setting this to true a hook will add nodes to the Redis&trade; cluster after the upgrade. currentNumberOfNodes is required
    ##
    addNodes: false
    ## @param cluster.update.currentNumberOfNodes Number of currently deployed Redis&trade; nodes
    ##
    currentNumberOfNodes: 6
    ## @param cluster.update.newExternalIPs External IPs obtained from the services for the new nodes to add to the cluster
    ##
    newExternalIPs: []

## @section Metrics sidecar parameters

## Prometheus Exporter / Metrics
##
metrics:
  ## @param metrics.enabled Start a side-car prometheus exporter
  ##
  enabled: false
  ## @param metrics.image.registry Redis&trade; exporter image registry
  ## @param metrics.image.repository Redis&trade; exporter image name
  ## @param metrics.image.tag Redis&trade; exporter image tag
  ## @param metrics.image.pullPolicy Redis&trade; exporter image pull policy
  ## @param metrics.image.pullSecrets Specify docker-registry secret names as an array
  ##
  image:
    registry: docker.io
    repository: bitnami/redis-exporter
    tag: 1.29.0-debian-10-r6
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## @param metrics.resources Metrics exporter resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ##
  resources: {}
  ## @param metrics.extraArgs Extra arguments for the binary; possible values [here](https://github.com/oliver006/redis_exporter
  ## extraArgs:
  ##   check-keys: myKey,myOtherKey
  ##
  extraArgs: {}
  ## @param metrics.podAnnotations [object] Additional annotations for Metrics exporter pod
  ##
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9121"
  ## @param metrics.podLabels Additional labels for Metrics exporter pod
  podLabels: {}
  ## Enable this if you're using https://github.com/coreos/prometheus-operator
  ##
  serviceMonitor:
    ## @param metrics.serviceMonitor.enabled If `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.enabled` to be `true`)
    ##
    enabled: false
    ## @param metrics.serviceMonitor.namespace Optional namespace which Prometheus is running in
    ##
    namespace: ""
    ## @param metrics.serviceMonitor.interval How frequently to scrape metrics (use by default, falling back to Prometheus' default)
    ##
    interval: ""
    ## @param metrics.serviceMonitor.scrapeTimeout Timeout after which the scrape is ended
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#endpoint
    ## e.g:
    ## scrapeTimeout: 10s
    ##
    scrapeTimeout: ""
    ## @param metrics.serviceMonitor.selector Prometheus instance selector labels
    ## ref: https://github.com/bitnami/charts/tree/master/bitnami/prometheus-operator#prometheus-configuration
    ## e.g:
    ## selector:
    ##   prometheus: my-prometheus
    ##
    selector: {}
    ## @param metrics.serviceMonitor.labels ServiceMonitor extra labels
    ##
    labels: {}
    ## @param metrics.serviceMonitor.annotations ServiceMonitor annotations
    ##
    annotations: {}
    ## @param metrics.serviceMonitor.jobLabel The name of the label on the target service to use as the job name in prometheus.
    ##
    jobLabel: ""
    ## @param metrics.serviceMonitor.relabelings RelabelConfigs to apply to samples before scraping
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#relabelconfig
    ##
    relabelings: []
    ## @param metrics.serviceMonitor.metricRelabelings MetricRelabelConfigs to apply to samples before ingestion
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#relabelconfig
    ##
    metricRelabelings: []
  ## Custom PrometheusRule to be defined
  ## The value is evaluated as a template, so, for example, the value can depend on .Release or .Chart
  ## ref: https://github.com/coreos/prometheus-operator#customresourcedefinitions
  ## @param metrics.prometheusRule.enabled Set this to true to create prometheusRules for Prometheus operator
  ## @param metrics.prometheusRule.additionalLabels Additional labels that can be used so prometheusRules will be discovered by Prometheus
  ## @param metrics.prometheusRule.namespace namespace where prometheusRules resource should be created
  ## @param metrics.prometheusRule.rules [rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) to be created, check values for an example.
  ##
  prometheusRule:
    enabled: false
    additionalLabels: {}
    namespace: ""
    ## These are just examples rules, please adapt them to your needs.
    ## Make sure to constraint the rules to the current postgresql service.
    ##  - alert: RedisDown
    ##    expr: redis_up{service="{{ template "common.names.fullname" . }}-metrics"} == 0
    ##    for: 2m
    ##    labels:
    ##      severity: error
    ##    annotations:
    ##      summary: Redis&trade; instance {{ "{{ $instance }}" }} down
    ##      description: Redis&trade; instance {{ "{{ $instance }}" }} is down.
    ##  - alert: RedisMemoryHigh
    ##    expr: >
    ##       redis_memory_used_bytes{service="{{ template "common.names.fullname" . }}-metrics"} * 100
    ##       /
    ##       redis_memory_max_bytes{service="{{ template "common.names.fullname" . }}-metrics"}
    ##       > 90
    ##    for: 2m
    ##    labels:
    ##      severity: error
    ##    annotations:
    ##      summary: Redis&trade; instance {{ "{{ $instance }}" }} is using too much memory
    ##      description: Redis&trade; instance {{ "{{ $instance }}" }} is using {{ "{{ $value }}" }}% of its available memory.
    ##  - alert: RedisKeyEviction
    ##    expr: increase(redis_evicted_keys_total{service="{{ template "common.names.fullname" . }}-metrics"}[5m]) > 0
    ##    for: 1s
    ##    labels:
    ##      severity: error
    ##    annotations:
    ##      summary: Redis&trade; instance {{ "{{ $instance }}" }} has evicted keys
    ##      description: Redis&trade; instance {{ "{{ $instance }}" }} has evicted {{ "{{ $value }}" }} keys in the last 5 minutes.
    ##
    rules: []
  ## @param metrics.priorityClassName Metrics exporter pod priorityClassName
  ##
  priorityClassName: ""
  ## @param metrics.service.type Kubernetes Service type (redis metrics)
  ## @param metrics.service.loadBalancerIP Use serviceLoadBalancerIP to request a specific static IP, otherwise leave blank
  ## @param metrics.service.annotations Annotations for the services to monitor.
  ## @param metrics.service.labels Additional labels for the metrics service
  ##
  service:
    type: ClusterIP
    loadBalancerIP: ""
    annotations: {}
    labels: {}

## @section Sysctl Image parameters

## Sysctl InitContainer
## Used to perform sysctl operation to modify Kernel settings (needed sometimes to avoid warnings)
##
sysctlImage:
  ## @param sysctlImage.enabled Enable an init container to modify Kernel settings
  ##
  enabled: false
  ## @param sysctlImage.command sysctlImage command to execute
  ##
  command: []
  ## @param sysctlImage.registry sysctlImage Init container registry
  ## @param sysctlImage.repository sysctlImage Init container repository
  ## @param sysctlImage.tag sysctlImage Init container tag
  ## @param sysctlImage.pullPolicy sysctlImage Init container pull policy
  ## @param sysctlImage.pullSecrets Specify docker-registry secret names as an array
  ##
  registry: docker.io
  repository: bitnami/bitnami-shell
  tag: 10-debian-10-r233
  pullPolicy: IfNotPresent
  ## Optionally specify an array of imagePullSecrets.
  ## Secrets must be manually created in the namespace.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ## e.g:
  ## pullSecrets:
  ##   - myRegistryKeySecretName
  ##
  pullSecrets: []
  ## @param sysctlImage.mountHostSys Mount the host `/sys` folder to `/host-sys`
  ##
  mountHostSys: false
  ## Container resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## @param sysctlImage.resources.limits The resources limits for the container
  ## @param sysctlImage.resources.requests The requested resources for the container
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 100m
    ##    memory: 128Mi
    limits: {}
    ## Examples:
    ## requests:
    ##    cpu: 100m
    ##    memory: 128Mi
    requests: {}

  EOF
  ]
}
