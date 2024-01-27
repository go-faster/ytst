#!/bin/bash

set -e

TAG=0.0.0
IMG=registry.ernado.me/ytop
NS=ytop
NAME=op

echo ">> Operator"
pushd yt-k8s-operator
make docker-build docker-push OPERATOR_IMAGE=${IMG} IMG=${IMG}:${TAG} OPERATOR_TAG=${TAG}
helm upgrade --install --namespace ${NS} --create-namespace ${NAME} ./ytop-chart --set controllerManager.manager.image.repository="${IMG}" --set controllerManager.manager.image.tag="${TAG}"
popd

kubectl -n ${NS} rollout status --timeout=1m deployment ${NAME}-ytop-chart-controller-manager
