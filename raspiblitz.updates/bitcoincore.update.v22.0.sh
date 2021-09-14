#!/bin/bash

# based on https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_30_bitcoin.md#installation

# set version (change if update is available)
# https://bitcoincore.org/en/download/
bitcoinVersion="22.0"

# needed to check code signing
# https://github.com/laanwj
laanwjPGP="71A3 B167 3540 5025 D447 E8F2 7481 0B01 2346 C9A6"

downloadDir="$(pwd)/download/bitcoin-core-${bitcoinVersion}"

echo "Detecting CPU architecture ..."
isARM=$(uname -m | grep -c 'arm')
isAARCH64=$(uname -m | grep -c 'aarch64')
isX86_64=$(uname -m | grep -c 'x86_64')
if [ ${isARM} -eq 0 ] && [ ${isAARCH64} -eq 0 ] && [ ${isX86_64} -eq 0 ]; then
  echo "!!! FAIL !!!"
  echo "Can only build on ARM, aarch64, x86_64 or i386 not on:"
  uname -m
  exit 1
else
 echo "OK running on $(uname -m) architecture."
fi

echo
echo "*** PREPARING BITCOIN ***"

# prepare directories
# rm -rf ${downloadDir} 2>/dev/null
mkdir -p ${downloadDir} 2>/dev/null
cd ${downloadDir}

# download, check and import signer key
if ! gpg --recv-key "71A3 B167 3540 5025 D447 E8F2 7481 0B01 2346 C9A6"
then
  echo "!!! FAIL !!! Couldn't download Wladimir J. van der Laan PGP pubkey"
  exit 1
fi

# download signed binary sha256 hash sum file
wget https://bitcoincore.org/bin/bitcoin-core-${bitcoinVersion}/SHA256SUMS -O SHA256SUMS

# download signed binary sha256 hash sum file signatures
wget https://bitcoincore.org/bin/bitcoin-core-${bitcoinVersion}/SHA256SUMS.asc -O SHA256SUMS.asc
verifyResult=$(gpg --verify SHA256SUMS.asc 2>&1)
goodSignature=$(echo ${verifyResult} | grep 'Good signature' -c)
echo "goodSignature(${goodSignature})"
correctKey=$(echo ${verifyResult} |  grep "${laanwjPGP}" -c)
echo "correctKey(${correctKey})"
if [ ${correctKey} -lt 1 ] || [ ${goodSignature} -lt 1 ]; then
  echo
  echo "!!! BUILD FAILED --> PGP Verify not OK / signature(${goodSignature}) verify(${correctKey})"
  exit 1
else
  echo
  echo "****************************************"
  echo "OK --> BITCOIN MANIFEST IS CORRECT"
  echo "****************************************"
  echo
fi

# get the sha256 value for the corresponding platform from signed hash sum file
if [ ${isARM} -eq 1 ] ; then
  bitcoinOSversion="arm-linux-gnueabihf"
fi
if [ ${isAARCH64} -eq 1 ] ; then
  bitcoinOSversion="aarch64-linux-gnu"
fi
if [ ${isX86_64} -eq 1 ] ; then
  bitcoinOSversion="x86_64-linux-gnu"
fi

echo "*** BITCOIN CORE v${bitcoinVersion} for ${bitcoinOSversion} ***"
# download resources
binaryName="bitcoin-${bitcoinVersion}-${bitcoinOSversion}.tar.gz"
if [ ! -f ${binaryName} ];then
  wget https://bitcoincore.org/bin/bitcoin-core-${bitcoinVersion}/${binaryName} -O ${binaryName}
else 
  echo "{binaryName} is already present."
fi
if [ ! -f "./${binaryName}" ]
then
    echo "!!! FAIL !!! Could not download the BITCOIN BINARY."
    exit 1
fi

# check binary checksum test
bitcoinSHA256=$(grep -i "${binaryName}" SHA256SUMS | cut -d " " -f1)
binaryChecksum=$(sha256sum ${binaryName} | cut -d " " -f1)
if [ "${binaryChecksum}" != "${bitcoinSHA256}" ]; then
  echo "!!! FAIL !!! Downloaded BITCOIN BINARY not matching SHA256 checksum: ${bitcoinSHA256}"
  echo "Press ENTER to remove the file: ${binaryName} or CTRL+C to abort"
  read key
  rm -f ${binaryName}
  exit 1
else
  echo
  echo "********************************************"
  echo "OK --> VERIFIED BITCOIN CORE BINARY CHECKSUM"
  echo "********************************************"
  echo
fi

echo "Stopping bitcoind"
sudo systemctl stop bitcoind
echo

echo "Installing Bitcoin Core v${bitcoinVersion}"
tar -xvf ${binaryName}
sudo install -m 0755 -o root -g root -t /usr/local/bin/ bitcoin-${bitcoinVersion}/bin/*
sleep 3
installed=$(bitcoind --version | grep "${bitcoinVersion}" -c)
if [ ${installed} -lt 1 ]; then
  echo
  echo "!!! BUILD FAILED --> Was not able to install bitcoind version(${bitcoinVersion})"
  exit 1
fi

sudo systemctl start bitcoind
sleep 2

echo
echo "Installed $(bitcoind --version | grep version)"
echo 
