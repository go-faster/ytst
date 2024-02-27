#!/bin/bash

set -e

CRI="${CRI:-unix:///run/portoshim.sock}"
echo ">> Setting k8s on ${CRI}"
if [[ ${CRI} =~ "porto" ]]; then
  echo ">> Pulling pause image (porto hack)"
  # https://github.com/go-faster/portoshim/issues/2
  portoctl docker-pull registry.k8s.io/pause:3.7
fi
kubeadm init --cri-socket="${CRI}"
kubectl taint nodes "$(hostname)" node-role.kubernetes.io/control-plane:NoSchedule-

echo ">> Calico"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
kubectl create -f calico.yml

echo ">> OpenEBS"
helm install openebs --namespace openebs openebs/openebs --create-namespace
kubectl replace -f openebs.storageclass.yml

echo ">> Cert-Manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
kubectl -n cert-manager rollout status --timeout=1m deployment cert-manager-webhook

echo ">> Service monitors"
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

./operator.sh

echo ">> YTsaurus"
SPEC=yt.yml
if [[ ${CRI} =~ "containerd" ]]; then
  SPEC=yt.containerd.yml
fi
kubectl create ns yt
kubectl apply -n yt -f ${SPEC}
