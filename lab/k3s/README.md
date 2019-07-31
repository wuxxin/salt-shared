# k3s

## Additional Components
    + Load Balancer & router
        + https://metallb.universe.tf/
        + https://github.com/cloudnativelabs/kube-router
    + External DNS
        + https://github.com/kubernetes-incubator/external-dns
    + local storage provisioner
        + https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner
        + hostpath based: https://github.com/rancher/local-path-provisioner
    + Certificates
        + https://github.com/jetstack/cert-manager
    + Install and Update- CI
        + https://keel.sh/
        + https://github.com/fluxcd/helm-operator-get-started
    
    + ingress
        + https://www.envoyproxy.io/
        + https://github.com/kubernetes/ingress-nginx
        + https://github.com/appscode/voyager
        + https://github.com/jcmoraisjr/haproxy-ingress
        + https://traefik.io/
    + service mesh
        + https://github.com/istio/istio
    + backup (with restic)
        + https://github.com/heptio/velero
        + https://github.com/vshn/k8up
    + kubernet config check
        + https://github.com/derailed/popeye
        + https://github.com/zegl/kube-score
    + unsorted
        + pxe,tftp,http metal provisioner
            + https://github.com/digitalrebar/provision
        + static container analyse
            + https://github.com/coreos/clair
        + conformance test
            + https://github.com/heptio/sonobuoy  
        + local develop with remote Cluster
            + https://github.com/telepresenceio/telepresence
        + make a kublet available for cloud k8s   
            + https://github.com/virtual-kubelet/virtual-kubelet
        + system info
            + https://github.com/draios/sysdig
            + 
        
## kernel modules to be loaded at start

```
overlay br_netfilter nf_conntrack ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh
```
## production todo

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.


Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation

## errors

+ [kubelet.go:1327] Failed to start ContainerManager failed to get rootfs info: cannot find filesystem info for device "rpool/data/lxd/containers/k3"
    + add zfs devices (FIXME: is unsafe, but k3s needs it for fsinfo /)

## warnings

+ [manager.go:326] Could not configure a source for OOM detection, disabling OOM events: open /dev/kmsg: no such file or directory
+ write /proc/self/oom_score_adj: permission denied
+ open /proc/sys/net/bridge/bridge-nf-call-iptables: no such file


## install k3s

# create lxd machine
lxc launch ubuntu-daily:bionic k3s -p default -p nested -p phy_eth1 -p zfs_device
```
# lxd profile
security.nesting: "true"
devices:
  zfs:
    path: /dev/zfs
    type: unix-char
  eth11:
    name: phyeth1
    nictype: physical
    parent: enp1s0
    type: nic
```
lxc file push /usr/local/lib/docker-custom-archive k3s/usr/local/lib/ -r
lxc file push /etc/apt/sources.list.d/local-docker-custom.list k3s/etc/apt/sources.list.d/
lxc shell k3s

# install prerequisites
DEBIAN_FRONTEND=noninteractive
apt-get -y update
apt -y install thin-provisioning-tools bridge-utils ebtables criu zfsutils-linux zfs-zed-

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
echo "10.140.222.162 k3s" >> /etc/hosts

# install k3s
curl -sfL https://get.k3s.io -o install-k3s.sh
chmod +x install-k3s.sh
export INSTALL_K3S_VERSION="v0.7.0"
export INSTALL_K3S_EXEC="server --no-deploy=servicelb --no-deploy=traefik --node-ip 10.140.222.162 --tls-san 10.140.222.162 --bind-address 10.140.222.162"
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


# install helm and tiller
curl -sfL "https://git.io/get_helm.sh" -o get_helm.sh
chmod +x get_helm.sh
./get_helm.sh
kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller-cluster-rule  --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --upgrade --service-account tiller
helm repo update


# helm install rancher local path provisioner
cat > ~/values-local-path-provisioner.yaml << EOF
storageClass:
  defaultClass: true
  provisionerName: rancher.io/local-path
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
if test -e local-path-provisioner; then rm -r local-path-provisioner; fi
git clone https://github.com/rancher/local-path-provisioner.git
cd local-path-provisioner
helm install --name local-path-storage --namespace local-path-storage ./deploy/chart/ -f ../values-local-path-provisioner.yaml
cd ..


# either: use preinstalled traefik
# kubectl annotate --namespace kube-system service/traefik 'metallb.universe.tf/allow-shared-ip=true'

