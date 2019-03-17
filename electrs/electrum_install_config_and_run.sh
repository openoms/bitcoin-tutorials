# Download this script to your linux desktop:
# $ wget https://gist.github.com/openoms/8d365f330f5e1288933e0f4874b56dbd/raw/2cf47bf5cc629e861540f4dd5fa525fd157fc341/electrum_install_config_and_run.sh
# make it executable:
# $ sudo chmod +x electrum_install_config_and_run.sh
# and run:
# $ ./electrum_install_config_and_run.sh

# https://electrum.org/#download
# Install dependencies: 	
sudo apt-get install python3-pyqt5
# Download package: 	
wget https://download.electrum.org/3.3.4/Electrum-3.3.4.tar.gz

#Verify signature:
gpg --import ThomasV.asc
wget https://download.electrum.org/3.3.4/Electrum-3.3.4.tar.gz.asc
verifyResult=$(gpg --verify Electrum-3.3.4.tar.gz.asc 2>&1)
goodSignature=$(echo ${verifyResult} | grep 'Good signature' -c)
echo "goodSignature(${goodSignature})"
if [ ${goodSignature} -lt 1 ]; then
  echo ""
  echo "!!! BUILD FAILED --> PGP Verify not OK / signature(${goodSignature})"
  exit 1
fi

# Run without installing: 	tar -xvf Electrum-3.3.4.tar.gz
# python3 Electrum-3.3.4/run_electrum
# Install with PIP: 	
sudo apt-get install python3-setuptools python3-pip
python3 -m pip install --user Electrum-3.3.4.tar.gz[fast]

echo "Type the PASSWORD B of your RaspiBlitz followed by [ENTER]:"
read PASSWORD_B
echo "Type the LAN IP ADDRESS of your RaspiBlitz followed by [ENTER]:"
read RASPIBLITZ_IP

# Make Electrum config persist (editing ~/.electrum/config)
# sudo nano ~/.electrum/config
#     "oneserver": true,
#     "rpcpassword": "$PASSWORD_B",
#     "rpcuser": "raspibolt",
#     "server": "192.168.1.239:50001:t",
electrum setconfig oneserver true
electrum setconfig rpcpassword $PASSWORD_B
electrum setconfig rpcuser raspibolt
electrum setconfig server $RASPIBLITZ_IP:50001:t

electrum --oneserver --server=$RASPIBLITZ_IP:50001:t 