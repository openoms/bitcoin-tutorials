#!/bin/bash

VERSION='1.8.4'

cd Downloads

wget -O sparrow_${VERSION}-1_amd64.deb https://github.com/sparrowwallet/sparrow/releases/download/${VERSION}/sparrow_${VERSION}-1_amd64.deb || exit 1
wget -O sparrow-${VERSION}-manifest.txt https://github.com/sparrowwallet/sparrow/releases/download/${VERSION}/sparrow-${VERSION}-manifest.txt || exit 1
wget -O sparrow-${VERSION}-manifest.txt.asc https://github.com/sparrowwallet/sparrow/releases/download/${VERSION}/sparrow-${VERSION}-manifest.txt.asc || exit 1


gpg --verify sparrow-${VERSION}-manifest.txt.asc sparrow-${VERSION}-manifest.txt || exit 1
sha256sum -c sparrow-${VERSION}-manifest.txt --ignore-missing || exit 1

sudo dpkg -i sparrow_${VERSION}-1_amd64.deb || exit 1

exit 0
