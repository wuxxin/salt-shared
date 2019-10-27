# k3s

## Additional Components
    + examples, see https://github.com/danderson/homelab/blob/master/website/content/stack.md
    + Load Balancer & router
        + A network load-balancer implementation for Kubernetes using standard routing protocols
            + https://metallb.universe.tf/
        + https://github.com/cloudnativelabs/kube-router
    + External DNS
        + https://github.com/kubernetes-incubator/external-dns
    + storage
        + local storage provisioner
            + hostpath based but with claims: https://github.com/rancher/local-path-provisioner
            + https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner
        + Storage Orchestration for Kubernetes:
            + https://rook.io using http://edgefs.io/
    + authentification
        + OpenID Connect Identity (OIDC) and OAuth 2.0 Provider with Pluggable Connectors
            + https://github.com/dexidp/dex
        + An application that can be used to easily enable authentication flows via OIDC for a kubernetes cluster.
            + https://github.com/heptiolabs/gangway
    + sandboxing
        + https://github.com/google/gvisor
    + database
        + cloud native postgresql compatible database (can be managed by rook.io)
            + https://github.com/yugabyte/yugabyte-db
        + https://github.com/CrunchyData/postgres-operator
    + Metric Gathering
        + Prometheus, Grafana
        + A multitenant, horizontally scalable Prometheus as a Service
            + https://github.com/cortexproject/cortex
        + Thanos is a set of components that can be composed into a highly available metric system with unlimited storage capacity, which can be added seamlessly on top of existing Prometheus deployments.
            + https://github.com/thanos-io/thanos
    + Certificates
        + Traefik 2.x with ALPN-TLS
            + https://docs.traefik.io/
        + https://github.com/jetstack/cert-manager
    + Install and Update- CI
        + Kured (KUbernetes REboot Daemon) is a Kubernetes daemonset that performs safe automatic node reboots when the need to do so is indicated by the package management system of the underlying OS.
            + https://github.com/weaveworks/kured
        + https://keel.sh/
        + https://github.com/fluxcd/helm-operator-get-started
    + ingress
        + https://docs.traefik.io/
        + https://www.envoyproxy.io/
        + https://github.com/kubernetes/ingress-nginx
        + https://github.com/appscode/voyager
        + https://github.com/jcmoraisjr/haproxy-ingress
    + service mesh
        + https://linkerd.io/
        + https://docs.mae.sh/
        + https://github.com/istio/istio
    + backup (with restic)
        + https://github.com/vmware-tanzu/velero
        + https://github.com/vshn/k8up
    + security
        + kubernet config check
            + https://github.com/derailed/popeye
            + https://github.com/zegl/kube-score
        + static container security analyse
            + https://github.com/coreos/clair
        + An auditing system for Kubernetes
            + https://github.com/k8guard/k8guard-start-from-here
        + kube-bench is a Go application that checks whether Kubernetes is deployed securely
            + https://github.com/aquasecurity/kube-bench
        + https://github.com/target/portauthority
    + scheduling
        + https://github.com/kubernetes-sigs/descheduler
    + Machine Net-booting, not directly related to k8s, but useful
        + Pixiecore is an tool to manage network booting of machines.
            + https://github.com/danderson/netboot/tree/master/pixiecore
        + pxe,tftp,http metal provisioner
            + https://github.com/digitalrebar/provision
    + modules needed for production rollout
        + mail service for cluster
        + secret service via vault
        + container registry
        + oauth/openid proxy -> google-gsuite
    + unsorted
        + conformance test
            + https://github.com/heptio/sonobuoy  
        + local develop with remote Cluster
            + https://github.com/telepresenceio/telepresence
        + make a kublet available for cloud k8s   
            + https://github.com/virtual-kubelet/virtual-kubelet
        + system info
            + https://github.com/draios/sysdig
        + apt_repository: repo="deb http://apt.kubernetes.io/ kubernetes-xenial main"

## kernel modules to be loaded at start

```
overlay br_netfilter nf_conntrack ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh
```
## production todo

## errors

+ [kubelet.go:1327] Failed to start ContainerManager failed to get rootfs info: cannot find filesystem info for device "rpool/data/lxd/containers/k3"
    + add zfs devices (FIXME: is unsafe, but k3s needs it for fsinfo /)

## warnings

+ [manager.go:326] Could not configure a source for OOM detection, disabling OOM events: open /dev/kmsg: no such file or directory
+ write /proc/self/oom_score_adj: permission denied


