set -e

IMG=${IMG:"minikube-amd64.iso"}

# if IMG is not set, download the latest minikube image
if [ -z "$IMG" ]; then
    echo ">> Downloading latest minikube image"
    GH_BIN=$(which gh)
    if [ -x "$GH_BIN" ]; then
        echo ">>> Using gh to get latest minikube image"
        REPO="go-faster/minikube"
        version=$(gh release view -R "${REPO}" --json tagName --jq '.tagName')
        IMG="minikube-amd64-${version}.iso"
        echo ">>> Downloading $IMG"
        wget --no-clobber "https://ytsaurus.hb.ru-msk.vkcs.cloud/minikube/minikube-amd64-${version}.iso"
    else
        echo ">>> gh command not found"
        exit 1
    fi
fi

echo ">> Building Minikube"
pushd minikube
make out/minikube
popd

ISO_REALPATH=$(realpath "${IMG}")
ISO="file://${ISO_REALPATH}"
# NB: To set the default driver, use `minikube config set driver virtualbox` command.
# Set LANG=en for VBoxManage, since VBoxManage output depends on system language
# and minikube fails to parse translated output.
export LANG=en
echo ">> Deleting old Minikube"
./minikube/out/minikube delete
echo ">> Starting Minikube (iso: $ISO)"
MEM=${MEM:-8g}
CPU=${CPU:-4}
./minikube/out/minikube start --memory="${MEM}" --cpus="${CPU}" --iso-url="${ISO}" --cni=cilium --container-runtime=porto --cache-images=false

echo ">> Cert-Manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
kubectl -n cert-manager rollout status --timeout=5m deployment cert-manager-webhook

echo ">> Service monitors"
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

./operator.sh

echo ">> YTsaurus"
SPEC=yt.yml
kubectl create ns yt
kubectl apply -n yt -f ${SPEC}
