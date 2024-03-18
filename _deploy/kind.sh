#!/bin/bash

set -e

echo ">> Kind"
CLUSTER=yt
kind delete cluster --name ${CLUSTER} -q || true
kind create cluster --name ${CLUSTER} --config kind.yml

echo ">> Cilium"
kubectl create ns cilium
cilium install --version 1.15.1 -n cilium --values cilium.yml
cilium -n cilium status --wait

echo ">> Cert-Manager"
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.yaml
kubectl -n cert-manager rollout status --timeout=1m deployment cert-manager-webhook

echo ">> Service monitors"
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml

echo ">> Istio"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm upgrade --install --namespace istio-system --create-namespace istio-base istio/base
helm upgrade --install --namespace istio-system istiod istio/istiod --wait
helm upgrade --install istio-ingressgateway istio/gateway -f istio-gw-values.yml
kubectl apply -f istio-ingress.yml

./operator.sh

echo ">> YTsaurus"
SPEC=yt.yml
kubectl create ns yt
kubectl apply -f kind.cnp.yml
sed 's/usePorto: true/usePorto: false/' ${SPEC} | kubectl apply -n yt -f -
