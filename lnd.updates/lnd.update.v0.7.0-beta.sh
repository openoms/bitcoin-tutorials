# LND Update Script

# Download and run this script on the RaspiBlitz:
# $ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/lnd.updates/lnd.update.v0.7.0-beta.sh && sudo bash lnd.update.v0.7.0-beta.sh

## based on https://github.com/Stadicus/guides/blob/master/raspibolt/raspibolt_40_lnd.md#lightning-lnd
## see LND releases: https://github.com/lightningnetwork/lnd/releases

lndVersion="0.7.0-beta"  # the version you would like to be updated
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
  lndSHA256="ac51d96ee9b57bfcab0b05dbcfcd9ce3bd42a216354c0972e97c1a1c86c2479a"
fi
if [ ${isAARCH64} -eq 1 ] ; then
  lndOSversion="arm64"
  lndSHA256="c995fa67d6b23e547723801de49817dda34188fba78d0fe8ae506774e54c0afd"
fi
if [ ${isX86_64} -eq 1 ] ; then
  lndOSversion="amd64"
  lndSHA256="c818c3a983167312f3bf2c84cb285212c5052131319caaef287a97541d2ff479"
fi 
if [ ${isX86_32} -eq 1 ] ; then
  lndOSversion="386"
  lndSHA256="47be6c3391fadbc5a169fa1dd6dd13031d759b3d42c71a2d556751746b705c48"
fi 
echo ""
echo "*** LND v${lndVersion} for ${lndOSversion} ***"

# olaoluwa
PGPpkeys="https://keybase.io/roasbeef/pgp_keys.asc"
PGPcheck="F8037E70C12C7A263C032508CE58F7F8E20FD9A2"
# PGPcheck="BD599672C804AF2770869A048B80CD2BB8BD8132"

# bitconner 
# PGPpkeys="https://keybase.io/bitconner/pgp_keys.asc"
# PGPcheck="9C8D61868A7C492003B2744EE7D737B67FA592C7"

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
