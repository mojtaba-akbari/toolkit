resource "helm_release" "fluent" {
   name             = "fluent"
   chart            = "fluent/fluentd"
   version          = "0.2.8"
   namespace        = "logging"
   create_namespace = true
   wait             = "false"
   depends_on       = [null_resource.fluent_community]
   values = [<<EOF
nameOverride: ""
fullnameOverride: ""

# DaemonSet or Deployment
kind: "DaemonSet"

# # Only applicable for Deployment
# replicaCount: 1

image:
  repository: "fluent/fluentd-kubernetes-daemonset"
  pullPolicy: "IfNotPresent"
  tag: ""

## Optional array of imagePullSecrets containing private registry credentials
## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
imagePullSecrets: []

serviceAccount:
  create: true
  annotations: {}
  name: null

rbac:
  create: false

# Configure podsecuritypolicy
# Ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/
podSecurityPolicy:
  enabled: true
  annotations: {}

## Security Context policies for controller pods
## See https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/ for
## notes on enabling and using sysctls
##
podSecurityContext: {}
  # seLinuxOptions:
  #   type: "spc_t"

securityContext: {}
  # capabilities:
  #   drop:
  #   - ALL
  # readOnlyRootFilesystem: true
  # runAsNonRoot: true
  # runAsUser: 1000

# Congigure the livessProbe
# Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
#livenessProbe:
  # httpGet:
  #   path: /metrics
  #   port: metrics
  # initialDelaySeconds: 0
  # periodSeconds: 10
  # timeoutSeconds: 1
  # successThreshold: 1
  # failureThreshold: 3

# Congigure the readinessProbe
# Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
# readinessProbe:
#   httpGet:
#     path: /metrics
#     port: metrics
  # initialDelaySeconds: 0
  # periodSeconds: 10
  # timeoutSeconds: 1
  # successThreshold: 1
  # failureThreshold: 3

resources: {}
  # requests:
  #   cpu: 10m
  #   memory: 128Mi
  # limits:
  #   memory: 128Mi

## only available if kind is Deployment
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80
  ## see https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#autoscaling-on-multiple-metrics-and-custom-metrics
  customRules: []
    # - type: Pods
    #   pods:
    #     metric:
    #       name: packets-per-second
    #     target:
    #       type: AverageValue
    #       averageValue: 1k
  ## see https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-configurable-scaling-behavior
  # behavior:
  #   scaleDown:
  #     policies:
  #       - type: Pods
  #         value: 4
  #         periodSeconds: 60
  #       - type: Percent
  #         value: 10
  #         periodSeconds: 60

# priorityClassName: "system-node-critical"

nodeSelector: {}

## Node tolerations for server scheduling to nodes with taints
## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
##
tolerations: []
# - key: null
#   operator: Exists
#   effect: "NoSchedule"

## Affinity and anti-affinity
## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
##
affinity: {}

## Annotations to be added to fluentd pods
##
podAnnotations: {}

## Labels to be added to fluentd pods
##
podLabels: {}

## Additional environment variables to set for fluentd pods
env:
- name: "FLUENTD_CONF"
  value: "../../etc/fluent/fluent.conf"
- name: FLUENT_ELASTICSEARCH_HOST
  value: "elasticsearch-master-0.elasticsearch-master.logging.svc.cluster.local"
- name: FLUENT_ELASTICSEARCH_PORT
  value: "9200"

envFrom: []

volumes:
- name: varlog
  hostPath:
    path: /var/log
- name: varlibdockercontainers
  hostPath:
    path: /var/lib/docker/containers
- name: etcfluentd-main
  configMap:
    name: fluentd-main
    defaultMode: 0777
- name: etcfluentd-config
  configMap:
    name: fluentd-config
    defaultMode: 0777

volumeMounts:
- name: varlog
  mountPath: /var/log
- name: varlibdockercontainers
  mountPath: /var/lib/docker/containers
  readOnly: true
- name: etcfluentd-main
  mountPath: /etc/fluent
- name: etcfluentd-config
  mountPath: /etc/fluent/config.d/

## Fluentd service
##
service:
  type: "ClusterIP"
  annotations: {}
  ports: []
  # - name: "forwarder"
  #   protocol: TCP
  #   containerPort: 24224

## Prometheus Monitoring
##
metrics:
  serviceMonitor:
    enabled: false
    additionalLabels:
      release: prometheus-operator
    namespace: ""
    namespaceSelector: {}
    ## metric relabel configs to apply to samples before ingestion.
    ##
    metricRelabelings: []
    # - sourceLabels: [__name__]
    #   separator: ;
    #   regex: ^fluentd_output_status_buffer_(oldest|newest)_.+
    #   replacement: $1
    #   action: drop
    ## relabel configs to apply to samples after ingestion.
    ##
    relabelings: []
    # - sourceLabels: [__meta_kubernetes_pod_node_name]
    #   separator: ;
    #   regex: ^(.*)$
    #   targetLabel: nodename
    #   replacement: $1
    #   action: replace
    ## Additional serviceMonitor config
    ##
    # jobLabel: fluentd
    # scrapeInterval: 30s
    # scrapeTimeout: 5s
    # honorLabels: true

  prometheusRule:
    enabled: false
    additionalLabels: {}
    namespace: ""
    rules: []
    # - alert: FluentdDown
    #   expr: up{job="fluentd"} == 0
    #   for: 5m
    #   labels:
    #     context: fluentd
    #     severity: warning
    #   annotations:
    #     summary: "Fluentd Down"
    #     description: "{{ $labels.pod }} on {{ $labels.nodename }} is down"
    # - alert: FluentdScrapeMissing
    #   expr: absent(up{job="fluentd"} == 1)
    #   for: 15m
    #   labels:
    #     context: fluentd
    #     severity: warning
    #   annotations:
    #     summary: "Fluentd Scrape Missing"
    #     description: "Fluentd instance has disappeared from Prometheus target discovery"

## Grafana Monitoring Dashboard
##
dashboards:
  enabled: "false"
  namespace: ""
  labels:
    grafana_dashboard: '"1"'

## Fluentd list of plugins to install
##
plugins: []
# - fluent-plugin-out-http

## Add fluentd config files from K8s configMaps
##
configMapConfigs:
  - fluentd-prometheus-conf
# - fluentd-systemd-conf

## Fluentd configurations:
##
fileConfigs:
  01_sources.conf: |-
    ## logs from podman
    <source>
      @type tail
      @id in_tail_container_logs
      @label @KUBERNETES
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type multi_format
        <pattern>
          format json
          time_key time
          time_type string
          time_format "%Y-%m-%dT%H:%M:%S.%NZ"
          keep_time_key false
        </pattern>
        <pattern>
          format regexp
          expression /^(?<time>.+) (?<stream>stdout|stderr)( (.))? (?<log>.*)$/
          time_format '%Y-%m-%dT%H:%M:%S.%NZ'
          keep_time_key false
        </pattern>
      </parse>
      emit_unmatched_lines true
    </source>
  02_filters.conf: |-
    <label @KUBERNETES>
      <match kubernetes.var.log.containers.fluentd**>
        @type relabel
        @label @FLUENT_LOG
      </match>
      # <match kubernetes.var.log.containers.**_kube-system_**>
      #   @type null
      #   @id ignore_kube_system_logs
      # </match>
      <filter kubernetes.**>
        @type kubernetes_metadata
        @id filter_kube_metadata
        skip_labels false
        skip_container_metadata false
        skip_namespace_metadata true
        skip_master_url true
      </filter>
      <match **>
        @type relabel
        @label @DISPATCH
      </match>
    </label>
  03_dispatch.conf: |-
    <label @DISPATCH>
      <filter **>
        @type prometheus
        <metric>
          name fluentd_input_status_num_records_total
          type counter
          desc The total number of incoming records
          <labels>
            tag 1
            hostname 1
          </labels>
        </metric>
      </filter>
      <match **>
        @type relabel
        @label @OUTPUT
      </match>
    </label>
  04_outputs.conf: |-
    <label @OUTPUT>
      <match **>
        @type elasticsearch
        host "elasticsearch-master"
        port 9200
        path ""
        user elastic
        password changeme
      </match>
    </label>

  EOF
   ]
 }
