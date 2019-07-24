
echo ""
echo "*** CHECK BASE IMAGE ***"

# armv7=32Bit , armv8=64Bit
echo "Detect CPU architecture ..."
isARM=$(uname -m | grep -c 'arm')
isAARCH64=$(uname -m | grep -c 'aarch64')
isX86_64=$(uname -m | grep -c 'x86_64')
isX86_32=$(uname -m | grep -c 'i386\|i486\|i586\|i686\|i786')
if [ ${isARM} -eq 0 ] && [ ${isAARCH64} -eq 0 ] && [ ${isX86_64} -eq 0 ] && [ ${isX86_32} -eq 0 ] ; then
  echo "!!! FAIL !!!"
  echo "Can only build on ARM, aarch64, x86_64 or i386 not on:"
  uname -m
  exit 1
else
 echo "OK running on $(uname -m) architecture."
fi

# "*** BITCOIN ***"
# based on https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_30_bitcoin.md#installation

# set version (change if update is available)
# https://bitcoincore.org/en/download/
# bitcoinVersion="0.18.0" # commented out checksums for this version until lnd version >0.5.1
bitcoinVersion="0.17.1"

# set OS version and checksum
# needed to make sure download is not changed
# calculate with sha256sum and also check with SHA256SUMS.asc
# https://bitcoincore.org/bin/bitcoin-core-0.18.0/SHA256SUMS.asc
if [ ${isARM} -eq 1 ] ; then
  bitcoinOSversion="arm-linux-gnueabihf"
  # bitcoinSHA256="3d7eb57290b2f14c495a24ecbab8100b35861f0c81bc10d86e5c0a8ec8284b27"
  bitcoinSHA256="aab3c1fb92e47734fadded1d3f9ccf0ac5a59e3cdc28c43a52fcab9f0cb395bc"
fi
if [ ${isAARCH64} -eq 1 ] ; then
  bitcoinOSversion="aarch64-linux-gnu"
  # bitcoinSHA256="bfc3b8fddbb7ab9b532c9866859fc507ec959bdb82954966f54c8ebf8c7bb53b"
  bitcoinSHA256="5659c436ca92eed8ef42d5b2d162ff6283feba220748f9a373a5a53968975e34"
fi
if [ ${isX86_64} -eq 1 ] ; then
  bitcoinOSversion="x86_64-linux-gnu"
  # bitcoinSHA256="5146ac5310133fbb01439666131588006543ab5364435b748ddfc95a8cb8d63f"
  bitcoinSHA256="53ffca45809127c9ba33ce0080558634101ec49de5224b2998c489b6d0fc2b17"
fi
if [ ${isX86_32} -eq 1 ] ; then
  bitcoinOSversion="i686-pc-linux-gnu"
  # bitcoinSHA256="36ce9ffb375f6ee280df5a86e61038e3c475ab9dee34f6f89ea82b65a264183b"
  bitcoinSHA256="b1e1dcf8265521fef9021a9d49d8661833e3f844ca9a410a9dd12a617553dda1"
fi

echo ""
echo "*** BITCOIN v${bitcoinVersion} for ${bitcoinOSversion} ***"

# needed to check code signing
laanwjPGP="01EA5486DE18A882D4C2684590C8019E36C2E964"

# prepare directories
sudo rm -r /home/admin/download
sudo -u admin mkdir /home/admin/download
cd /home/admin/download

# download resources
binaryName="bitcoin-${bitcoinVersion}-${bitcoinOSversion}.tar.gz"
sudo -u admin wget https://bitcoin.org/bin/bitcoin-core-${bitcoinVersion}/${binaryName}
if [ ! -f "./${binaryName}" ]
then
    echo "!!! FAIL !!! Download BITCOIN BINARY not success."
    exit 1
fi

# check binary is was not manipulated (checksum test)
binaryChecksum=$(sha256sum ${binaryName} | cut -d " " -f1)
if [ "${binaryChecksum}" != "${bitcoinSHA256}" ]; then
  echo "!!! FAIL !!! Downloaded BITCOIN BINARY not matching SHA256 checksum: ${bitcoinSHA256}"
  exit 1
fi

# check gpg finger print
sudo -u admin wget https://bitcoin.org/laanwj-releases.asc
if [ ! -f "./laanwj-releases.asc" ]
then
  echo "!!! FAIL !!! Download laanwj-releases.asc not success."
  exit 1
fi
gpg ./laanwj-releases.asc
fingerprint=$(gpg ./laanwj-releases.asc 2>/dev/null | grep "${laanwjPGP}" -c)
if [ ${fingerprint} -lt 1 ]; then
  echo ""
  echo "!!! BUILD WARNING --> Bitcoin PGP author not as expected"
  echo "Should contain laanwjPGP: ${laanwjPGP}"
  echo "PRESS ENTER to TAKE THE RISK if you think all is OK"
  read key
fi
gpg --import ./laanwj-releases.asc
sudo -u admin wget https://bitcoin.org/bin/bitcoin-core-${bitcoinVersion}/SHA256SUMS.asc
verifyResult=$(gpg --verify SHA256SUMS.asc 2>&1)
goodSignature=$(echo ${verifyResult} | grep 'Good signature' -c)
echo "goodSignature(${goodSignature})"
correctKey=$(echo ${verifyResult} |  grep "using RSA key ${laanwjPGP: -16}" -c)
echo "correctKey(${correctKey})"
if [ ${correctKey} -lt 1 ] || [ ${goodSignature} -lt 1 ]; then
  echo ""
  echo "!!! BUILD FAILED --> LND PGP Verify not OK / signatute(${goodSignature}) verify(${correctKey})"
  exit 1
fi

# correct versions for install if needed
# just if an small update shows a different formatted version number
if [ "${bitcoinVersion}" = "0.17.0.1" ]; then
 bitcoinVersion="0.17.0"
fi

# install
sudo -u admin tar -xvf ${binaryName}
sudo install -m 0755 -o root -g root -t /usr/local/bin/ bitcoin-${bitcoinVersion}/bin/*
sleep 3
installed=$(sudo -u admin bitcoind --version | grep "${bitcoinVersion}" -c)
if [ ${installed} -lt 1 ]; then
  echo ""
  echo "!!! BUILD FAILED --> Was not able to install bitcoind version(${bitcoinVersion})"
  exit 1
fi