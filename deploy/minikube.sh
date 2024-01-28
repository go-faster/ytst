set -e

echo ">> Downloading latest minikube image with porto and portoshim"
VER=v1.32.1-alpha.1
IMG=https://github.com/go-faster/minikube/releases/download/${VER}/minikube-amd64.iso
wget -N ${IMG} # -N flag enables timestamping and prevents re-downloading the same file

echo ">> Building"
pushd minikube
make out/minikube
popd

echo ">> Starting"
ISO="file://$(realpath minikube-amd64.iso)"
./minikube/out/minikube start --iso-url="${ISO}" --cni=cilium --container-runtime=porto --cache-images=false
