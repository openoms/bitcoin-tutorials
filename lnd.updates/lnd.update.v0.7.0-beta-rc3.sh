# LND Update Script

# Download and run this script on the RaspiBlitz:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/lnd.updates/lnd.update.v0.7.0-beta-rc3.sh && sudo bash lnd.update.v0.7.0-beta-rc3.sh

## based on https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_40_lnd.md#lightning-lnd
## see LND releases: https://github.com/lightningnetwork/lnd/releases

lndVersion="0.7.0-beta-rc3"  # the version you would like to be updated
downloadDir="/home/admin/download"  # edit your download directory

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

# update the SHA256 checksum upon version change
if [ ${isARM} -eq 1 ] ; then
  lndOSversion="armv7"
  lndSHA256="92d2cf564714057ebf63f952454e4255e3e16e590178d096f75efc40931ace9a"
fi
if [ ${isAARCH64} -eq 1 ] ; then
  lndOSversion="arm64"
  lndSHA256="a0f40ec55ac9a9898657ede6084b32ae150d2d0483975eb1a6aab3c5fa691f2d"
fi
if [ ${isX86_64} -eq 1 ] ; then
  lndOSversion="amd64"
  lndSHA256="d90bf078edc57f12cfebfae96aaa6d686a8036a3cb1b8684855f773edd9f2ec7"
fi 
if [ ${isX86_32} -eq 1 ] ; then
  lndOSversion="386"
  lndSHA256="2723ce9dff50a2b063ba01b2b2cf4159db5aed5ade76a20978dfac361152fa06"
fi 
echo ""
echo "*** LND v${lndVersion} for ${lndOSversion} ***"

# olaoluwa
# PGPpkeys="https://keybase.io/roasbeef/pgp_keys.asc"
# PGPcheck="BD599672C804AF2770869A048B80CD2BB8BD8132"
# bitconner 
PGPpkeys="https://keybase.io/bitconner/pgp_keys.asc"
PGPcheck="9C8D61868A7C492003B2744EE7D737B67FA592C7"

# get LND resources
cd "${downloadDir}"
binaryName="lnd-linux-${lndOSversion}-v${lndVersion}.tar.gz"
sudo -u admin wget -N https://github.com/lightningnetwork/lnd/releases/download/v${lndVersion}/${binaryName}
sudo -u admin wget -N https://github.com/lightningnetwork/lnd/releases/download/v${lndVersion}/manifest-v${lndVersion}.txt
sudo -u admin wget -N https://github.com/lightningnetwork/lnd/releases/download/v${lndVersion}/manifest-v${lndVersion}.txt.sig
sudo -u admin wget -N -O "${downloadDir}/pgp_keys.asc" ${PGPpkeys}

# check binary is was not manipulated (checksum test)
binaryChecksum=$(sha256sum ${binaryName} | cut -d " " -f1)
if [ "${binaryChecksum}" != "${lndSHA256}" ]; then
  echo "!!! FAIL !!! Downloaded LND BINARY not matching SHA256 checksum: ${lndSHA256}"
  exit 1
fi

# check gpg finger print
gpg ./pgp_keys.asc
fingerprint=$(sudo gpg "${downloadDir}/pgp_keys.asc" 2>/dev/null | grep "${PGPcheck}" -c)
if [ ${fingerprint} -lt 1 ]; then
  echo ""
  echo "!!! BUILD WARNING --> LND PGP author not as expected"
  echo "Should contain PGP: ${PGPcheck}"
  echo "PRESS ENTER to TAKE THE RISK if you think all is OK"
  read key
fi
gpg --import ./pgp_keys.asc
sleep 3
verifyResult=$(gpg --verify manifest-v${lndVersion}.txt.sig 2>&1)
goodSignature=$(echo ${verifyResult} | grep 'Good signature' -c)
echo "goodSignature(${goodSignature})"
correctKey=$(echo ${verifyResult} | tr -d " \t\n\r" | grep "${olaoluwaPGP}" -c)
echo "correctKey(${correctKey})"
if [ ${correctKey} -lt 1 ] || [ ${goodSignature} -lt 1 ]; then
  echo ""
  echo "!!! BUILD FAILED --> LND PGP Verify not OK / signatute(${goodSignature}) verify(${correctKey})"
  exit 1
fi

sudo systemctl stop lnd

# install
sudo -u admin tar -xzf ${binaryName}
sudo install -m 0755 -o root -g root -t /usr/local/bin lnd-linux-${lndOSversion}-v${lndVersion}/*
sleep 3
installed=$(sudo -u admin lnd --version)
if [ ${#installed} -eq 0 ]; then
  echo ""
  echo "!!! BUILD FAILED --> Was not able to install LND"
  exit 1
fi

sudo systemctl restart lnd

echo ""
echo "Installed ${installed}"
