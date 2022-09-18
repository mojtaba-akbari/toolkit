resource "helm_release" "haproxy" {
  name             = "haproxy"
  chart            = "bitnami/haproxy"
  version          = "0.2.15"
  namespace        = "core"
  create_namespace = true
  wait             = "false"
  depends_on       = [null_resource.redis_community]
  values = [<<EOF

# Copyright 2020 HAProxy Technologies LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Default values for HAProxy

## Configure Service Account
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
serviceAccount:
  create: true
  name:

## Default values for image
image:
  repository: bitnami/haproxy    # can be changed to use CE or EE images
  tag: 2.4.7-debian-10-r1
  pullPolicy: IfNotPresent

## Deployment or DaemonSet pod mode
## ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
## ref: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
kind: Deployment    # can be 'Deployment' or 'DaemonSet'
replicaCount: 1   # used only for Deployment mode

# livenessProbe to deployment and daemonset
livenessProbe:
  enabled: false
  failureThreshold: 3
  successThreshold: 1
  initialDelaySeconds: 15
  timeoutSeconds: 1
  tcpSocket:
    port: 1024   # modify to your config
  periodSeconds: 20

## DaemonSet configuration
## ref: https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/
daemonset:
  useHostNetwork: false   # also modify dnsPolicy accordingly
  useHostPort: false
  hostPorts:
    http: 80
    https: 443
    stat: 1024

## Init Containers
## ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
initContainers: []
# - name: sysctl
#   image: "busybox:musl"
#   command:
#     - /bin/sh
#     - -c
#     - sysctl -w net.core.somaxconn=65536
#   securityContext:
#     privileged: true

## Pod termination grace period
## ref: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/
terminationGracePeriodSeconds: 60

## Private Registry configuration
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
imageCredentials:
  registry: null    ## EE images require setting this
  username: null    ## EE images require setting this
  password: null    ## EE images require setting this
existingImagePullSecret: null

## Container listener port configuration
## ref: https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/
containerPorts:   # has to match hostPorts when useHostNetwork is true
    - name: http
      containerPort: 80
    - name: https
      containerPort: 443
    - name: stat
      containerPort: 1024
    - name: redis1
      containerPort: 8001
    - name: redis2
      containerPort: 8002
    - name: redis3
      containerPort: 8003

## Deployment strategy definition
## ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy
strategy: {}
#  rollingUpdate:
#    maxSurge: 25%
#    maxUnavailable: 25%
#  type: RollingUpdate

## Pod PriorityClass
## ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/#priorityclass
priorityClassName: ""

## Container lifecycle handlers
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/
lifecycle: {}
  ## Example preStop for graceful shutdown
  # preStop:
  #   exec:
  #     command: ["/bin/sh", "-c", "kill -USR1 $(pidof haproxy); while killall -0 haproxy; do sleep 1; done"]

## Additional volumeMounts to the controller main container
extraVolumeMounts: []
## Example empty volume mounts when using securityContext->readOnlyRootFilesystem
# - name: etc-haproxy
#   mountPath: /etc/haproxy
# - name: tmp
#   mountPath: /tmp
# - name: var-state-haproxy
#   mountPath: /var/state/haproxy

## Additional volumes to the controller pod
extraVolumes: []
## Example empty volumes when using securityContext->readOnlyRootFilesystem
# - name: etc-haproxy
#   emptyDir: {}
# - name: tmp
#   emptyDir: {}
# - name: var-state-haproxy
#   emptyDir: {}

## HAProxy daemon configuration
# ref: https://www.haproxy.org/download/2.2/doc/configuration.txt
configuration: |
  global
    log stdout format raw local0
    maxconn 1024
  defaults
    log global
    timeout client 60s
    timeout connect 60s
    timeout server 60s
  resolvers dnsdirect
      nameserver dns1 10.96.0.10:53
      accepted_payload_size 8192
  frontend ft_redis1
    bind 0.0.0.0:8001 name redis1
    default_backend bk_redis1
  backend bk_redis1
    mode tcp
    option tcp-check
    tcp-check connect
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    tcp-check send info\ replication\r\n
    tcp-check expect string role:master
    tcp-check send QUIT\r\n
    tcp-check expect string +OK
    server redis-1 redis-redis-cluster-0.redis-redis-cluster-headless.redis-cluster.svc.cluster.local:6379 check resolvers dnsdirect inter 2s rise 3 fall 3
    server redis-2 redis-redis-cluster-4.redis-redis-cluster-headless.redis-cluster.svc.cluster.local:6379 check resolvers dnsdirect inter 2s rise 3 fall 3
  frontend ft_redis2
    bind 0.0.0.0:8002 name redis2
    default_backend bk_redis2
  backend bk_redis2
    mode tcp
    option tcp-check
    tcp-check connect
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    tcp-check send info\ replication\r\n
    tcp-check expect string role:master
    tcp-check send QUIT\r\n
    tcp-check expect string +OK
    server redis-3 redis-redis-cluster-1.redis-redis-cluster-headless.redis-cluster.svc.cluster.local:6379 check resolvers dnsdirect inter 2s rise 3 fall 3
    server redis-4 redis-redis-cluster-5.redis-redis-cluster-headless.redis-cluster.svc.cluster.local:6379 check resolvers dnsdirect inter 2s rise 3 fall 3
  frontend ft_redis3
    bind 0.0.0.0:8003 name redis3
    default_backend bk_redis3
  backend bk_redis3
    mode tcp
    option tcp-check
    tcp-check connect
    tcp-check send PING\r\n
    tcp-check expect string +PONG
    tcp-check send info\ replication\r\n
    tcp-check expect string role:master
    tcp-check send QUIT\r\n
    tcp-check expect string +OK
    server redis-5 redis-redis-cluster-2.redis-redis-cluster-headless.redis-cluster.svc.cluster.local:6379 check resolvers dnsdirect inter 2s rise 3 fall 3
    server redis-6 redis-redis-cluster-3.redis-redis-cluster-headless.redis-cluster.svc.cluster.local:6379 check resolvers dnsdirect inter 2s rise 3 fall 3


## Additional secrets to mount as volumes
## This is expected to be an array of dictionaries specifying the volume name, secret name and mount path

mountedSecrets: []
#  - volumeName: ssl-certificate
#    secretName: star-example-com
#    mountPath: /usr/local/etc/ssl

## Pod Node assignment
## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
nodeSelector: {}

## Node Taints and Tolerations for pod-node cheduling through attraction/repelling
## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
tolerations: []
#  - key: "key"
#    operator: "Equal|Exists"
#    value: "value"
#    effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

## Node Affinity for pod-node scheduling constraints
## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
affinity: {}

## Pod DNS Config
## ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
dnsConfig: {}

## Pod DNS Policy
## Change this to ClusterFirstWithHostNet in case you have useHostNetwork set to true
## ref: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy
dnsPolicy: ClusterFirst

## Additional labels to add to the pod container metadata
## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
podLabels: {}
#  key: value

## Additional annotations to add to the pod container metadata
## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
podAnnotations: {}
#  key: value

## Disableable use of Pod Security Policy
## ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/
podSecurityPolicy:
  create: true

## Pod Security Context
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
podSecurityContext: {}

## Container Security Context
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
securityContext:
  enabled: false
  runAsUser: 1000
  runAsGroup: 1000

## Compute Resources
## ref: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
resources:
#  limits:
#    cpu: 100m
#    memory: 64Mi
  requests:
    cpu: 100m
    memory: 64Mi

## Horizontal Pod Scaler
## Only to be used with Deployment kind
## ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 7
  targetCPUUtilizationPercentage: 80
  # targetMemoryUtilizationPercentage: 80

## Pod Disruption Budget
## Only to be used with Deployment kind
## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/
PodDisruptionBudget:
  enable: false
  # maxUnavailable: 1
  # minAvailable: 1

## Service configuration
## ref: https://kubernetes.io/docs/concepts/services-networking/service/
service:
  type: ClusterIP   # can be 'LoadBalancer'
  ## Service ClusterIP
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/
  clusterIP: ""

  ## LoadBalancer IP
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
  loadBalancerIP: ""

  ## Source IP ranges permitted to access Network Load Balancer
  # ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-cloud-provider-firewall/
  loadBalancerSourceRanges: []

  ## Service annotations
  ## ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/
  annotations: {}

  ## Service externalTrafficPolicy
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#external-traffic-policy
  # externalTrafficPolicy: Cluster
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: http
    - name: https
      protocol: TCP
      port: 443
      targetPort: https
    - name: stats
      protocol: TCP
      port: 1024
      targetPort: 1024
    - name: redis1
      protocol: TCP
      port: 8001
      targetPort: 8001
    - name: redis2
      protocol: TCP
      port: 8002
      targetPort: 8001
    - name: redis3
      protocol: TCP
      port: 8003
      targetPort: 8001

   EOF
  ]
}