# or: install new traefik as ingress
cat > ~/values-traefik.yaml << EOF
serviceType: LoadBalancer
externalTrafficPolicy: Local
rbac.enabled: "true"
ssl.enabled: "true"
kubernetes.ingressEndpoint.useDefaultPublishedService:  "true"
service:
  annotations:
    metallb.universe.tf/allow-shared-ip: "true"

dashboard:
  enabled: "true"
  domain: traefik.k3s.lan
  auth:
    basic:
      admin: $apr1$NmU269Gf$mvRlfXTxzmzJTfW7FknoF0

kubernetes:
  namespaces:
    - default
    - kube-system

EOF
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
helm install --namespace=kube-system --values values-traefik.yaml --name=traefik stable/traefik 


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



# install metallb loadbalancer
cat > ~/configinline-metallb-10.9.8.32.yaml << EOF
configInline:
  address-pools:
  - name: default
    protocol: layer2
    addresses:
    - 10.9.8.32/32
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
helm install --namespace=metallb-system --name=metallb -f configinline-metallb-10.9.8.32.yaml stable/metallb 
# more up2date chart inside repo of metallb
# https://github.com/danderson/metallb/tree/master/helm-chart


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
  password: "doremifaso"
ingress:
  enabled: false
  hosts: 
    - keel.k3s.lan
  annotations:
    kubernetes.io/ingress.class: traefik
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
helm repo add keel-charts https://charts.keel.sh 
helm repo update
helm upgrade --install keel --namespace=kube-system keel-charts/keel --values values-keel.yaml


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
  kubernetes.io/ingress.class: traefik
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

wget https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail
chmod +x kubetail && mv kubetail /usr/local/bin



## install kubernetes dashboard
```
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
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
kubectl proxy
firefox http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/



----



# add quay helm registry plugin
mkdir -p ~/.helm/plugins/
cd ~/.helm/plugins/ && git clone https://github.com/app-registry/appr-helm-plugin.git registry
helm registry --help
helm registry list quay.io

---- 
## install mattermost
cat > ~/values-mattermost.yaml << EOF
mysql:
  mysqlUser: mattermost
  mysqlPassword: "X8M1NX37945O"
ingress:
  enabled: "true"
  hosts:
    - mattermost.k3s.lan
  annotations:
    kubernetes.io/ingress.class: traefik
configJSON:
  EmailSettings:
    InviteSalt: z0TREsyHk1VhA4zqPbch5kBbrn901C0w
  FileSettings:
    PublicLinkSalt: CLjCuY00PXE73gNKUOsAkthk3Pv8Ni5g
  SqlSettings:
    AtRestEncryptKey: YzdnsT8UcsDrp1bd50FXFAjFxxToh1l9
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
helm install mattermost/mattermost-team-edition --name mattermost --values values-mattermost.yaml


----

## install node-red
cat > ~/values-node-red.yaml << EOF
ingress:
  enabled: "true"
  hosts:
    - node-red.k3s.lan
  annotations:
    kubernetes.io/ingress.class: traefik
persistence:
  enabled: "true"
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
helm install stable/node-red --name my-node-red --values values-node-red.yaml

----

## install codimd


cat > ~/values-codimd.yaml << EOF
image:
  repository: quay.io/codimd/server
  tag: 1.4-alpine
service:
  name: codimd
ingress:
  enabled: "true"
  hosts:
    - codimd.k3s.lan
  annotations:
    kubernetes.io/ingress.class: traefik
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
helm install stable/hackmd --name codimd --values values-codimd.yaml


----

## install scope


cat > ~/values-scope.yaml << EOF
ingress:
  enabled: "true"
  hosts:
    - scope.k3s.lan
  annotations:
    kubernetes.io/ingress.class: traefik
EOF
helm install stable/weave-scope --name scope --values values-scope.yaml


----

## install ghost
# symlink '/bitnami/ghost/content' -> '/opt/bitnami/ghost/content'

cat > ~/values-ghost.yaml << EOF
ghostUsername: admin
ghostPassword: doremifaso
ghostHost: ghost.k3s.lan
ingress:
  enabled: "true"
  hosts:
    - name: ghost.k3s.lan
  annotations:
    kubernetes.io/ingress.class: traefik
service:
  type: ClusterIP
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
helm install stable/ghost --name my-ghost --values values-ghost.yaml

----

cat > ~/values-wordpress.yaml << EOF
ingress:
  enabled: "true"
  hosts:
    - name: wordpress.k3s.lan
  annotations:
    kubernetes.io/ingress.class: traefik
service:
  type: ClusterIP
keel:
  policy: all
  images:
    - repository: image.repository
      tag: image.tag
EOF
helm install stable/wordpress --name my-wordpress --values values-wordpress.yaml

----
