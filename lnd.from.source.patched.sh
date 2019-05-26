# LND Update Script to build patch for https://github.com/rootzoll/raspiblitz/issues/595

# Download and run this script on the RaspiBlitz:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/lnd.from.source.patched.sh && sudo bash lnd.from.source.patched.sh

sudo systemctl stop lnd

#### Build from Source
# To quickly catch up get latest patches if needed
repo="github.com/openoms/lnd"
commit="1a59596df3e8ae9e95a858cda33c329d4736d1bd"
# https://github.com/openoms/lnd/commit/1a59596df3e8ae9e95a858cda33c329d4736d1bd

# BUILDING LND FROM SOURCE
echo "*** Build LND from Source ***"
echo "repo=${repo}"
echo "up to the commit=${commit}"

export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/usr/local/gocode
export PATH=$PATH:$GOPATH/bin
go get -d $repo
# make sure to always have the same code (commit) to build
# TODO: To update lnd -> change to latest commit
cd $GOPATH/src/${repo}
sudo git checkout ${commit}
make && make install
sudo chmod 555 /usr/local/gocode/bin/lncli
sudo chmod 555 /usr/local/gocode/bin/lnd
sudo bash -c "echo 'export PATH=$PATH:/usr/local/gocode/bin/' >> /home/admin/.bashrc"
sudo bash -c "echo 'export PATH=$PATH:/usr/local/gocode/bin/' >> /home/pi/.bashrc"
sudo bash -c "echo 'export PATH=$PATH:/usr/local/gocode/bin/' >> /home/bitcoin/.bashrc"

lndVersionCheck=$(lncli --version)
if [ ${#lndVersionCheck} -eq 0 ]; then
  echo "FAIL - Something went wrong with building LND from source."
  echo "Sometimes it may just be a connection issue. Reset to fresh Rasbian and try again?"
  exit 1
fi
echo ""
echo "** Link to /usr/local/bin ***"
sudo ln -s /usr/local/gocode/bin/lncli /usr/local/bin/lncli
sudo ln -s /usr/local/gocode/bin/lnd /usr/local/bin/lnd

sudo systemctl restart lnd

echo ""
echo "LND VERSION INSTALLED: ${lndVersionCheck} up to commit ${commit} from ${repo}"