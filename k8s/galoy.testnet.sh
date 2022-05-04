# Testnet LND connected to the bitcoin node on the host

# vars
localip=$(hostname -I | awk '{print $1}')
rpcpass=$(sudo cat /mnt/hdd/bitcoin/bitcoin.conf | grep rpcpassword | cut -c 13-)

#TODO check for LAN RPC connection
## bitcoind on the raspiblitz node needs:
localip=$(hostname -I | awk '{print $1}')
echo "\
test.rpcbind=${localip}:18332
test.zmqpubrawblock=tcp://${localip}:21332
test.zmqpubrawtx=tcp://${localip}:21333
" | sudo tee -a /mnt/hdd/bitcoin/bitcoin.conf
sudo systemctl restart tbitcoind
############

## charts
helm repo add galoy-repo https://github.com/GaloyMoney/charts
## add the bitnami charts https://charts.bitnami.com/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

## bitcoind - on the host
#helm install bitcoind galoy-repo/bitcoin
## create secrets instead of bitcoind
rpcpass=$(sudo cat /mnt/hdd/bitcoin/bitcoin.conf | grep rpcpassword | cut -c 13-)
kubectl create secret generic network -n test \
  --from-literal=network=testnet
kubectl create secret generic bitcoind-rpcpassword -n test \
  --from-literal=password="${rpcpass}"

## lnd
## values
localip=$(hostname -I | awk '{print $1}')
echo "\
configmap:
  customValues:
    - bitcoin.testnet=true
    - bitcoind.rpchost=${localip}:18332
    - bitcoind.zmqpubrawblock=tcp://${localip}:21332
    - bitcoind.zmqpubrawtx=tcp://${localip}:21333
    - db.bolt.auto-compact=true
    - bitcoind.rpcuser=raspibolt
autoGenerateSeed:
    enabled: true
loop:
  enabled: false
lndmon:
  enabled: false
" | tee tlndvalues.yaml
## install
helm install lnd1 -f tlndvalues.yaml --namespace test galoy-repo/lnd --create-namespace 

## save seed and unlock password
mkdir -p ~/test-secrets/lnd
kubectl -n test logs lnd1-0 -c init-wallet >> ~/test-secrets/lnd/tlnd1seed.txt
cat ~/test-secrets/lnd/tlnd1seed.txt
kubectl -n test get secret lnd1-pass -o jsonpath='{.data.password}' | base64 -d >> ~/test-secrets/lnd/tlnd1walletpassword.txt
cat ~/test-secrets/lnd/tlnd1walletpassword.txt

## galoy
## secrets
mkdir -p ~/test-secrets/tgaloy-mongodb
cd ~/test-secrets/tgaloy-mongodb
echo -n "$(openssl rand -hex 64)" > ./mongodb-password
echo -n "$(openssl rand -hex 64)" > ./mongodb-root-password
echo -n "$(openssl rand -hex 64)" > ./mongodb-replica-set-key
kubectl -n test create secret generic galoy-mongodb \
  --from-file=./mongodb-password \
  --from-file=./mongodb-root-password \
  --from-file=./mongodb-replica-set-key

mkdir -p ~/test-secrets/tgaloy-price-history-postgres-creds
cd ~/test-secrets/tgaloy-price-history-postgres-creds
echo -n "$(openssl rand -hex 48)" > ./password
kubectl -n test create secret generic galoy-price-history-postgres-creds \
  --from-file=./password \
  --from-literal=username=price-history \
  --from-literal=database=price-history

# for trigger
kubectl -n test  create secret generic gcs-sa-key

# for galoy-pre-migration-backup-1
kubectl -n test  create secret generic dropbox-access-token \
  --from-literal=token=''
# kubectl create secret generic geetest-key
#   --from-literal=key='dummy' \
#   --from-literal=id='dummy'

cd

# galoy
echo "\
global:
  network: testnet
galoy:
  name: 'Testnet Wallet'
bitcoind:
  port: 18332
needFirebaseServiceAccount: false
twilio: false
devDisableMongoBackup: true
" | tee tgaloyvalues.yaml

helm install galoy -f tgaloyvalues.yaml -n test galoy-repo/galoy


if [ "$1" = off ]; then
  stop_terminated_pods() {
   # Define namespace
   namespace="test"
   # Get all pods in Terminated / Evicted State
   epods=$(kubectl get pods -n ${namespace} | egrep -i 'Terminating|Terminated|Evicted' | awk '{print $1 }')
   # Force deletion of the pods
   for i in ${epods[@]}; do
     kubectl delete pod --force=true --wait=false --grace-period=0 $i -n ${namespace}
   done
  }

  # LND
  helm uninstall lnd1 --wait=false
  stop_terminated_pods

# delete galoy storage
for i in $(kubectl -n test get pvc | grep galoy | awk '{print $1}' ); do kubectl -n test delete pvc ${i}; done

# in filesystem (skip lnd)
for i in $(sudo ls /var/snap/microk8s/common/default-storage/ | grep test | grep -v lnd ); do sudo rm -rf /var/snap/microk8s/common/default-storage/${i}; done

# delete the manually generated secrets
kubectl -n test delete secret galoy-mongodb


fi