## install k3s

# create lxd machine

lxc launch ubuntu-daily:eoan k3s -p default -p nested -p network_extra -p phy_eth1 -p zfs_device
lxc file push /usr/local/lib/docker-custom-archive k3s/usr/local/lib/ -r
lxc file push /etc/apt/sources.list.d/local-docker-custom.list k3s/etc/apt/sources.list.d/
lxc shell k3s

# add symlink for missing kmsg to console
echo 'L /dev/kmsg - - - - /dev/console' > /etc/tmpfiles.d/kmsg.conf
systemd-tmpfiles  --create

# install prerequisites
DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt -y install thin-provisioning-tools bridge-utils ebtables squashfs-tools  snapd- --purge
# criu

# configure eth1
cat > /etc/netplan/60-phyeth1.yaml << EOF
network:
    version: 2
    ethernets:
        phyeth1:
            dhcp4: true
EOF
netplan generate
netplan apply

# add hostname k3s to /etc/hosts, is needed by containerd to find internal interface 
default_iface=$(cat /proc/net/route | \
    grep -E -m 1 "^[^[:space:]]+[[:space:]]+00000000" | \
    sed -r "s/^([^[:space:]]+).*/\1/g")
default_cidr=$(ip addr show dev "$default_iface" | \
    grep -E -m 1 "^[[:space:]]+inet[[:space:]]" | \
    sed -r "s/^[[:space:]]+inet[[:space:]]+(.+)[[:space:]]+brd.*/\1/g")
default_ip=$(echo "$default_cidr" | sed -E "s#^([^/]+)/.*#\1#g")
echo "$default_ip k3s" >> /etc/hosts

# install k3s
curl -sfL https://get.k3s.io -o install-k3s.sh
chmod +x install-k3s.sh
#export INSTALL_K3S_VERSION="v0.10.0"
export INSTALL_K3S_EXEC="server --no-deploy=servicelb --no-deploy=traefik --node-ip $default_ip --tls-san $default_ip --bind-address $default_ip"
#export INSTALL_K3S_EXEC="server --no-deploy=servicelb --node-ip $default_ip --tls-san $default_ip --bind-address $default_ip"
./install-k3s.sh 

# optional install of docker (to have a second container technology)
mkdir -p /etc/docker
cat - > /etc/docker/daemon.json <<"EOF"
{
	"experimental": true,
	"features": {"buildkit": true},
	"storage-driver": "overlay2",
	"log-driver": "syslog"
}
EOF
apt-get install docker.io


# test cluster is running
kubectl cluster-info
kubectl --all-namespaces=true get all
# copy kubernets config to user root
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config


# install helm (without tiller)
curl -sfL "https://git.io/get_helm.sh" -o get_helm.sh
chmod +x get_helm.sh
./get_helm.sh  -v "v3.0.0-beta.5"
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update


# install rancher local path provisioner via helm from git
# SKIP THIS, as newest k3s has it buildin
cat > ~/values-local-path-provisioner.yaml << EOF
storageClass:
  defaultClass: true
  provisionerName: rancher.io/local-path
EOF
if test -e local-path-provisioner; then rm -r local-path-provisioner; fi
git clone https://github.com/rancher/local-path-provisioner.git
cd local-path-provisioner
helm install --namespace local-path-storage local-path-storage ./deploy/chart/ -f ../values-local-path-provisioner.yaml
cd ..


# install metallb loadbalancer
cat > ~/configinline-metallb-10.9.8.32.yaml << EOF
configInline:
  address-pools:
  - name: default
    protocol: layer2
    addresses:
    - 10.9.8.32/32
EOF
helm install -f configinline-metallb-10.9.8.32.yaml metallb stable/metallb
# more up2date chart inside repo of metallb
# https://github.com/danderson/metallb/tree/master/helm-chart


# install new traefik 2.x as ingress
cat > ~/values-traefik.yaml << EOF
service:
  externalTrafficPolicy: Local
  #  externalTrafficPolicy: Cluster
  annotations:
    metallb.universe.tf/allow-shared-ip: "true"
EOF
helm repo add traefik https://github.com/containous/traefik-helm-chart.git
helm repo update
helm install --values values-traefik.yaml traefik stable/traefik 


----
# deprecated
cat > ~/traefik-dashboard.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: traefik-dashboard
  namespace: kube-system
