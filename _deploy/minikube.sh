set -e

echo ">> Downloading latest minikube image with porto and portoshim"
IMG=https://github.com/go-faster/minikube/releases/latest/download/minikube-amd64.iso
wget -N ${IMG} # -N flag enables timestamping and prevents re-downloading the same file

echo ">> Building Minikube"
pushd minikube
make out/minikube
popd

echo ">> Starting Minikube"
ISO="file://$(realpath minikube-amd64.iso)"
# NB: To set the default driver, use `minikube config set driver virtualbox` command.
# Set LANG=en for VBoxManage, since VBoxManage output depends on system language
# and minikube fails to parse translated output.
export LANG=en
./minikube/out/minikube delete
./minikube/out/minikube start --iso-url="${ISO}" --cni=cilium --container-runtime=porto --cache-images=false

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
