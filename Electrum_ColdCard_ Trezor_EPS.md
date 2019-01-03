>sudo apt-get update

>sudo apt-get upgrade

>sudo apt install git-all

## download, verify, install Electrum
>wget https://download.electrum.org/3.3.2/Electrum-3.3.2.tar.gz https://download.electrum.org/3.3.2/Electrum-3.3.2.tar.gz.asc

Verify Electrum's downloaded source code
At this stage, we are ready to verify Electrum's source code. The source code is signed by Thomas Voegtlin (https://electrum.org). Let's import a relevant key signature:

> gpg --keyserver pool.sks-keyservers.net --recv-keys 2BD5824B7F9470E6
```
gpg: key 2BD5824B7F9470E6: public key "Thomas Voegtlin (https://electrum.org) " imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 1
gpg:               imported: 1
```

Confirm a correct key import as per LINE 2. Once the key has been imported it is time to perform the verification:

> gpg --verify Electrum-3.3.2.tar.gz.asc Electrum-3.3.2.tar.gz
```
gpg: Signature made Tue 12 Dec 2017 17:06:09 AEDT
gpg:                using RSA key 2BD5824B7F9470E6
gpg: Good signature from "Thomas Voegtlin (https://electrum.org) " [unknown]
gpg:                 aka "ThomasV " [unknown]
gpg:                 aka "Thomas Voegtlin " [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 6694 D8DE 7BE8 EE56 31BE  D950 2BD5 824B 7F94 70E6
```

Note gpg: Good signature on Line 4. All seems to be in order!
Install Electrum
To install Electrum bitcoin wallet, we first need to preform an installation of all prerequisites:

> sudo apt-get install python3-setuptools python3-pyqt5 python3-pip

And finally, install Electrum bitcoin wallet using the bellow command:

>sudo pip3 install Electrum-3.3.2.tar.gz

>cd Electrum-3.3.2


## install and activate a virtual environment
>apt-get install python3-venv

>python3 -m venv venv

>source venv/bin/activate



## to install ColdCard access for Electrum
>sudo apt-get install python-dev libusb-1.0-0-dev libudev-dev

>sudo pip install --upgrade setuptools

>sudo pip install hidapi

>pip install pyqt5 

>pip install "ckcc-protocol[cli]"

## install Trezor access for Electrum
>sudo apt-get install python3-dev python3-pip cython3 libusb-1.0-0-dev libudev-dev

>pip3 install --upgrade setuptools

>pip3 install trezor

>sudo pip3 install trezor[hidapi]

## install Electrum Personal server
https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_64_electrum.md  

some debugging which worked for me:

>ssh admin@Raspibolt

>sudo su - bitcoin

>ls -la

`drwx------ 6 bitcoin bitcoin 4096 Jan  2 23:55 .local`

>chmod 755 .local

`drwxr-xr-x 6 bitcoin bitcoin 4096 Jan  2 23:55 .local`

>sudo ufw status

allow your chosen port in ufw (default is 50002)

>sudo ufw allow 50002

>sudo systemctl start eps.service

>admin ~ ฿ tail -f /tmp/electrumpersonalserver.log

will need the LAN IP if your Raspibolt
>python3 run_electrum --oneserver --server 192.168.?.???:50002:s

