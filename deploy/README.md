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
