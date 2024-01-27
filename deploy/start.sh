#!/bin/bash

set -e

CRI="${CRI:-unix:///run/portoshim.sock}"
echo ">> Setting k8s on ${CRI}"
portoctl docker-pull registry.k8s.io/pause:3.7 # https://github.com/go-faster/portoshim/issues/2
kubeadm init --cri-socket="${CRI}" --skip-phases=addon/kube-proxy
kubectl taint nodes "$(hostname)" node-role.kubernetes.io/control-plane:NoSchedule-

echo ">> Cilium"
kubectl create ns cilium
cilium install --version 1.14.5 -n cilium --set bpf.autoMount.enabled=false
cilium hubble enable -n cilium
cilium -n cilium status --wait

echo ">> OpenEBS"
helm install openebs --namespace openebs openebs/openebs --create-namespace
kubectl replace -f openebs.storageclass.yml

echo ">> Cert-Manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
kubectl -n cert-manager rollout status --timeout=1m deployment cert-manager-webhook

echo ">> Service monitors"
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

echo ">> Operator"
./operator.sh

echo ">> YTsaurus"
kubectl create ns yt
kubectl apply -n yt -f yt.yml
