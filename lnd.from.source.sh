# LND Update Script

# Download and run this script on the RaspiBlitz:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/lnd.from.source.sh && sudo bash lnd.from.source.sh

#### Build from Source
# To quickly catch up get latest patches if needed
aarepo="github.com/lightningnetwork/lnd"
echo "Paste the latest or desired commit ID to checkout from: https://github.com/lightningnetwork/lnd/commits/master"
echo "Example:"
echo "4068e78af690f9b4a598de1f3f0b21b5560dd146"
echo "and press ENTER"
read commit
# commit="580509191007617afa6da4b6b0151b4b5313eb72"

# BUILDING LND FROM SOURCE
echo "*** Build LND from Source ***"
echo "repo=${repo}"
echo "up to the commit=${commit}"

sudo systemctl stop lnd

export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/usr/local/gocode
export PATH=$PATH:$GOPATH/bin
echo "Deleting old source..."
sudo rm -r /usr/local/gocode/src/github.com/lightningnetwork/lnd
go get -d $repo

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