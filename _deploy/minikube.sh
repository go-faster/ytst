set -e

echo ">> Downloading latest minikube image with porto and portoshim"
IMG="minikube-amd64.iso"
GH_BIN=$(which gh)
if [ -x "$GH_BIN" ]; then
    echo ">>> Using gh to get latest minikube image"
    REPO="go-faster/minikube"
    latest_version=$(gh release view -R "${REPO}" --json name --jq '.name')
    IMG="minikube-amd64-${latest_version}.iso"
    echo ">>> Downloading $IMG"
    gh release download -R "${REPO}" --skip-existing -O "${IMG}" "${latest_version}"
else
    echo ">>> gh command not found"
fi

echo ">> Building Minikube"
pushd minikube
make out/minikube
popd

ISO="file://$(realpath $IMG)"
# NB: To set the default driver, use `minikube config set driver virtualbox` command.
# Set LANG=en for VBoxManage, since VBoxManage output depends on system language
# and minikube fails to parse translated output.
export LANG=en
echo ">> Deleting old Minikube"
./minikube/out/minikube delete
echo ">> Starting Minikube (iso: $ISO)"
./minikube/out/minikube start --memory="8g" --cpus=4 --iso-url="${ISO}" --cni=cilium --container-runtime=porto --cache-images=false

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
