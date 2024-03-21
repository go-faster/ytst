#!/bin/bash

set -e

TAG="dev-$(date +%s)"
# TODO(ernado): replace with ghcr.io
IMG="${IMG:-registry.ernado.me/ytop}"
NS=ytop
NAME=op

echo ">> Operator"
pushd yt-k8s-operator
make docker-build docker-push OPERATOR_IMAGE="${IMG}" IMG="${IMG}":"${TAG}" OPERATOR_TAG="${TAG}"
helm upgrade ${NAME} ./ytop-chart --install --namespace ${NS} --create-namespace --values ../ytop.yml --set controllerManager.manager.image.repository="${IMG}" --set controllerManager.manager.image.tag="${TAG}"
popd

kubectl -n ${NS} rollout status --timeout=5m deployment ${NAME}-ytop-chart-controller-manager
