# Deploy

Deployment scripts and files.

## Requirements

- porto
- portoshim
- kubeadm
- kubectl
- helm
- cilium cli
- hubble cli
- go
- yt cli

## Preparing

Clone repositories:

```bash
git clone https://github.com/go-faster/portoshim.git
git clone https://github.com/go-faster/porto
git clone https://github.com/go-faster/ytst.git
git clone --branch feat/layer-location https://github.com/go-faster/yt-k8s-operator.git
```

## Running

First, start the cluster:
```bash
./start.sh
```

Wait until ytsaurus spins up:
```bash
kubectl -n yt get pods --watch
```

Setup and run test:
```bash
./yt-setup.sh
./yt-test.sh
```

Manually issue yt commands:
```bash
source yt.sh
```

## Cleanup

```bash
./reset.sh
```
