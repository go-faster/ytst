#!/bin/bash

set -e

source yt.sh
VER=22.04
IMG=ubuntu-base-${VER}-base-amd64.tar.gz

echo ">> Loading base layer"
wget -O ${IMG} -nc https://cdimage.ubuntu.com/ubuntu-base/releases/${VER}/release/${IMG}
LAYER=//${IMG}
yt write-file ${LAYER} < ${IMG}
