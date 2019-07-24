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

# "*** Installing Go ***"
# Go is needed for ZAP connect later
# see https://golang.org/dl/
goVersion="1.12.7"
if [ ${isARM} -eq 1 ] ; then
  goOSversion="armv6l"
fi
if [ ${isAARCH64} -eq 1 ] ; then
  goOSversion="arm64"
fi
if [ ${isX86_64} -eq 1 ] ; then
  goOSversion="amd64"
fi
if [ ${isX86_32} -eq 1 ] ; then
  goOSversion="386"
fi

echo "*** Installing Go v${goVersion} for ${goOSversion} ***"

# wget https://storage.googleapis.com/golang/go${goVersion}.linux-${goOSversion}.tar.gz
wget https://dl.google.com/go/go${goVersion}.linux-${goOSversion}.tar.gz
if [ ! -f "./go${goVersion}.linux-${goOSversion}.tar.gz" ]
then
    echo "!!! FAIL !!! Download not success."
    exit 1
fi
sudo tar -C /usr/local -xzf go${goVersion}.linux-${goOSversion}.tar.gz
sudo rm *.gz
sudo mkdir /usr/local/gocode
sudo chmod 777 /usr/local/gocode
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=/usr/local/gocode
export PATH=$PATH:$GOPATH/bin
echo ""