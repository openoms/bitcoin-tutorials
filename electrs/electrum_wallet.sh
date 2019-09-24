# Download and run this script to the Linux desktop:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/4_electrum_install && bash 4_electrum_install.sh

# https://electrum.org/#download
# Install dependencies: 	
sudo apt-get install -y python3-pyqt5
# Download package: 	
wget https://download.electrum.org/3.3.8/Electrum-3.3.8.tar.gz

#Verify signature:
wget https://raw.githubusercontent.com/spesmilo/electrum/master/pubkeys/ThomasV.asc
gpg --import ThomasV.asc
wget https://download.electrum.org/3.3.8/Electrum-3.3.8.tar.gz.asc
verifyResult=$(gpg --verify Electrum-3.3.8.tar.gz.asc 2>&1)
goodSignature=$(echo ${verifyResult} | grep 'Good signature' -c)
echo "goodSignature(${goodSignature})"
if [ ${goodSignature} -lt 1 ]; then
  echo ""
  echo "!!! BUILD FAILED --> PGP Verify not OK / signature(${goodSignature})"
  exit 1
fi

# Run without installing: 	tar -xvf Electrum-3.3.8.tar.gz
# python3 Electrum-3.3.8/run_electrum
# Install with PIP: 	
sudo apt-get install -y python3-setuptools python3-pip
python3 -m pip install --user Electrum-3.3.8.tar.gz[fast]

# add install dir to PATH (and make persist)
PATH=$PATH:~/.local/bin
touch ~/.profile
export PATH
~/.profile

echo "Type the LAN IP ADDRESS of your RaspiBlitz followed by [ENTER]:"
read RASPIBLITZ_IP

# Make Electrum config persist (editing ~/.electrum/config)
# sudo nano ~/.electrum/config
#     "rpcuser": "raspibolt",
#     "server": "192.168.1.239:50001:t",
electrum setconfig oneserver true
electrum setconfig server $RASPIBLITZ_IP:50001:t

electrum --oneserver --server $RASPIBLITZ_IP:50001:t 

echo "To start again: run \`electrum\` in the terminal."

echo "To connect through SSL:"
echo "Run: \`electrum --oneserver --server $YOUR_DOMAIN:50002:s\`"
echo "edit ~/.electrum/config: \"server\": \"<your_domain_or_dynDNS>:50002:s\""

electrum --oneserver --server $RASPIBLITZ_IP:50001:t 