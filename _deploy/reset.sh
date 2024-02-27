#!/bin/bash

CRI="${CRI:-unix:///run/portoshim.sock}"
echo ">> Stopping k8s on ${CRI}"
kubeadm reset --cri-socket="${CRI}" --force
