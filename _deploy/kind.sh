#!/bin/bash

set -e

echo ">> Kind"
CLUSTER=yt
kind delete cluster --name ${CLUSTER} -q || true
kind create cluster --name ${CLUSTER} --config kind.yml

echo ">> Cilium"
kubectl create ns cilium
cilium install --version 1.14.5 -n cilium --set bpf.autoMount.enabled=false
cilium hubble enable -n cilium
cilium -n cilium status --wait

echo ">> Cert-Manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
kubectl -n cert-manager rollout status --timeout=1m deployment cert-manager-webhook

echo ">> Service monitors"
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

./operator.sh

echo ">> YTsaurus"
SPEC=yt.master-caches.yml
kubectl create ns yt
kubectl apply -n yt -f ${SPEC}
