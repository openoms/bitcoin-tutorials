# https://www.zokos.com/blog/site/public/2019/01/12/Self-Host%20your%20Own%20OpenBazaar%20Store/
# https://github.com/OpenBazaar/openbazaar-go/blob/master/docs/install-linux.md

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install build-essential git -y
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/usr/local/gocode
export PATH=$PATH:$GOPATH/bin
go get github.com/OpenBazaar/openbazaar-go

cd /usr/local/gocode/src/github.com/OpenBazaar/openbazaar-go

go run openbazaard.go init

# Generating Ed25519 keypair...Done
# 2019/03/09 10:57:29 Initializing OpenBazaar node at /home/admin/.openbazaar
# OpenBazaar repo initialized at /home/admin/.openbazaar

go run openbazaard.go setapicreds
# Enter username:
# Enter a veerrrry strong password: 
# Confirm your password: 
cd $HOME/.openbazaar

sed -i -- 's/127.0.0.1/0.0.0.0/g' config
cd /usr/local/gocode/src/github.com/OpenBazaar/openbazaar-go
sudo ufw allow 4002

go run openbazaard.go start &

-----------------


# https://github.com/OpenBazaar/openbazaar-go/blob/master/docs/install-pi3.md
# https://github.com/OpenBazaar/openbazaar-go
# https://github.com/OpenBazaar/openbazaar-go#usage


sudo mkdir /mnt/hdd/openbazaar
sudo chown -R bitcoin:bitcoin /mnt/hdd/openbazaar
sudo su bitcoin
/home/admin/config.scripts/go.install.sh
go get github.com/OpenBazaar/openbazaar-go
cd $GOPATH/src/github.com/OpenBazaar/openbazaar-go
git checkout v0.13.6

#echo "export GOPATH=/home/admin/go" >> .profile
#echo "export PATH=$PATH:/usr/local/go/bin" >> .profile
source ~/.profile


go run $GOPATH/src/github.com/OpenBazaar/openbazaar-go/openbazaard.go init -d /mnt/hdd/openbazaar -v

go run $GOPATH/src/github.com/OpenBazaar/openbazaar-go/openbazaard.go setapicreds -d /mnt/hdd/openbazaar -v

go run $GOPATH/src/github.com/OpenBazaar/openbazaar-go/openbazaard.go start --tor -d /mnt/hdd/openbazaar -v

# https://api.docs.openbazaar.org/

sed -i -- 's/127.0.0.1/0.0.0.0/g' /mnt/hdd/openbazaar/config

sudo ufw allow 4002 comment 'openbazaar'
