#!/bin/bash

set -e

echo ">> Building Minikube"
pushd minikube
make out/minikube
popd

# NB: To set the default driver, use `minikube config set driver virtualbox` command.
# Set LANG=en for VBoxManage, since VBoxManage output depends on system language
# and minikube fails to parse translated output.
export LANG=en
echo ">> Deleting old Minikube"
./minikube/out/minikube delete
echo ">> Starting Minikube"
./minikube/out/minikube start --memory="8g" --cpus=4 --cni=cilium --cache-images=false

echo ">> Cert-Manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
kubectl -n cert-manager rollout status --timeout=5m deployment cert-manager-webhook

echo ">> Service monitors"
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

./operator.sh

kubectl create ns yt
kubectl apply -n yt -f "${SPEC:-yt.master-caches.yml}"
