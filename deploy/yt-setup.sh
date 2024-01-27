#!/bin/bash

source yt.sh

echo ">> Loading base layer"
IMG=ubuntu-base-22.04-base-amd64.tar.gz
LAYER=//${IMG}
yt write-file ${LAYER} < ${IMG}