spec:
  selector:
    app: traefik
  ports:
  - name: dash
    port: 80
    targetPort: 8080
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-dashboard
  namespace: kube-system
  kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: traefik.k3s.lan
    http:
      paths:
      - path: /
        backend:
          serviceName: traefik-dashboard
          servicePort: dash
EOF
kubectl apply -f traefik-dashboard.yaml




-----
# install keel
cat > ~/values-keel.yaml << EOF
image:
  # get new dashboard, only available in latest
  tag: latest
persistance:
  enabled: true
basicauth:
  enabled: true
  user: "admin"
  password: "admin"
  # XXX insecure testing password
ingress:
  enabled: false
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
helm repo add keel-charts https://charts.keel.sh 
helm repo update
helm upgrade --install keel keel-charts/keel --namespace=kube-system --values values-keel.yaml


cat > ~/keel-dashboard.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: keel-dashboard
  namespace: kube-system
spec:
  selector:
    app: keel
  ports:
  - name: dashboard
    port: 80
    targetPort: 9300
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: keel-dashboard
  namespace: kube-system
spec:
  rules:
  - host: keel.k3s.lan
    http:
      paths:
      - path: /
        backend:
          serviceName: keel-dashboard
          servicePort: dashboard
EOF
kubectl apply -f keel-dashboard.yaml


----
# install log tail for k8s
wget https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod +x kubetail && mv kubetail /usr/local/bin



## install kubernetes dashboard
cat > dashboard-adminuser.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
EOF
cat > rbac-cluster-admin.yaml << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOF
kubectl apply -f dashboard-adminuser.yaml 
kubectl apply -f rbac-cluster-admin.yaml 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta5/aio/deploy/recommended.yaml

-----
on lxc host:
lxc file pull k3s/root/.kube/config .
install -o wuxxin -g wuxxin config /home/wuxxin/.kube/config

-----
on lxc host as user wuxxin:
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
kubectl proxy &
firefox http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/



---- 
## install mattermost
# XXX insecure testing passwords
cat > ~/values-mattermost.yaml << EOF
mysql:
  mysqlUser: mattermost
  mysqlPassword: "X8M1NX37945O"
ingress:
  enabled: "true"
  hosts:
    - mattermost.k3s.lan
configJSON:
  EmailSettings:
    InviteSalt: z0TREsyHk1VhA4zqPbch5kBbrn901C0w
  FileSettings:
    PublicLinkSalt: CLjCuY00PXE73gNKUOsAkthk3Pv8Ni5g
  SqlSettings:
    AtRestEncryptKey: YzdnsT8UcsDrp1bd50FXFAjFxxToh1l9
EOF
helm repo add mattermost https://helm.mattermost.com
helm repo update
helm install mattermost mattermost/mattermost-team-edition --values values-mattermost.yaml


----
## install node-red
cat > ~/values-node-red.yaml << EOF
ingress:
  enabled: "true"
  hosts:
    - nodered.k3s.lan
persistence:
  enabled: "true"
EOF
helm install nodered stable/node-red --values values-node-red.yaml


----
## install codimd
cat > ~/values-codimd.yaml << EOF
image:
  repository: quay.io/codimd/server
  tag: 1.5-alpine
service:
  name: codimd
ingress:
  enabled: "true"
  hosts:
    - codimd.k3s.lan
EOF
helm install codimd stable/hackmd --values values-codimd.yaml


----
## install scope
cat > ~/values-scope.yaml << EOF
ingress:
  enabled: "true"
  hosts:
    - scope.k3s.lan
EOF
helm install scope stable/weave-scope --values values-scope.yaml


----

## install ghost
# symlink '/bitnami/ghost/content' -> '/opt/bitnami/ghost/content'

cat > ~/values-ghost.yaml << EOF
# XXX insecure testing passwords
ghostUsername: admin
ghostPassword: admin
ghostHost: ghost.k3s.lan
ingress:
  enabled: "true"
  hosts:
    - name: ghost.k3s.lan
service:
  type: ClusterIP
EOF
helm install ghost stable/ghost --values values-ghost.yaml


----
cat > ~/values-wordpress.yaml << EOF
ingress:
  enabled: "true"
  hosts:
    - name: wordpress.k3s.lan
service:
  type: ClusterIP
EOF
helm install wordpress stable/wordpress --values values-wordpress.yaml


----
# add quay helm registry plugin
mkdir -p ~/.helm/plugins/
cd ~/.helm/plugins/ && git clone https://github.com/app-registry/appr-helm-plugin.git registry
helm registry --help
helm registry list quay.io


----
