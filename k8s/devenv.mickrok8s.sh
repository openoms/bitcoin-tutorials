# from install.microk8s.sh

  sudo apt install -y snapd
  sudo snap install microk8s --classic --channel=1.23/stable

  sudo adduser --disabled-password --gecos "" k8s
  sudo usermod -a -G sudo,bitcoin,debian-tor,microk8s k8s
  echo '/usr/share/doc/fzf/examples/key-bindings.bash' >> /home/k8s/.bashrc
  echo '/usr/share/doc/fzf/examples/completion.bash' >> /home/k8s/.bashrc
  echo 'export PATH=/snap/bin:$PATH' | sudo tee -a /home/k8s/.profile
  echo "\
alias kubectl='microk8s kubectl'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias g='git'
alias grep='grep --color=auto'
alias gs='git status'
alias k='kubectl'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias tf='terraform'\
" | sudo -u k8s tee -a /home/k8s/.bash_aliases

  sudo -u k8s /snap/bin/microk8s enable storage

    sudo snap install helm --classic

# https://github.com/GaloyMoney/galoy-infra/blob/main/modules/inception/gcp/bastion.tf
  cfssl_version   = "1.6.1"
  bitcoin_version = "22.0"
  cepler_version  = "0.7.8"
  lnd_version     = "0.13.3"
  kubectl_version = "1.21.9"
  k9s_version     = "0.25.18"

# https://github.com/GaloyMoney/galoy-infra/blob/main/modules/inception/gcp/bastion-startup.tmpl#L12-L20

sed -i'' 's/pam_mkhomedir.so$/pam_mkhomedir.so umask=0077/' /etc/pam.d/sshd # Make all files private by default

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Keep make and terraform the first items installed as they are needed
# for testflight to complete
apt-get update && apt-get install -y make terraform jq tree wget redis postgresql

cat <<EOF > /etc/profile.d/aliases.sh
alias tf="terraform"
alias k="kubectl"
alias g="git"
alias gs="git status"
alias kauth="gcloud container clusters get-credentials ${cluster_name} --zone ${zone} --project ${project}"

export GALOY_ENVIRONMENT=${project}
export KUBE_CONFIG_PATH=~/.kube/config
EOF

%{ if bastion_revoke_on_exit }
cat <<EOF >> /etc/profile.d/auto-revoke.sh
onExit() {
  gcloud auth revoke
  echo Y | gcloud auth application-default revoke
}
trap onExit EXIT
EOF
%{ endif }

curl -LO https://storage.googleapis.com/kubernetes-release/release/v${kubectl_version}/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

wget -O- https://k14s.io/install.sh | bash

wget https://github.com/bodymindarts/cepler/releases/download/v${cepler_version}/cepler-x86_64-unknown-linux-musl-${cepler_version}.tar.gz \
  && tar -zxvf cepler-x86_64-unknown-linux-musl-${cepler_version}.tar.gz \
  && mv cepler-x86_64-unknown-linux-musl-${cepler_version}/cepler /usr/local/bin \
  && chmod +x /usr/local/bin/cepler \
  && rm -rf ./cepler-*

wget https://bitcoincore.org/bin/bitcoin-core-${bitcoin_version}/bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz \
  && tar -xvf bitcoin-${bitcoin_version}-x86_64-linux-gnu.tar.gz \
  && mv bitcoin-${bitcoin_version}/bin/* /usr/local/bin

wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | apt-key add - \
  && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/5.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-5.0.list \
  && apt-get update \
  && apt-get install -y mongodb-org-tools

wget https://github.com/lightningnetwork/lnd/releases/download/v${lnd_version}-beta/lnd-linux-amd64-v${lnd_version}-beta.tar.gz \
   && tar -xvf lnd-linux-amd64-v${lnd_version}-beta.tar.gz \
   && mv lnd-linux-amd64-v${lnd_version}-beta/lncli /usr/local/bin \
   && rm -rf lnd-linux-amd64-v${lnd_version}-*

mkdir k9s && cd k9s \
   && wget https://github.com/derailed/k9s/releases/download/v${k9s_version}/k9s_Linux_x86_64.tar.gz \
   && tar -xvf k9s_Linux_x86_64.tar.gz \
   && mv k9s /usr/local/bin \
   && cd .. && rm -rf k9s*
