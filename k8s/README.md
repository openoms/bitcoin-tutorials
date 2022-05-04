<!-- omit in toc -->
# Kubernetes - Helm tips

- [kubectl cheat sheet](#kubectl-cheat-sheet)
- [Install microk8s and helm on Debian 11 - RaspiBlitz](#install-microk8s-and-helm-on-debian-11---raspiblitz)
  - [Install on a working raspiblitz system: install.microk8s.sh](#install-on-a-working-raspiblitz-system-installmicrok8ssh)
  - [install on pure Debian 11 (eg Digital Ocean)](#install-on-pure-debian-11-eg-digital-ocean)
- [Using the Galoy Helm charts](#using-the-galoy-helm-charts)
  - [install the Galoy charts repo](#install-the-galoy-charts-repo)
- [Bitcoind in kubernetes helm](#bitcoind-in-kubernetes-helm)
  - [install](#install)
  - [monitor](#monitor)
  - [copy the chain from an external source (optional to speed up sync)](#copy-the-chain-from-an-external-source-optional-to-speed-up-sync)
  - [get bitcoind password](#get-bitcoind-password)
  - [modify the stateful set](#modify-the-stateful-set)
- [LND](#lnd)
  - [activate mainnet and the automatic seed creation with an added yaml file](#activate-mainnet-and-the-automatic-seed-creation-with-an-added-yaml-file)
  - [check template](#check-template)
  - [install with the overriding setting](#install-with-the-overriding-setting)
- [get seed and delete](#get-seed-and-delete)
  - [lncli command line inside the pod](#lncli-command-line-inside-the-pod)
  - [lncli through the RPC interface (needs a local lncli in the PATH of the host like on a raspiblitz)](#lncli-through-the-rpc-interface-needs-a-local-lncli-in-the-path-of-the-host-like-on-a-raspiblitz)
    - [credentials for local user (using the k8s user)](#credentials-for-local-user-using-the-k8s-user)
    - [Forward a local port to container port](#forward-a-local-port-to-container-port)
    - [Run lncli](#run-lncli)
    - [Create wallet](#create-wallet)
  - [Monitor](#monitor-1)
  - [lnd autounlock password from the secrets](#lnd-autounlock-password-from-the-secrets)
    - [get current](#get-current)
    - [to modify the password manually:](#to-modify-the-password-manually)
- [Loop](#loop)
  - [Monitor](#monitor-2)
  - [stateful set](#stateful-set)
  - [cli](#cli)
- [Secrets](#secrets)
  - [create](#create)
  - [Decode to view](#decode-to-view)
  - [Edit](#edit)
- [Debug](#debug)
  - [Troubleshooting](#troubleshooting)
  - [Check pods](#check-pods)
  - [Stop terminated pods](#stop-terminated-pods)
  - [Status](#status)
- [Dashboard](#dashboard)
- [OS level tweaks](#os-level-tweaks)
  - [Increase open file limits](#increase-open-file-limits)
  - [Free space without restart](#free-space-without-restart)
  - [Directories taking space](#directories-taking-space)
  - [Change microk8s default-storage path in config](#change-microk8s-default-storage-path-in-config)
- [Networking](#networking)
  - [External Service ports](#external-service-ports)
  - [check local tbitcoind](#check-local-tbitcoind)
- [Testnet LND connected to the bitcoin node on the host](#testnet-lnd-connected-to-the-bitcoin-node-on-the-host)
  - [save seed and unlock password](#save-seed-and-unlock-password)
  - [change the wallet unlock password](#change-the-wallet-unlock-password)
  - [restart](#restart)
  - [logs](#logs)
  - [cli](#cli-1)
- [testnet Galoy](#testnet-galoy)
  - [Install](#install-1)
  - [monitor](#monitor-3)
  - [remove](#remove)
- [Galoy with bitcoin and lnd on mainnet](#galoy-with-bitcoin-and-lnd-on-mainnet)
- [Galoy with bitcoin and lnd on mainnet](#galoy-with-bitcoin-and-lnd-on-mainnet-1)
- [Configure with terraform](#configure-with-terraform)
- [install terraform](#install-terraform)

# kubectl cheat sheet
* https://kubernetes.io/docs/reference/kubectl/cheatsheet/


# Install microk8s and helm on Debian 11 - RaspiBlitz

## Install on a working raspiblitz system: [install.microk8s.sh](install.microk8s.sh)
  * tested on an amd64 server Running DEbian 11 as base

## install on pure Debian 11 (eg Digital Ocean)
```
sudo adduser --disabled-password --gecos "" k8s

sudo usermod -a -G sudo,bitcoin,debian-tor k8s

sudo su - k8s

sudo apt update
sudo apt install -y snapd
sudo snap install microk8s --classic

echo 'export PATH=/snap/bin:$PATH'      >> ~/.bashrc
echo "alias kubectl='microk8s.kubectl'" >> ~/.bashrc
echo 'export KUBE_EDITOR="nano"'        >> ~/.bashrc

source ~/.bashrc

sudo usermod -a -G microk8s k8s
sudo chown -f -R k8s ~/.kube
newgrp microk8s

# microk8s.inspect
# troubleshooting steps on Debian
# https://microk8s.io/docs/troubleshooting
sudo iptables -P FORWARD ACCEPT
sudo apt-get install -y iptables-persistent
echo '{
    "insecure-registries" : ["localhost:32000"]
}
' | sudo tee -a /etc/docker/daemon.json

sudo apt install ufw
sudo ufw enable
sudo ufw allow in on vxlan.calico && sudo ufw allow out on vxlan.calico
sudo ufw allow in on cali+ && sudo ufw allow out on cali+
sudo ufw allow 16443 comment "microk8s"
sudo ufw allow 10443 comment "kubernetes-dashboard"

microk8s start

microk8s enable helm
microk8s enable dns
microk8s enable dashboard
microk8s enable storage
microk8s enable ingress
microk8s enable registry

# make the config permanent
microk8s config > ~/.kube/config
sudo chmod 0600 /home/k8s/.kube/config

# helm
sudo snap install helm --classic
```

# Using the Galoy Helm charts

## install the Galoy charts repo
```
helm repo add galoy-repo https://github.com/GaloyMoney/charts

# add the bitnami charts https://charts.bitnami.com/
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update
```

# Bitcoind in kubernetes helm
## install
```
helm install bitcoind galoy-repo/bitcoind

# bitcoind RPC can be accessed via port  on the following DNS name from within your cluster:
# bitcoind.default.svc.cluster.local
```

## monitor
```
# monitor pod
kubectl describe pod bitcoind
# logs
kubectl logs bitcoind-0 bitcoind
# same as:
sudo tail -f /var/snap/microk8s/common/default-storage/default-bitcoind-pvc-*/debug.log
```

## copy the chain from an external source (optional to speed up sync)
```
# check storage
ls -la /var/snap/microk8s/common/default-storage
# note user:group and permissions
sudo ls -la /var/snap/microk8s/common/default-storage/default-bitcoind-pvc-*

# stop with helm
helm uninstall bitcoind

# copy from clone / host (must not have bitcoind running)
# cd to the source bitcoin directory
cd /mnt/hdd/*/bitcoin

# copy ./chainstate ./blocks ./indexes recursively and verbose
sudo rsync -rv ./chainstate ./blocks ./indexes /var/snap/microk8s/common/default-storage/default-bitcoind-pvc-*/

# fix user:group
sudo chown -R user:3000 /var/snap/microk8s/common/default-storage/default-bitcoind-pvc-*
# restart with helm
helm install bitcoind galoy-repo/bitcoind
```

## get bitcoind password
```
microk8s kubectl get secret bitcoind-rpcpassword -o jsonpath='{.data.password}'
```

## modify the stateful set
```
kubectl -n default edit sts bitcoind
```

# LND
## activate mainnet and the automatic seed creation with an added yaml file
* full example: https://github.com/zoop-btc/lndchart/blob/main/myvalues.yaml
```
echo "\
configmap:
  customValues:
    - bitcoin.mainnet=true
    - bitcoind.rpchost=bitcoind:8332
    - bitcoind.zmqpubrawblock=tcp://bitcoind:28332
    - bitcoind.zmqpubrawtx=tcp://bitcoind:28333
    - minchansize=200000
    - db.bolt.auto-compact=true

autoGenerateSeed:
    enabled: true
" | tee -a lndvalues.yaml
```
## check template
```
helm template -f lndvalues.yaml galoy-repo/lnd | grep "mainnet=true" -A2 -B5
```

## install with the overriding setting
```
helm install lnd -f lndvalues.yaml galoy-repo/lnd
```
* these notes need updates (https://github.com/GaloyMoney/charts/blob/main/charts/lnd/templates/NOTES.txt):
```
NAME: lnd
LAST DEPLOYED: Wed Apr 27 19:33:40 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=lnd,app.kubernetes.io/instance=lnd" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
2. To get the TLS, run:
export TLS=$(kubectl -n default exec lnd-0 -- base64 /root/.lnd/tls.cert | tr -d '\n\r')
3. To get the macaroon, run:
export MACAROON=$(kubectl exec -n default lnd-0 -- base64 /root/.lnd/data/chain/bitcoin/mainnet/admin.macaroon | tr -d '\n\r')
4. To execute lncli against the pod, run the following commands:
kubectl -n default port-forward lnd-0 10009
lncli -n default help
5. To retrieve the seed for the lnd wallet, run:
kubectl -n default logs lnd-wallet-create
kubectl -n default delete pod lnd-wallet-create

Warning: Make sure you write/store the seed somewhere, because if lost you will not be able to retrieve it again, and you might end up losing all your funds.
```

# get seed and delete
```
kubectl -n default logs lnd-0 -c init-wallet
kubectl -n default delete pod lnd-init-wallet
```

## lncli command line inside the pod
```
# kubectl -n <lnd-namespace> exec -it <lnd-pod-name> -c lnd -- bash
kubectl -n default exec -it lnd-0 -c lnd -- bash

lncli help
```

## lncli through the RPC interface (needs a local lncli in the PATH of the host like on a raspiblitz)

### credentials for local user (using the k8s user)
```
mkdir -p ~/.lnd/data/chain/bitcoin/mainnet/

# get tls.cert
kubectl -n default exec lnd-0 -c lnd -- cat /root/.lnd/tls.cert > ~/.lnd/tls.cert

# get admin.macaroon
kubectl exec -n default lnd-0 -c lnd -- cat /root/.lnd/data/chain/bitcoin/mainnet/admin.macaroon > ~/.lnd/data/chain/bitcoin/mainnet/admin.macaroon
```
### Forward a local port to container port
* this needs to run in the background eg. in tmux)
```
kubectl -n default port-forward lnd-0 10010:10009
```
### Run lncli
```
lncli -n mainnet --rpcserver localhost:10010 state
```
### Create wallet
```
lncli -n mainnet --rpcserver localhost:10010 create
```

## Monitor
```
# logs
kubectl logs lnd-0 lnd
# same as:
sudo tail -f /var/snap/microk8s/common/default-storage/default-lnd-pvc-*/logs/bitcoin/mainnet/lnd.log

# check template
helm template lnd
# logs
kubectl -n default logs lnd-0 lnd
# describe
kubectl describe pod lnd

To debug the lnd container, you can modify the stateful set via -> kubectl -n <lnd-namespace> edit sts <lnd-sts-name> , then remove the readiness and liveness probes, override the command for the lnd container and set it to sleep 5000000 , then delete the lnd pod. Once it restarts, you can use kubectl -n <lnd-namespace> exec -it <lnd-pod-name> -c lnd -- bash
Then you can check what config is being copied by the init-container

# kubectl -n <lnd-namespace> edit sts <lnd-sts-name>
kubectl -n default edit sts lnd

# kubectl -n <lnd-namespace> exec -it <lnd-pod-name> -c lnd -- bash
kubectl -n default exec -it lnd-0 -c lnd -- bash
```


## lnd autounlock password from the secrets
### get current
* the easiest is to set this autogenerated password as the wallet unlock password when you create the wallet manually
```
# get (decode from base64)
kubectl get secret lnd-pass -o jsonpath='{.data.password}' | base64 -d
```
### to modify the password manually:
* https://stackoverflow.com/questions/37180209/kubernetes-modify-a-secret-using-kubectl

* semi-automatic method:
```
NewPassword="NEW_PASSWORD_HERE"
kubectl get secret lnd-pass -o json | jq --arg password "$(echo $NewPassword | base64)" '.data["password"]=$password' | kubectl apply -f -
```

* more manual method:
```
# what to look for:
kubectl get secret lnd-pass -o jsonpath='{.data.password}'

# encode the new password to base64 and copy
echo "new_password" | base64

# run:
kubectl edit secrets

# edit:
- apiVersion: v1
  data:
    password: base64_encoded_new_password_here
  kind: Secret
  metadata:
    annotations:
      meta.helm.sh/release-name: bitcoind
      meta.helm.sh/release-namespace: default
    creationTimestamp: "2022-04-27T16:49:53Z"
    labels:
      app.kubernetes.io/instance: bitcoind
      app.kubernetes.io/managed-by: Helm
      app.kubernetes.io/name: bitcoind
      app.kubernetes.io/version: 0.21.0
      helm.sh/chart: bitcoind-0.1.2
    name: bitcoind-rpcpassword
    namespace: default
    resourceVersion: "201394"
    selfLink: /api/v1/namespaces/default/secrets/bitcoind-rpcpassword
    uid: 9135ade7-1584-4f9b-a5f3-2b5cb4abcd0e
  type: Opaque
```

# Loop

## Monitor
kubectl logs lnd-loop-0 -f
kubectl describe pod lnd-loop-0

## stateful set
kubectl -n default edit sts lnd-loop

## cli
```
kubectl -n default exec -it lnd-loop-0 -- bash

loop --help

loopd --lnd.host=lnd:10009 --network mainnet

loop -n mainnet terms
```

# Secrets
* https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/

## create
```
# galoy-mongodb as in https://github.com/GaloyMoney/charts/blob/cc000d4f11e215892b11fc7407a4440fd4d200c8/dev/galoy/main.tf#L64

mkdir -p ~/test-secrets/galoy-mongodb
cd ~/test-secrets/galoy-mongodb

#echo -n 'testGaloy' >./username
echo -n "$(openssl rand -hex 64)" > ./mongodb-password
echo -n "$(openssl rand -hex 64)" > ./mongodb-root-password
echo -n "$(openssl rand -hex 64)" > ./mongodb-replica-set-key

kubectl create secret generic galoy-mongodb \
  --from-file=./mongodb-password \
  --from-file=./mongodb-root-password \
  --from-file=./mongodb-replica-set-key

# galoy-price-history-postgres-creds as in https://github.com/GaloyMoney/charts/blob/cc000d4f11e215892b11fc7407a4440fd4d200c8/dev/galoy/main.tf#L214

mkdir -p ~/test-secrets/galoy-price-history-postgres-creds
cd ~/test-secrets/galoy-price-history-postgres-creds

# The password cannot be longer than 100 characters.
echo -n "$(openssl rand -hex 48)" > ./password

echo -n 'price-history' > ./username
echo -n 'price-history' > ./database

kubectl create secret generic galoy-price-history-postgres-creds \
  --from-file=./password \
  --from-file=./username \
  --from-file=./database

kubectl create secret generic gcs-sa-key

kubectl create secret generic geetest-key
  --from-literal=key='dummy' \
  --from-literal=id='dummy'

kubectl create secret generic dropbox-access-token \
  --from-literal=token=''

```

## Decode to view
```
kubectl get secret galoy-price-history-postgres-creds -o jsonpath='{.data.password}' | base64 -d, echo

## compare
cat ~/test-secrets/galoy-price-history-postgres-creds/password
```

## Edit
```
kubectl edit secrets
```

# Debug
* https://devopscube.com/troubleshoot-kubernetes-pods/
## Troubleshooting
```
microk8s.inspect
```

## Check pods
```
# all pods
microk8s.kubectl get pod --all-namespaces

# watch
microk8s.kubectl get pod -Aw
```

## Stop terminated pods
* https://computingforgeeks.com/force-delete-evicted-terminated-pods-in-kubernetes/
```
stop_terminated_pods() {
 # Define namespace
 namespace="default"

 # Get all pods in Terminated / Evicted State
 epods=$(kubectl get pods -n ${namespace} | egrep -i 'Terminating|Terminated|Evicted' | awk '{print $1 }')

 # Force deletion of the pods
 for i in ${epods[@]}; do
   kubectl delete pod --force=true --wait=false --grace-period=0 $i -n ${namespace}
 done
}
```

## Status
```
microk8s.kubectl describe no
```
# Dashboard
```
microk8s dashboard-proxy

# to just get the token:
token=$(microk8s kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
microk8s kubectl -n kube-system describe secret $token
```
# OS level tweaks

## Increase open file limits
The error:
```
Failed to allocate directory watch: Too many open files
```
Check:
```
sysctl fs.inotify
```
Fix:
```
sudo sysctl fs.inotify.max_user_instances=512
```

## Free space without restart

```
sudo docker system prune -a
```

https://serverfault.com/questions/501963/how-do-i-recover-free-space-on-deleted-files-without-restarting-the-referencing

```
# check free space
df -h
# Find all opened file descriptors, grep deleted, StdError to /dev/null
sudo find /proc/*/fd -ls 2> /dev/null | grep '(deleted)'
# Find and truncate all deleted files, -p prompt before execute truncate
sudo find /proc/*/fd -ls 2> /dev/null | awk '/deleted/ {print $11}' | xargs -p -n 1 sudo truncate -s 0
df -h
```

## Directories taking space
```
/var/snap/microk8s/common/default-storage
https://github.com/canonical/microk8s/issues/463#issuecomment-491285745
sudo lsof +D /var/snap | awk '!/COMMAND/{print $1 | "sort -u"}'
```

## Change microk8s default-storage path in config
```
microk8s.kubectl -n kube-system edit deploy hostpath-provisioner
```
Change in:
```
      volumes:
      - hostPath:
          path: /mnt/ext/microk8s/common/default-storage
          type: ""
        name: pv-volume
```

# Networking
* https://webapp.io/blog/container-tcp-tunnel/
* https://betterprogramming.pub/how-to-ssh-into-a-kubernetes-pod-from-outside-the-cluster-354b4056c42b

##  External Service ports
* https://stackoverflow.com/questions/37648553/is-there-anyway-to-get-the-external-ports-of-the-kubernetes-cluster
```
kubectl describe service --all-namespaces | grep -i nodeport

# This gets all services in all namespaces, and does basically: "for each service, for each port, if nodePort is defined, print nodePort".
kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\n"}}{{end}}{{end}}{{end}}'

# this will give more information about each NodePort listed
kubectl get svc --all-namespaces -o go-template='{{range .items}}{{range.spec.ports}}{{if .nodePort}}{{.nodePort}}{{.}}{{"\n"}}{{end}}{{end}}{{end}}'
```


## check local tbitcoind
```
nc -zv localhost 18332
```

```
k8stunnel() {
    POD="$1"
    CONTAINER="$2"
    HOSTPORT="$3"
    PODPORT="$4"
    if [ -z "$POD" -o -z "$CONTAINER" -o -z "$HOSTPORT" -o -z "$PODPORT" ]; then
    	echo "Usage: k8stunnel [pod name] [container] [host port] [pod port]"
        return 1
    fi
    pkill -f 'nc 127.0.0.1 "$HOSTPORT"'
    kubectl exec -it "$POD" -c "$CONTAINER"  -- apk add ucspi-tcp6
    nc 127.0.0.1 "$HOSTPORT" | microk8s kubectl exec -it "$POD" -c "$CONTAINER" -- tcpserver 127.0.0.1 "$PODPORT" cat &
    echo "To access the host:"$HOSTPORT" Connect to 127.0.0.1:"$HOSTPORT" in the pod"
}
```

```
k8stunnel tlnd-0 lnd 18332 18332
k8stunnel tlnd-0 lnd 21332 21332
k8stunnel tlnd-0 lnd 21333 21333
```

# Testnet LND connected to the bitcoin node on the host
* [galoy.testnet.sh](galoy.testnet.sh)
## save seed and unlock password
```
kubectl -n default logs tlnd-0 -c init-wallet

kubectl get secret tlnd-pass -o jsonpath='{.data.password}' | base64 -d, echo
```
## change the wallet unlock password
* semi-automatic method:
```
NewPassword="NEW_PASSWORD_HERE"
kubectl -n test get secret lnd1-pass -o json | jq --arg password "$(echo $NewPassword | base64)" '.data["password"]=$password' | kubectl -n test apply -f -
```
## restart
```
kubectl delete pod lnd1-0 --wait=false --grace-period=0  -n test
```

## logs
```
kubectl logs lnd1-0 -n test -c lnd -f

sudo tail -f /var/snap/microk8s/common/default-storage/test-lnd1-pvc-[TAB]/logs/bitcoin/testnet/lnd.log
```
## cli
```
kubectl exec lnd1-0 -n test -c lnd  -- sh
lncli -n testnet  getinfo
```


# testnet Galoy
## Install
* create custom values
```
echo "\
global:
  network: testnet
galoy:
  name: 'Testnet Galoy Wallet'
bitcoind:
  port: 18332
needFirebaseServiceAccount: false
twilio: false
devDisableMongoBackup: true
" | tee tgaloyvalues.yaml
```
* install
```
helm install galoy -f tgaloyvalues.yaml -n test galoy-repo/galoy
```

## monitor
```
kubectl get pod -n galoy -w

kubectl get service -n galoy
```
## remove
```
helm uninstall galoy

# check pvc -s
kubectl get pvc

## CAREFUL HERE
# delete all pending storage
for i in $(kubectl get pvc | grep Pending | awk '{print $1}' ); do kubectl delete pvc ${i}; done

# delete galoy storage
for i in $(kubectl get pvc | grep galoy | awk '{print $1}' ); do kubectl delete pvc ${i}; done

# in filesystem
for i in $(sudo ls /var/snap/microk8s/common/default-storage/ | grep galoy); do sudo rm -rf /var/snap/microk8s/common/default-storage/${i}; done

# delete the manually generated secrets
kubectl delete secret galoy-mongodb
kubectl delete secret galoy-price-history-postgres-creds

sudo rm -rf /home/k8s/test-secrets
```

# Galoy with bitcoin and lnd on mainnet
```
# bitcoind
helm install bitcoind galoy-repo/bitcoin

# lnd
echo "\
configmap:
  customValues:
    - bitcoin.mainnet=true
    - bitcoind.rpchost=bitcoind:8332
    - bitcoind.zmqpubrawblock=tcp://bitcoind:28332
    - bitcoind.zmqpubrawtx=tcp://bitcoind:28333
    - minchansize=200000
    - db.bolt.auto-compact=true
autoGenerateSeed:
    enabled: true
" | tee -a lndvalues.yaml

helm install lnd -f lndvalues.yaml galoy-repo/lnd

# galoy
# secrets
mkdir -p ~/test-secrets/galoy-mongodb
cd ~/test-secrets/galoy-mongodb
echo -n "$(openssl rand -hex 64)" > ./mongodb-password
echo -n "$(openssl rand -hex 64)" > ./mongodb-root-password
echo -n "$(openssl rand -hex 64)" > ./mongodb-replica-set-key
kubectl create secret generic galoy-mongodb \
  --from-file=./mongodb-password \
  --from-file=./mongodb-root-password \
  --from-file=./mongodb-replica-set-key

mkdir -p ~/test-secrets/galoy-price-history-postgres-creds
cd ~/test-secrets/galoy-price-history-postgres-creds
echo -n "$(openssl rand -hex 48)" > ./password

kubectl create secret generic galoy-price-history-postgres-creds \
  --from-file=./password \
  --from-literal=username=price-history \
  --from-file=database=price-history

kubectl create secret generic dropbox-access-token \
  --from-literal=token=''

kubectl create secret generic gcs-sa-key

kubectl create secret generic geetest-key
  --from-literal=key='dummy' \
  --from-literal=id='dummy'


cd

echo "\
global:
  network: mainnet
bitcoind:
  port: 8332
needFirebaseServiceAccount: false
twilio: false
devDisableMongoBackup: true
" | tee galoyvalues.yaml

helm install galoy -f galoyvalues.yaml galoy-repo/galoy
```


https://learnk8s.io/a/a-visual-guide-on-troubleshooting-kubernetes-deployments/troubleshooting-kubernetes.en_en.v2.pdf



# Galoy with bitcoin and lnd on mainnet
* [galoy.testnet.sh](galoy.testnet.sh)

# Configure with terraform

# install terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```