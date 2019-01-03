sudo apt-get update
sudo apt-get upgrade

sudo apt install git-all

# download, verify, install Electrum
wget https://download.electrum.org/3.0.3/Electrum-3.0.3.tar.gz https://download.electrum.org/3.0.3/Electrum-3.0.3.tar.gz.asc

Verify Electrum's downloaded source code
At this stage, we are ready to verify Electrum's source code. The source code is signed by Thomas Voegtlin (https://electrum.org). Let's import a relevant key signature:

$ gpg --keyserver pool.sks-keyservers.net --recv-keys 2BD5824B7F9470E6
gpg: key 2BD5824B7F9470E6: public key "Thomas Voegtlin (https://electrum.org) " imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 1
gpg:               imported: 1

Confirm a correct key import as per LINE 2. Once the key has been imported it is time to perform the verification:
"""
$ gpg --verify Electrum-3.0.3.tar.gz.asc Electrum-3.0.3.tar.gz
gpg: Signature made Tue 12 Dec 2017 17:06:09 AEDT
gpg:                using RSA key 2BD5824B7F9470E6
gpg: Good signature from "Thomas Voegtlin (https://electrum.org) " [unknown]
gpg:                 aka "ThomasV " [unknown]
gpg:                 aka "Thomas Voegtlin " [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 6694 D8DE 7BE8 EE56 31BE  D950 2BD5 824B 7F94 70E6
"""

Note gpg: Good signature on Line 4. All seems to be in order!
Install Electrum
To install Electrum bitcoin wallet, we first need to preform an installation of all prerequisites:

$ sudo apt-get install python3-setuptools python3-pyqt5 python3-pip

And finally, install Electrum bitcoin wallet using the bellow command:

$ sudo pip3 install Electrum-3.0.3.tar.gz

Start Electrum bitcoin Wallet
Electrum bitcoin wallet is now installed. You can start it from your start menu by clicking on the Electrum wallet icon or by executing electrum command from your terminal:

$ electrum

Navigate to the following page to learn how to create a Bitcoin offline/paper wallet.

How
ARE YOU LOOKING FOR A LINUX JOB?
Submit your RESUME or create a JOB ALERT on LinuxCareers.com job portal.
DO YOU NEED ADDITIONAL HELP?
Get extra help by visiting our LINUX FORUM or simply use comments below.
You may also be interested in:

# cd Electrum...
apt-get install python3-venv

python3 -m venv venv
source venv/bin/activate


$ sudo apt-get install python-dev libusb-1.0-0-dev libudev-dev
$ sudo pip install --upgrade setuptools
$ sudo pip install hidapi

pip install pyqt5 

pip install "ckcc-protocol[cli]"

https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_64_electrum.md

python3 run_electrum --oneserver --server 192.168.1.244:50002:s

