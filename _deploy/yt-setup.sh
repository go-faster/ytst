#!/bin/bash

set -e

VER=20.04.5
IMG=ubuntu-base-${VER}-base-amd64.tar.gz

echo ">> Loading base layer"
wget -N https://cdimage.ubuntu.com/ubuntu-base/releases/${VER}/release/${IMG}
LAYER=//${IMG}
yt write-file ${LAYER} < ${IMG}
