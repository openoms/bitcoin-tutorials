# charts
helm repo add galoy-repo https://galoymoney.github.io/charts/

# add the bitnami charts https://charts.bitnami.com/
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

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
lnd1:
  dns: lnd1.default.svc.cluster.local
lnd2:
  dns: lnd1.default.svc.cluster.local
" | tee galoyvalues.yaml

helm install galoy -f galoyvalues.yaml galoy-repo/galoy
