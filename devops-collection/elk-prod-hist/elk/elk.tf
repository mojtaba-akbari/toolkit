resource "helm_release" "elasticsearch-hist" {
  name             = "elasticsearch-hist"
  chart            = "bitnami/elasticsearch"
  version          = "15.10.3"
  namespace        = "logging"
  create_namespace = true
  wait             = "false"
  depends_on       = [null_resource.elasticsearch_community]
  values = [<<EOF
## @section Global parameters
## Global Docker image parameters
## Please, note that this will override the image parameters, including dependencies, configured to use the global value
## Current available global Docker image parameters: imageRegistry, imagePullSecrets and storageClass

## @param global.imageRegistry Global Docker image registry
## @param global.imagePullSecrets Global Docker registry secret names as an array
## @param global.storageClass Global StorageClass for Persistent Volume(s)
## @param global.coordinating.name Coordinating name to be used in the Kibana subchart (service name)
## @param global.kibanaEnabled Whether or not to enable Kibana
##
global:
  imageRegistry: ""
  ## E.g.
  ## imagePullSecrets:
  ##   - myRegistryKeySecretName
  ##
  imagePullSecrets: []
  storageClass: ""
  coordinating:
    name: coordinating-only
  kibanaEnabled: false

## @section Common parameters

## @param nameOverride String to partially override common.names.fullname template (will maintain the release name)
##
nameOverride: ""
## @param fullnameOverride String to fully override common.names.fullname template
##
fullnameOverride: ""
## @param clusterDomain Kubernetes cluster domain
##
clusterDomain: cluster.local

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

## @section Elasticsearch parameters

## Bitnami Elasticsearch image version
## ref: https://hub.docker.com/r/bitnami/elasticsearch/tags/
## @param image.registry Elasticsearch image registry
## @param image.repository Elasticsearch image repository
## @param image.tag Elasticsearch image tag (immutable tags are recommended)
## @param image.pullPolicy Elasticsearch image pull policy
## @param image.pullSecrets Elasticsearch image pull secrets
## @param image.debug Enable image debug mode
##
image:
  registry: docker.io
  repository: bitnami/elasticsearch
  #tag: 7.14.0-debian-10-r21
  tag: 7.15.1-debian-10-r16
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
  ## Set to true if you would like to see extra information on logs
  ##
  debug: false
## @param name Elasticsearch cluster name
##
name: efk-kub-log
## @param plugins Comma, semi-colon or space separated list of plugins to install at initialization
## ref: https://github.com/bitnami/bitnami-docker-elasticsearch#environment-variables
##
plugins: ""
## @param snapshotRepoPath File System snapshot repository path
## ref: https://github.com/bitnami/bitnami-docker-elasticsearch#environment-variables
##
snapshotRepoPath: ""
## @param config Override elasticsearch configuration
##
config: {}

## @param extraConfig Append extra configuration to the elasticsearch node configuration
## Use this instead of `config` to add more configuration
## See below example:
## extraConfig:
##   node:
##     store:
##       allow_mmap: false
## ref: https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html
##
extraConfig:
  path:
    repo: ["/nfs-storage"]
  xpack:
    #ml:
      #enabled: "true"
    #monitoring:
      #enabled: "true"
    security:
      enabled: false
      #transport:
        #ssl:
          #enabled: "true"
          #verification_mode: certificate
          #keystore:
            #path: /opt/bitnami/elasticsearch/config/cert/cert.p12
          #truststore:
            #path: /opt/bitnami/elasticsearch/config/cert/cert.p12
    #watcher:
      #enabled: "true"

## @param extraVolumes A list of volumes to be added to the pod
## Example Use Case: mount ssl certificates when elasticsearch has tls enabled
extraVolumes:
  - name: nfs-storage
    persistentVolumeClaim:
      claimName: nfs-storage-pvc-extra
   #- name: es-certs
     #hostPath:
      # directory location on host
      #path: /mnt/elastic-cert-sercurity
      # this field is optional
      #type: Directory

##extraVolumes: []
## @param extraVolumeMounts A list of volume mounts to be added to the pod

extraVolumeMounts:
   - name: nfs-storage
     mountPath: /nfs-storage
     readOnly: false

#extraVolumeMounts: []
## @param initScripts Dictionary of init scripts. Evaluated as a template.
## Specify dictionary of scripts to be run at first boot
## Alternatively, you can put your scripts under the files/docker-entrypoint-initdb.d directory
## For example:
initScripts:
  my_init_script.sh: |
      #!/bin/sh
      echo "HI"
##initScripts: {}
## @param initScriptsCM ConfigMap with the init scripts. Evaluated as a template.
## Note: This will override initScripts
##
initScriptsCM: ""
## @param initScriptsSecret Secret containing `/docker-entrypoint-initdb.d` scripts to be executed at initialization time that contain sensitive data. Evaluated as a template.
##
initScriptsSecret: ""
## @param extraEnvVars Array containing extra env vars to be added to all pods (evaluated as a template)
## For example:
## extraEnvVars:
##  - name: MY_ENV_VAR
##    value: env_var_value
##
extraEnvVars:
  - name: ELASTIC_PASSWORD
    value: elasticZooket123456
  - name: ELASTIC_USERNAME
    value: zooket
## @param extraEnvVarsConfigMap ConfigMap containing extra env vars to be added to all pods (evaluated as a template)
##
extraEnvVarsConfigMap: ""
## @param extraEnvVarsSecret Secret containing extra env vars to be added to all pods (evaluated as a template)
##
extraEnvVarsSecret: ""

## @section Master parameters

## Elasticsearch master-eligible node parameters
##
master:
  ## @param master.name Master-eligible node pod name
  ##
  name: master
  ## @param master.fullnameOverride String to fully override elasticsearch.master.fullname template with a string
  ##
  fullnameOverride: ""
  ## @param master.replicas Desired number of Elasticsearch master-eligible nodes. Consider using an odd number of master nodes to prevent "split brain" situation.  See: https://www.elastic.co/guide/en/elasticsearch/reference/7.x/modules-discovery-voting.html
  ## https://www.elastic.co/guide/en/elasticsearch/reference/7.x/modules-discovery-voting.html#_even_numbers_of_master_eligible_nodes
  ## https://www.elastic.co/guide/en/elasticsearch/reference/7.x/modules-discovery-quorums.html#modules-discovery-quorums
  ##
  replicas: 1
  ## Update strategy for ElasticSearch master statefulset
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ## @param master.updateStrategy.type Update strategy for Master statefulset
  ##
  updateStrategy:
    type: RollingUpdate
  ## @param master.hostAliases Add deployment host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param master.schedulerName Name of the k8s scheduler (other than default)
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ##
  ## @param master.heapSize Master-eligible node heap size
  ##
  heapSize: 1024m
  ## @param master.podAnnotations Annotations for master-eligible pods.
  ##
  podAnnotations: {}
  ## @param master.podLabels Extra labels to add to Pod
  ##
  podLabels: {}
  ## Pod Security Context for master-eligible pods.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  ## @param master.securityContext.enabled Enable security context for master-eligible pods
  ## @param master.securityContext.fsGroup Group ID for the container for master-eligible pods
  ## @param master.securityContext.runAsUser User ID for the container for master-eligible pods
  ##
  securityContext:
    enabled: true
    fsGroup: 1001
    runAsUser: 1001
  ## @param master.podAffinityPreset Master-eligible Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param master.podAntiAffinityPreset Master-eligible Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: ""
  ## Node affinity preset. Allowed values: soft, hard
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ## @param master.nodeAffinityPreset.type Master-eligible Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## @param master.nodeAffinityPreset.key Master-eligible Node label key to match Ignored if `affinity` is set.
  ## @param master.nodeAffinityPreset.values Master-eligible Node label values to match. Ignored if `affinity` is set.
  ##
  nodeAffinityPreset:
    type: ""
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param master.affinity Master-eligible Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param master.nodeSelector Master-eligible Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {
    "kubernetes.io/hostname": "zooket-workers-b64-1-2xztz"
  }
  ## @param master.tolerations Master-eligible Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## Elasticsearch master-eligible container's resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param master.resources.limits The resources limits for the container
  ## @param master.resources.requests [object] The requested resources for the container
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 100m
    ##    memory: 128Mi
    limits: {}
    requests:
      cpu: 25m
      memory: 248Mi
  ## Elasticsearch master-eligible container's startup probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param master.startupProbe.enabled Enable/disable the startup probe (master nodes pod)
  ## @param master.startupProbe.initialDelaySeconds Delay before startup probe is initiated (master nodes pod)
  ## @param master.startupProbe.periodSeconds How often to perform the probe (master nodes pod)
  ## @param master.startupProbe.timeoutSeconds When the probe times out (master nodes pod)
  ## @param master.startupProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (master nodes pod)
  ## @param master.startupProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch master-eligible container's liveness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param master.livenessProbe.enabled Enable/disable the liveness probe (master-eligible nodes pod)
  ## @param master.livenessProbe.initialDelaySeconds Delay before liveness probe is initiated (master-eligible nodes pod)
  ## @param master.livenessProbe.periodSeconds How often to perform the probe (master-eligible nodes pod)
  ## @param master.livenessProbe.timeoutSeconds When the probe times out (master-eligible nodes pod)
  ## @param master.livenessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (master-eligible nodes pod)
  ## @param master.livenessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ##
  livenessProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch master-eligible container's readiness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param master.readinessProbe.enabled Enable/disable the readiness probe (master-eligible nodes pod)
  ## @param master.readinessProbe.initialDelaySeconds Delay before readiness probe is initiated (master-eligible nodes pod)
  ## @param master.readinessProbe.periodSeconds How often to perform the probe (master-eligible nodes pod)
  ## @param master.readinessProbe.timeoutSeconds When the probe times out (master-eligible nodes pod)
  ## @param master.readinessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (master-eligible nodes pod)
  ## @param master.readinessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ##
  readinessProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## @param master.customStartupProbe Override default startup probe
  ##
  customStartupProbe: {}
  ## @param master.customLivenessProbe Override default liveness probe
  ##
  customLivenessProbe: {}
  ## @param master.customReadinessProbe Override default readiness probe
  ##
  customReadinessProbe: {}
  ## @param master.initContainers Extra init containers to add to the Elasticsearch master-eligible pod(s)
  ##
  initContainers: []
  ## @param master.sidecars Extra sidecar containers to add to the Elasticsearch master-eligible pod(s)
  ##
  sidecars: []
  ## Enable persistence using Persistent Volume Claims
  ## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
  ##
  persistence:
    ## @param master.persistence.enabled Enable persistence using a `PersistentVolumeClaim`
    ##
    enabled: true
    ## @param master.persistence.storageClass Persistent Volume Storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: "hiops"
    ## @param master.persistence.existingClaim Existing Persistent Volume Claim
    ## then accept the value as an existing Persistent Volume Claim to which
    ## the container should be bound
    ##
    existingClaim: ""
    ## @param master.persistence.existingVolume Existing Persistent Volume for use as volume match label selector to the `volumeClaimTemplate`. Ignored when `master.persistence.selector` is set.
    ##
    existingVolume: ""
    ## @param master.persistence.selector Configure custom selector for existing Persistent Volume. Overwrites `master.persistence.existingVolume`
    ## selector:
    ##   matchLabels:
    ##     volume:
    ##
    selector: {}
    ## @param master.persistence.annotations Persistent Volume Claim annotations
    ##
    annotations: {}
    ## @param master.persistence.accessModes Persistent Volume Access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param master.persistence.size Persistent Volume Size
    ##
    size: 250Gi
  ## Service parameters for master-eligible node(s)
  ##
  service:
    ## @param master.service.type Kubernetes Service type (master-eligible nodes)
    ##
    type: ClusterIP
    ## @param master.service.port Kubernetes Service port for Elasticsearch transport port (master-eligible nodes)
    ##
    port: 9300
    ## @param master.service.nodePort Kubernetes Service nodePort (master-eligible nodes)
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
    ##
    nodePort: ""
    ## @param master.service.annotations Annotations for master-eligible nodes service
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    annotations: {}
    ## @param master.service.loadBalancerIP loadBalancerIP if master-eligible nodes service type is `LoadBalancer`
    ## Set the LoadBalancer service type to internal only.
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    loadBalancerIP: ""
  ## Provide functionality to use RBAC
  ##
  serviceAccount:
    ## @param master.serviceAccount.create Enable creation of ServiceAccount for the master node
    ##
    create: false
    ## @param master.serviceAccount.name Name of the created serviceAccount
    ## If not set and create is true, a name is generated using the fullname template
    name: ""
  ## Autoscaling configuration
  ## @param master.autoscaling.enabled Enable autoscaling for master replicas
  ## @param master.autoscaling.minReplicas Minimum number of master replicas
  ## @param master.autoscaling.maxReplicas Maximum number of master replicas
  ## @param master.autoscaling.targetCPU Target CPU utilization percentage for master replica autoscaling
  ## @param master.autoscaling.targetMemory Target Memory utilization percentage for master replica autoscaling
  ##
  autoscaling:
    enabled: false
    minReplicas: 2
    maxReplicas: 11
    targetCPU: ""
    targetMemory: ""

## @section Coordinating parameters

## Elasticsearch coordinating-only node parameters
##
coordinating:
  ## @param coordinating.fullnameOverride String to fully override elasticsearch.coordinating.fullname template with a string
  ##
  fullnameOverride: ""
  ## @param coordinating.replicas Desired number of Elasticsearch coordinating-only nodes
  ##
  replicas: 0
  ## @param coordinating.hostAliases Add deployment host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param coordinating.schedulerName Name of the k8s scheduler (other than default)
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## Update strategy for ElasticSearch coordinating deployment
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy
  ## @param coordinating.updateStrategy.type Update strategy for Coordinating Deployment
  ##
  updateStrategy:
    type: RollingUpdate
  ## @param coordinating.heapSize Coordinating-only node heap size
  ##
  heapSize: 128m
  ## @param coordinating.podAnnotations Annotations for coordinating pods.
  ##
  podAnnotations: {}
  ## @param coordinating.podLabels Extra labels to add to Pod
  ##
  podLabels: {}
  ## Pod Security Context for coordinating-only pods.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  ## @param coordinating.securityContext.enabled Enable security context for coordinating-only pods
  ## @param coordinating.securityContext.fsGroup Group ID for the container for coordinating-only pods
  ## @param coordinating.securityContext.runAsUser User ID for the container for coordinating-only pods
  ##
  securityContext:
    enabled: true
    fsGroup: 1001
    runAsUser: 1001
  ## @param coordinating.podAffinityPreset Coordinating Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param coordinating.podAntiAffinityPreset Coordinating Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: ""
  ## Node affinity preset
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ## @param coordinating.nodeAffinityPreset.type Coordinating Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## @param coordinating.nodeAffinityPreset.key Coordinating Node label key to match Ignored if `affinity` is set.
  ## @param coordinating.nodeAffinityPreset.values Coordinating Node label values to match. Ignored if `affinity` is set.
  ##
  nodeAffinityPreset:
    type: ""
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param coordinating.affinity Coordinating Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param coordinating.nodeSelector Coordinating Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param coordinating.tolerations Coordinating Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## Elasticsearch coordinating-only container's resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param coordinating.resources.limits The resources limits for the container
  ## @param coordinating.resources.requests [object] The requested resources for the container
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 100m
    ##    memory: 384Mi
    limits: {}
    requests:
      cpu: 25m
      memory: 256Mi
  ## Elasticsearch coordinating-only container's startup probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param coordinating.startupProbe.enabled Enable/disable the startup probe (coordinating nodes pod)
  ## @param coordinating.startupProbe.initialDelaySeconds Delay before startup probe is initiated (coordinating nodes pod)
  ## @param coordinating.startupProbe.periodSeconds How often to perform the probe (coordinating nodes pod)
  ## @param coordinating.startupProbe.timeoutSeconds When the probe times out (coordinating nodes pod)
  ## @param coordinating.startupProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param coordinating.startupProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (coordinating nodes pod)
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch coordinating-only container's liveness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param coordinating.livenessProbe.enabled Enable/disable the liveness probe (coordinating-only nodes pod)
  ## @param coordinating.livenessProbe.initialDelaySeconds Delay before liveness probe is initiated (coordinating-only nodes pod)
  ## @param coordinating.livenessProbe.periodSeconds How often to perform the probe (coordinating-only nodes pod)
  ## @param coordinating.livenessProbe.timeoutSeconds When the probe times out (coordinating-only nodes pod)
  ## @param coordinating.livenessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param coordinating.livenessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (coordinating-only nodes pod)
  ##
  livenessProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch coordinating-only container's readiness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param coordinating.readinessProbe.enabled Enable/disable the readiness probe (coordinating-only nodes pod)
  ## @param coordinating.readinessProbe.initialDelaySeconds Delay before readiness probe is initiated (coordinating-only nodes pod)
  ## @param coordinating.readinessProbe.periodSeconds How often to perform the probe (coordinating-only nodes pod)
  ## @param coordinating.readinessProbe.timeoutSeconds When the probe times out (coordinating-only nodes pod)
  ## @param coordinating.readinessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param coordinating.readinessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (coordinating-only nodes pod)
  ##
  readinessProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## @param coordinating.customStartupProbe Override default startup probe
  ##
  customStartupProbe: {}
  ## @param coordinating.customLivenessProbe Override default liveness probe
  ##
  customLivenessProbe: {}
  ## @param coordinating.customReadinessProbe Override default readiness probe
  ##
  customReadinessProbe: {}
  ## @param coordinating.initContainers Extra init containers to add to the Elasticsearch coordinating-only pod(s)
  ##
  initContainers: []
  ## @param coordinating.sidecars Extra sidecar containers to add to the Elasticsearch coordinating-only pod(s)
  ##
  sidecars: []
  ## Service parameters for coordinating-only node(s)
  ##
  service:
    ## @param coordinating.service.type Kubernetes Service type (coordinating-only nodes)
    ##
    type: ClusterIP
    ## @param coordinating.service.port Kubernetes Service port for REST API (coordinating-only nodes)
    ##
    port: 9200
    ## @param coordinating.service.nodePort Kubernetes Service nodePort (coordinating-only nodes)
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
    ##
    nodePort: ""
    ## @param coordinating.service.annotations Annotations for coordinating-only nodes service
    ## Set the LoadBalancer service type to internal only.
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    annotations: {}
    ## @param coordinating.service.loadBalancerIP loadBalancerIP if coordinating-only nodes service type is `LoadBalancer`
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    loadBalancerIP: ""
  ## Provide functionality to use RBAC
  ##
  serviceAccount:
    ## @param coordinating.serviceAccount.create Enable creation of ServiceAccount for the coordinating-only node
    ##
    create: false
    ## @param coordinating.serviceAccount.name Name of the created serviceAccount
    ## If not set and create is true, a name is generated using the fullname template
    ##
    name: ""
  ## Autoscaling configuration
  ## @param coordinating.autoscaling.enabled Enable autoscaling for coordinating replicas
  ## @param coordinating.autoscaling.minReplicas Minimum number of coordinating replicas
  ## @param coordinating.autoscaling.maxReplicas Maximum number of coordinating replicas
  ## @param coordinating.autoscaling.targetCPU Target CPU utilization percentage for coordinating replica autoscaling
  ## @param coordinating.autoscaling.targetMemory Target Memory utilization percentage for coordinating replica autoscaling
  ##
  autoscaling:
    enabled: false
    minReplicas: 2
    maxReplicas: 11
    targetCPU: ""
    targetMemory: ""

## @section Data parameters

## Elasticsearch data node parameters
##
data:
  ## @param data.name Data node pod name
  ##
  name: data
  ## @param data.fullnameOverride String to fully override elasticsearch.data.fullname template with a string
  ##
  fullnameOverride: ""
  ## @param data.replicas Desired number of Elasticsearch data nodes
  ##
  replicas: 1
  ## @param data.hostAliases Add deployment host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param data.schedulerName Name of the k8s scheduler (other than default)
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## Update strategy for ElasticSearch Data statefulset
  ## ref: https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#update-strategies
  ## @param data.updateStrategy.type Update strategy for Data statefulset
  ## @param data.updateStrategy.rollingUpdatePartition Partition update strategy for Data statefulset
  ##
  updateStrategy:
    type: RollingUpdate
    rollingUpdatePartition: ""
  ## @param data.heapSize Data node heap size
  ##
  heapSize: 1024m
  ## @param data.podAnnotations Annotations for data pods.
  ##
  podAnnotations: {}
  ## @param data.podLabels Extra labels to add to Pod
  ##
  podLabels: {}
  ## Pod Security Context for data pods.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  ## @param data.securityContext.enabled Enable security context for data pods
  ## @param data.securityContext.fsGroup Group ID for the container for data pods
  ## @param data.securityContext.runAsUser User ID for the container for data pods
  ##
  securityContext:
    enabled: true
    fsGroup: 1001
    runAsUser: 1001
  ## @param data.podAffinityPreset Data Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param data.podAntiAffinityPreset Data Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: ""
  ## Node affinity preset. Allowed values: soft, hard
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ## @param data.nodeAffinityPreset.type Data Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## @param data.nodeAffinityPreset.key Data Node label key to match Ignored if `affinity` is set.
  ## @param data.nodeAffinityPreset.values Data Node label values to match. Ignored if `affinity` is set.
  ##
  nodeAffinityPreset:
    type: ""
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []

  ## @param data.affinity Data Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param data.nodeSelector Data Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {
    "kubernetes.io/hostname": "zooket-workers-b64-1-2xztz"
  }
  ## @param data.tolerations Data Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## Elasticsearch data container's resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param data.resources.limits The resources limits for the container
  ## @param data.resources.requests [object] The requested resources for the container
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 100m
    ##    memory: 2176Mi
    limits: {}
    requests:
      cpu: 25m
      memory: 248Mi
  ## Elasticsearch data container's startup probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param data.startupProbe.enabled Enable/disable the startup probe (data nodes pod)
  ## @param data.startupProbe.initialDelaySeconds Delay before startup probe is initiated (data nodes pod)
  ## @param data.startupProbe.periodSeconds How often to perform the probe (data nodes pod)
  ## @param data.startupProbe.timeoutSeconds When the probe times out (data nodes pod)
  ## @param data.startupProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param data.startupProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (data nodes pod)
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch data container's liveness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param data.livenessProbe.enabled Enable/disable the liveness probe (data nodes pod)
  ## @param data.livenessProbe.initialDelaySeconds Delay before liveness probe is initiated (data nodes pod)
  ## @param data.livenessProbe.periodSeconds How often to perform the probe (data nodes pod)
  ## @param data.livenessProbe.timeoutSeconds When the probe times out (data nodes pod)
  ## @param data.livenessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param data.livenessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (data nodes pod)
  ##
  livenessProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch data container's readiness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param data.readinessProbe.enabled Enable/disable the readiness probe (data nodes pod)
  ## @param data.readinessProbe.initialDelaySeconds Delay before readiness probe is initiated (data nodes pod)
  ## @param data.readinessProbe.periodSeconds How often to perform the probe (data nodes pod)
  ## @param data.readinessProbe.timeoutSeconds When the probe times out (data nodes pod)
  ## @param data.readinessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param data.readinessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (data nodes pod)
  ##
  readinessProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## @param data.customStartupProbe Override default startup probe
  ##
  customStartupProbe: {}
  ## @param data.customLivenessProbe Override default liveness probe
  ##
  customLivenessProbe: {}
  ## @param data.customReadinessProbe Override default readiness probe
  ##
  customReadinessProbe: {}
  ## @param data.initContainers Extra init containers to add to the Elasticsearch data pod(s)
  ##
  initContainers: []
  ## @param data.sidecars Extra sidecar containers to add to the Elasticsearch data pod(s)
  ##
  sidecars: []
  ## Enable persistence using Persistent Volume Claims
  ## ref: http://kubernetes.io/docs/user-guide/persistent-volumes/
  ##
  persistence:
    ## @param data.persistence.enabled Enable persistence using a `PersistentVolumeClaim`
    ##
    enabled: true
    ## @param data.persistence.storageClass Persistent Volume Storage Class
    ## If defined, storageClassName: <storageClass>
    ## If set to "-", storageClassName: "", which disables dynamic provisioning
    ## If undefined (the default) or set to null, no storageClassName spec is
    ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
    ##   GKE, AWS & OpenStack)
    ##
    storageClass: "hiops"
    ## @param data.persistence.existingClaim Existing Persistent Volume Claim
    ## If persistence is enable, and this value is defined,
    ## then accept the value as an existing Persistent Volume Claim to which
    ## the container should be bound
    ##
    existingClaim: ""
    ## @param data.persistence.existingVolume Existing Persistent Volume for use as volume match label selector to the `volumeClaimTemplate`. Ignored when `data.persistence.selector` ist set.
    ##
    existingVolume: ""
    ## @param data.persistence.selector Configure custom selector for existing Persistent Volume. Overwrites `data.persistence.existingVolume`
    ## selector:
    ##   matchLabels:
    ##     volume:
    selector: {}
    ## @param data.persistence.annotations Persistent Volume Claim annotations
    ##
    annotations: {}
    ## @param data.persistence.accessModes Persistent Volume Access Modes
    ##
    accessModes:
      - ReadWriteOnce
    ## @param data.persistence.size Persistent Volume Size
    ##
    size: 2048Gi
  ## Provide functionality to use RBAC
  ##
  serviceAccount:
    ## @param data.serviceAccount.create Enable creation of ServiceAccount for the data node
    ##
    create: false
    ## @param data.serviceAccount.name Name of the created serviceAccount
    ## If not set and create is true, a name is generated using the fullname template
    ##
    name: ""
  ## Autoscaling configuration
  ## @param data.autoscaling.enabled Enable autoscaling for data replicas
  ## @param data.autoscaling.minReplicas Minimum number of data replicas
  ## @param data.autoscaling.maxReplicas Maximum number of data replicas
  ## @param data.autoscaling.targetCPU Target CPU utilization percentage for data replica autoscaling
  ## @param data.autoscaling.targetMemory Target Memory utilization percentage for data replica autoscaling
  ##
  autoscaling:
    enabled: false
    minReplicas: 2
    maxReplicas: 11
    targetCPU: ""
    targetMemory: ""

## @section Ingest parameters

## Elasticsearch ingest node parameters
##
ingest:
  ## @param ingest.enabled Enable ingest nodes
  ##
  enabled: false
  ## @param ingest.name Ingest node pod name
  ##
  name: ingest
  ## @param ingest.fullnameOverride String to fully override elasticsearch.ingest.fullname template with a string
  ##
  fullnameOverride: ""
  ## @param ingest.replicas Desired number of Elasticsearch ingest nodes
  ##
  replicas: 2
  ## @param ingest.heapSize Ingest node heap size
  ##
  heapSize: 128m
  ## @param ingest.podAnnotations Annotations for ingest pods.
  ##
  podAnnotations: {}
  ## @param ingest.hostAliases Add deployment host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param ingest.schedulerName Name of the k8s scheduler (other than default)
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param ingest.podLabels Extra labels to add to Pod
  ##
  podLabels: {}
  ## Pod Security Context for ingest pods.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
  ## @param ingest.securityContext.enabled Enable security context for ingest pods
  ## @param ingest.securityContext.fsGroup Group ID for the container for ingest pods
  ## @param ingest.securityContext.runAsUser User ID for the container for ingest pods
  ##
  securityContext:
    enabled: true
    fsGroup: 1001
    runAsUser: 1001
  ## @param ingest.podAffinityPreset Ingest Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param ingest.podAntiAffinityPreset Ingest Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: ""
  ## Node affinity preset
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ## Allowed values: soft, hard
  ## @param ingest.nodeAffinityPreset.type Ingest Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## @param ingest.nodeAffinityPreset.key Ingest Node label key to match Ignored if `affinity` is set.
  ## @param ingest.nodeAffinityPreset.values Ingest Node label values to match. Ignored if `affinity` is set.
  ##
  nodeAffinityPreset:
    type: ""
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param ingest.affinity Ingest Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param ingest.nodeSelector Ingest Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param ingest.tolerations Ingest Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## Elasticsearch ingest container's resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param ingest.resources.limits The resources limits for the container
  ## @param ingest.resources.requests [object] The requested resources for the container
  ##
  resources:
    ## Example:
    ## limits:
    ##    cpu: 100m
    ##    memory: 384Mi
    limits: {}
    requests:
      cpu: 25m
      memory: 256Mi
  ## Elasticsearch ingest container's startup probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param ingest.startupProbe.enabled Enable/disable the startup probe (ingest nodes pod)
  ## @param ingest.startupProbe.initialDelaySeconds Delay before startup probe is initiated (ingest nodes pod)
  ## @param ingest.startupProbe.periodSeconds How often to perform the probe (ingest nodes pod)
  ## @param ingest.startupProbe.timeoutSeconds When the probe times out (ingest nodes pod)
  ## @param ingest.startupProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param ingest.startupProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (ingest nodes pod)
  ##
  startupProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch ingest container's liveness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param ingest.livenessProbe.enabled Enable/disable the liveness probe (ingest nodes pod)
  ## @param ingest.livenessProbe.initialDelaySeconds Delay before liveness probe is initiated (ingest nodes pod)
  ## @param ingest.livenessProbe.periodSeconds How often to perform the probe (ingest nodes pod)
  ## @param ingest.livenessProbe.timeoutSeconds When the probe times out (ingest nodes pod)
  ## @param ingest.livenessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param ingest.livenessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (ingest nodes pod)
  ##
  livenessProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch ingest container's readiness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param ingest.readinessProbe.enabled Enable/disable the readiness probe (ingest nodes pod)
  ## @param ingest.readinessProbe.initialDelaySeconds Delay before readiness probe is initiated (ingest nodes pod)
  ## @param ingest.readinessProbe.periodSeconds How often to perform the probe (ingest nodes pod)
  ## @param ingest.readinessProbe.timeoutSeconds When the probe times out (ingest nodes pod)
  ## @param ingest.readinessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param ingest.readinessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (ingest nodes pod)
  ##
  readinessProbe:
    enabled: false
    initialDelaySeconds: 90
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## @param ingest.customStartupProbe Override default startup probe
  ##
  customStartupProbe: {}
  ## @param ingest.customLivenessProbe Override default liveness probe
  ##
  customLivenessProbe: {}
  ## @param ingest.customReadinessProbe Override default readiness probe
  ##
  customReadinessProbe: {}
  ## @param ingest.initContainers Extra init containers to add to the Elasticsearch ingest pod(s)
  ##
  initContainers: []
  ## @param ingest.sidecars Extra sidecar containers to add to the Elasticsearch ingest pod(s)
  ##
  sidecars: []
  ## Service parameters for ingest node(s)
  ##
  service:
    ## @param ingest.service.type Kubernetes Service type (ingest nodes)
    ##
    type: ClusterIP
    ## @param ingest.service.port Kubernetes Service port Elasticsearch transport port (ingest nodes)
    ##
    port: 9300
    ## @param ingest.service.nodePort Kubernetes Service nodePort (ingest nodes)
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
    ##
    nodePort: ""
    ## @param ingest.service.annotations Annotations for ingest nodes service
    ## set the LoadBalancer service type to internal only.
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    annotations: {}
    ## @param ingest.service.loadBalancerIP loadBalancerIP if ingest nodes service type is `LoadBalancer`
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    loadBalancerIP: ""

## @section Curator parameters

## Elasticsearch curator parameters
##
curator:
  ## @param curator.enabled Enable Elasticsearch Curator cron job
  enabled: false
  ## @param curator.name Elasticsearch Curator pod name
  ##
  name: curator
  ## @param curator.image.registry Elasticsearch Curator image registry
  ## @param curator.image.repository Elasticsearch Curator image repository
  ## @param curator.image.tag Elasticsearch Curator image tag
  ## @param curator.image.pullPolicy Elasticsearch Curator image pull policy
  ## @param curator.image.pullSecrets Elasticsearch Curator image pull secrets
  ##
  image:
    registry: docker.io
    repository: bitnami/elasticsearch-curator
    tag: 5.8.4-debian-10-r102
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## @param curator.cronjob.schedule Schedule for the CronJob
  ## @param curator.cronjob.annotations Annotations to add to the cronjob
  ## @param curator.cronjob.concurrencyPolicy `Allow,Forbid,Replace` concurrent jobs
  ## @param curator.cronjob.failedJobsHistoryLimit Specify the number of failed Jobs to keep
  ## @param curator.cronjob.successfulJobsHistoryLimit Specify the number of completed Jobs to keep
  ## @param curator.cronjob.jobRestartPolicy Control the Job restartPolicy
  ##
  cronjob:
    ## At 01:00 every day
    schedule: "0 1 * * *"
    annotations: {}
    concurrencyPolicy: ""
    failedJobsHistoryLimit: ""
    successfulJobsHistoryLimit: ""
    jobRestartPolicy: Never
  ## @param curator.schedulerName Name of the k8s scheduler (other than default)
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## @param curator.podAnnotations Annotations to add to the pod
  ##
  podAnnotations: {}
  ## @param curator.podLabels Extra labels to add to Pod
  ##
  podLabels: {}
  ## @param curator.podAffinityPreset Curator Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param curator.podAntiAffinityPreset Curator Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: ""
  ## Node affinity preset
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ## @param curator.nodeAffinityPreset.type Curator Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## @param curator.nodeAffinityPreset.key Curator Node label key to match Ignored if `affinity` is set.
  ## @param curator.nodeAffinityPreset.values Curator Node label values to match. Ignored if `affinity` is set.
  ##
  nodeAffinityPreset:
    type: ""
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param curator.initContainers Extra init containers to add to the Elasticsearch coordinating-only pod(s)
  ##
  initContainers: []
  ## @param curator.sidecars Extra sidecar containers to add to the Elasticsearch ingest pod(s)
  ##
  sidecars: []
  ## @param curator.affinity Curator Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param curator.nodeSelector Curator Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param curator.tolerations Curator Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## @param curator.rbac.enabled Enable RBAC resources
  ##
  rbac:
    enabled: false
  ## @param curator.serviceAccount.create Create a default serviceaccount for elasticsearch curator
  ## @param curator.serviceAccount.name Name for elasticsearch curator serviceaccount
  ##
  serviceAccount:
    create: true
    ## If not set and create is true, a name is generated using the fullname template
    ##
    name: ""
  ## @param curator.psp.create Create pod security policy resources
  ##
  psp:
    create: false
  ## @param curator.hooks [object] Whether to run job on selected hooks
  ##
  hooks:
    install: false
    upgrade: false
  ## @param curator.dryrun Run Curator in dry-run mode
  ##
  dryrun: false
  ## @param curator.command Command to execute
  ##
  command: ["curator"]
  ## @param curator.env Environment variables to add to the cronjob container
  ##
  env: {}
  ## Curator configMaps
  configMaps:
    ## @param curator.configMaps.action_file_yml [string] Contents of the Curator action_file.yml
    ## Delete indices older than 90 days
    ##
    action_file_yml: |-
      ---
      actions:
        1:
          action: delete_indices
          description: "Clean up ES by deleting old indices"
          options:
            timeout_override:
            continue_if_exception: False
            disable_action: False
            ignore_empty_list: True
          filters:
          - filtertype: age
            source: name
            direction: older
            timestring: '%Y.%m.%d'
            unit: days
            unit_count: 90
            field:
            stats_result:
            epoch:
            exclude: False
    ## @param curator.configMaps.config_yml [string] Contents of the Curator config.yml (overrides config)
    ## Default config (this value is evaluated as a template)
    ##
    config_yml: |-
      ---
      client:
        hosts:
          - {{ template "elasticsearch.coordinating.fullname" . }}.{{ .Release.Namespace }}.svc.{{ .Values.clusterDomain }}
        port: {{ .Values.coordinating.service.port }}
        # url_prefix:
        # use_ssl: True
        # certificate:
        # client_cert:
        # client_key:
        # ssl_no_validate: True
        # http_auth:
        # timeout: 30
        # master_only: False
      # logging:
      #   loglevel: INFO
      #   logfile:
      #   logformat: default
      #   blacklist: ['elasticsearch', 'urllib3']
  ## Curator resources requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param curator.resources.limits The resources limits for the container
  ## @param curator.resources.requests The requested resources for the container
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
  ## @param curator.priorityClassName Priority Class Name
  ##
  priorityClassName: ""
  ## @param curator.extraVolumes Extra volumes
  ## Example Use Case: mount ssl certificates when elasticsearch has tls enabled
  ## extraVolumes:
  ##   - name: es-certs
  ##     secret:
  ##       defaultMode: 420
  ##       secretName: es-certs
  extraVolumes: []
  ## @param curator.extraVolumeMounts Mount extra volume(s)
  ## extraVolumeMounts:
  ##   - name: es-certs
  ##     mountPath: /certs
  ##     readOnly: true
  extraVolumeMounts: []
  ## @param curator.extraInitContainers DEPRECATED. Use `curator.initContainers` instead. Init containers to add to the cronjob container
  ## Don't configure S3 repository till Elasticsearch is reachable.
  ## Ensure that it is available at http://elasticsearch:9200
  ##
  ## elasticsearch-s3-repository:
  ##   image: bitnami/minideb
  ##   imagePullPolicy: "IfNotPresent"
  ##   command:
  ##   - "/bin/bash"
  ##   - "-c"
  ##   args:
  ##   - |
  ##     ES_HOST=elasticsearch
  ##     ES_PORT=9200
  ##     ES_REPOSITORY=backup
  ##     S3_REGION=us-east-1
  ##     S3_BUCKET=bucket
  ##     S3_BASE_PATH=backup
  ##     S3_COMPRESS=true
  ##     S3_STORAGE_CLASS=standard
  ##     install_packages curl && \
  ##     ( counter=0; while (( counter++ < 120 )); do curl -s http://$#{ES_HOST}:$#{ES_PORT} >/dev/null 2>&1 && break; echo "Waiting for elasticsearch $counter/120"; sleep 1; done ) && \
  ##     cat <<EOF | curl -sS -XPUT -H "Content-Type: application/json" -d @- http://$#{ES_HOST}:$#{ES_PORT}/_snapshot/$#{ES_REPOSITORY} \
  ##     {
  ##       "type": "s3",
  ##       "settings": {
  ##         "bucket": "$#{S3_BUCKET}",
  ##         "base_path": "$#{S3_BASE_PATH}",
  ##         "region": "$#{S3_REGION}",
  ##         "compress": "$#{S3_COMPRESS}",
  ##         "storage_class": "$#{S3_STORAGE_CLASS}"
  ##       }
  ##     }
  ##
  extraInitContainers: []

## @section Metrics parameters

## Elasticsearch Prometheus exporter configuration
## ref: https://hub.docker.com/r/bitnami/elasticsearch-exporter/tags/
##
metrics:
  ## @param metrics.enabled Enable prometheus exporter
  ##
  enabled: false
  ## @param metrics.name Metrics pod name
  ##
  name: metrics
  ## @param metrics.image.registry Metrics exporter image registry
  ## @param metrics.image.repository Metrics exporter image repository
  ## @param metrics.image.tag Metrics exporter image tag
  ## @param metrics.image.pullPolicy Metrics exporter image pull policy
  ## @param metrics.image.pullSecrets Metrics exporter image pull secrets
  ##
  image:
    registry: docker.io
    repository: bitnami/elasticsearch-exporter
    tag: 1.2.1-debian-10-r53
    pullPolicy: IfNotPresent
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## @param metrics.extraArgs Extra arguments to add to the default exporter command
  ## ref: https://github.com/justwatchcom/elasticsearch_exporter
  ## e.g
  ## extraArgs:
  ##   - --es.snapshots
  ##   - --es.indices
  ##
  extraArgs: []
  ## @param metrics.hostAliases Add deployment host aliases
  ## https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/
  ##
  hostAliases: []
  ## @param metrics.schedulerName Name of the k8s scheduler (other than default)
  ## ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-multiple-schedulers/
  ##
  schedulerName: ""
  ## Elasticsearch Prometheus exporter service type
  ##
  service:
    ## @param metrics.service.type Metrics exporter endpoint service type
    ##
    type: ClusterIP
    ## @param metrics.service.annotations [object] Provide any additional annotations which may be required.
    ## This can be used to set the LoadBalancer service type to internal only.
    ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
    ##
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "9114"
  ## @param metrics.podAffinityPreset Metrics Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAffinityPreset: ""
  ## @param metrics.podAntiAffinityPreset Metrics Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity
  ##
  podAntiAffinityPreset: ""
  ## Node affinity preset
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
  ## @param metrics.nodeAffinityPreset.type Metrics Node affinity preset type. Ignored if `affinity` is set. Allowed values: `soft` or `hard`
  ## @param metrics.nodeAffinityPreset.key Metrics Node label key to match Ignored if `affinity` is set.
  ## @param metrics.nodeAffinityPreset.values Metrics Node label values to match. Ignored if `affinity` is set.
  ##
  nodeAffinityPreset:
    type: ""
    ## E.g.
    ## key: "kubernetes.io/e2e-az-name"
    ##
    key: ""
    ## E.g.
    ## values:
    ##   - e2e-az1
    ##   - e2e-az2
    ##
    values: []
  ## @param metrics.affinity Metrics Affinity for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ## Note: podAffinityPreset, podAntiAffinityPreset, and  nodeAffinityPreset will be ignored when it's set
  ##
  affinity: {}
  ## @param metrics.nodeSelector Metrics Node labels for pod assignment
  ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  ##
  nodeSelector: {}
  ## @param metrics.tolerations Metrics Tolerations for pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  ##
  tolerations: []
  ## Elasticsearch Prometheus exporter resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  ## @param metrics.resources.limits The resources limits for the container
  ## @param metrics.resources.requests The requested resources for the container
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
  ## Elasticsearch metrics container's liveness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param metrics.livenessProbe.enabled Enable/disable the liveness probe (metrics pod)
  ## @param metrics.livenessProbe.initialDelaySeconds Delay before liveness probe is initiated (metrics pod)
  ## @param metrics.livenessProbe.periodSeconds How often to perform the probe (metrics pod)
  ## @param metrics.livenessProbe.timeoutSeconds When the probe times out (metrics pod)
  ## @param metrics.livenessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param metrics.livenessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (metrics pod)
  ##
  livenessProbe:
    enabled: true
    initialDelaySeconds: 60
    periodSeconds: 10
    timeoutSeconds: 5
    successThreshold: 1
    failureThreshold: 5
  ## Elasticsearch metrics container's readiness probe
  ## ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ## @param metrics.readinessProbe.enabled Enable/disable the readiness probe (metrics pod)
  ## @param metrics.readinessProbe.initialDelaySeconds Delay before readiness probe is initiated (metrics pod)
  ## @param metrics.readinessProbe.periodSeconds How often to perform the probe (metrics pod)
  ## @param metrics.readinessProbe.timeoutSeconds When the probe times out (metrics pod)
  ## @param metrics.readinessProbe.failureThreshold Minimum consecutive failures for the probe to be considered failed after having succeeded
  ## @param metrics.readinessProbe.successThreshold Minimum consecutive successes for the probe to be considered successful after having failed (metrics pod)
  ##
  readinessProbe:
    enabled: true
    initialDelaySeconds: 5
    periodSeconds: 10
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 5
  ## @param metrics.podAnnotations [object] Metrics exporter pod Annotation and Labels
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  ##
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "9114"
  ## @param metrics.podLabels Extra labels to add to Pod
  ##
  podLabels: {}
  ## Prometheus Operator ServiceMonitor configuration
  ##
  serviceMonitor:
    ## @param metrics.serviceMonitor.enabled if `true`, creates a Prometheus Operator ServiceMonitor (also requires `metrics.enabled` to be `true`)
    ##
    enabled: false
    ## @param metrics.serviceMonitor.namespace Namespace in which Prometheus is running
    ##
    namespace: ""
    ## @param metrics.serviceMonitor.interval Interval at which metrics should be scraped.
    ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#endpoint
    ## e.g:
    ## interval: 10s
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
    ## selector:
    ##   prometheus: my-prometheus
    ##
    selector: {}

## @section Sysctl Image parameters

## Kernel settings modifier image
##
sysctlImage:
  ## @param sysctlImage.enabled Enable kernel settings modifier image
  ##
  enabled: true
  ## @param sysctlImage.registry Kernel settings modifier image registry
  ## @param sysctlImage.repository Kernel settings modifier image repository
  ## @param sysctlImage.tag Kernel settings modifier image tag
  ## @param sysctlImage.pullPolicy Kernel settings modifier image pull policy
  ## @param sysctlImage.pullSecrets Kernel settings modifier image pull secrets
  ##
  registry: docker.io
  repository: bitnami/bitnami-shell
  tag: 10-debian-10-r171
  ## Specify a imagePullPolicy
  ## Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent'
  ## ref: http://kubernetes.io/docs/user-guide/images/#pre-pulling-images
  ##
  pullPolicy: Always
  ## Optionally specify an array of imagePullSecrets.
  ## Secrets must be manually created in the namespace.
  ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  ## e.g:
  ## pullSecrets:
  ##   - myRegistryKeySecretName
  ##
  pullSecrets: []
  ## Init container' resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
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

## @section VolumePermissions parameters

## Init containers parameters:
## volumePermissions: Change the owner and group of the persistent volume mountpoint to runAsUser:fsGroup values from the securityContext section.
##
volumePermissions:
  ## @param volumePermissions.enabled Enable init container that changes volume permissions in the data directory (for cases where the default k8s `runAsUser` and `fsUser` values do not work)
  ##
  enabled: false
  ## @param volumePermissions.image.registry Init container volume-permissions image registry
  ## @param volumePermissions.image.repository Init container volume-permissions image name
  ## @param volumePermissions.image.tag Init container volume-permissions image tag
  ## @param volumePermissions.image.pullPolicy Init container volume-permissions image pull policy
  ## @param volumePermissions.image.pullSecrets Init container volume-permissions image pull secrets
  ##
  image:
    registry: docker.io
    repository: bitnami/bitnami-shell
    tag: 10-debian-10-r171
    pullPolicy: Always
    ## Optionally specify an array of imagePullSecrets.
    ## Secrets must be manually created in the namespace.
    ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
    ## e.g:
    ## pullSecrets:
    ##   - myRegistryKeySecretName
    ##
    pullSecrets: []
  ## Init container' resource requests and limits
  ## ref: http://kubernetes.io/docs/user-guide/compute-resources/
  ## We usually recommend not to specify default resources and to leave this as a conscious
  ## choice for the user. This also increases chances charts run on environments with little
  ## resources, such as Minikube. If you do want to specify resources, uncomment the following
  ## lines, adjust them as necessary, and remove the curly braces after 'resources:'.
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

## @section Kibana Parameters

## Bundled Kibana parameters
## @param kibana.elasticsearch.hosts [array] Array containing hostnames for the ES instances. Used to generate the URL
## @param kibana.elasticsearch.port Port to connect Kibana and ES instance. Used to generate the URL
##
kibana:
  elasticsearch:
    hosts:
      - '{{ include "elasticsearch-hist.coordinating.fullname" . }}'
    port: 9200

  EOF
  ]
}