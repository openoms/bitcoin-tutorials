<!-- omit in toc -->
# Kubernetes - Helm tips

- [Install microk8s and helm on Debian 11 - RaspiBlitz](#install-microk8s-and-helm-on-debian-11---raspiblitz)
- [Using the Galoy Helm charts](#using-the-galoy-helm-charts)
  - [Inspect chart without installing](#inspect-chart-without-installing)
  - [Install](#install)
- [Bitcoind in kubernetes helm](#bitcoind-in-kubernetes-helm)
  - [install](#install-1)
  - [monitor](#monitor)
  - [copy chain](#copy-chain)
  - [get bitcoind password](#get-bitcoind-password)
- [Secrets](#secrets)
- [Debug](#debug)
  - [Troubleshooting](#troubleshooting)
  - [Check pods](#check-pods)
  - [Status](#status)
- [Dashboard](#dashboard)
- [OS level tweaks](#os-level-tweaks)
  - [Increase open file limits](#increase-open-file-limits)
  - [Free space without restart](#free-space-without-restart)
  - [Directories taking space](#directories-taking-space)
  - [Change microk8s default-storage path in config](#change-microk8s-default-storage-path-in-config)

# Install microk8s and helm on Debian 11 - RaspiBlitz

[install.microk8s.sh](install.microk8s.sh)

# Using the Galoy Helm charts

## Inspect chart without installing
```
helm pull galoy-repo/galoy
helm show chart galoy-0.2.52.tgz
helm show values galoy-0.2.52.tgz
```
## Install

```
helm repo add galoy-repo https://github.com/GaloyMoney/charts
helm repo update
# microk8s.kubectl create namespace galoy
# helm install galoy -n galoy --set global.persistence.storageClass=microk8s-hostpath galoy-repo/galoy
# helm uninstall galoy -n galoy
helm install galoy --set global.persistence.storageClass=microk8s-hostpath galoy-repo/galoy --debug --timeout 10m

helm install galoy \
 --set needFirebaseServiceAccount=false \
 --set global.persistence.storageClass=microk8s-hostpath \
 galoy-repo/galoy --debug --timeout 10m

# needFirebaseServiceAccount: true
needFirebaseServiceAccount=false

helm install bitcoind galoy-repo/bitcoind
helm install lnd galoy-repo/lnd

helm install bitcoin galoy-repo/bitcoin

# monitor
microk8s kubectl get pod -n galoy -w

microk8s kubectl get service -n galoy
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
sudo tail -f /var/snap/microk8s/common/default-storage/default-bitcoind-pvc-*/debug.log
```

## copy chain
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

# Secrets
* https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/
```
microk8s kubectl edit secrets
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
