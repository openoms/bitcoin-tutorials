# LND Update Script

# Download and run this script on the RaspiBlitz:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/lnd.from.source.patched.sh && sudo bash lnd.from.source.patched.sh

sudo systemctl stop lnd


echo ""
echo "Installed ${installed}"

#### Build from Source
# To quickly catch up get latest patches if needed
repo="github.com/lightningnetwork/lnd"
commit="6e3b92b55f4a064198bc82eeefe33ad8733fea2a"
# BUILDING LND FROM SOURCE
echo "*** Build LND from Source ***"
go get -d $repo
# make sure to always have the same code (commit) to build
# TODO: To update lnd -> change to latest commit
cd $GOPATH/src/${repo}
sudo git checkout ${commit}

diff --git a/channeldb/graph.go b/channeldb/graph.go
index eaf3503c..b1b351b7 100644
--- a/channeldb/graph.go
+++ b/channeldb/graph.go
@@ -3025,7 +3025,9 @@ func (c *ChannelGraph) ChannelView() ([]EdgePoint, error) {
 				edgeIndex, chanID,
 			)
 			if err != nil {
-				return err
+				log.Errorf("Unable to fetch edge info for "+
+					"channel %v: %v", chanPoint, err)
+				return nil
 			}
 
 			pkScript, err := genMultiSigP2WSH(

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
echo "LND VERSION INSTALLED: ${lndVersionCheck} up to commit ${commit}"