# ytst

Set of tools for testing ytsaurus.

```bash
cd deploy
```

## Running in Kubernetes

### Requirements

- porto
- portoshim
- kubeadm
- kubectl
- helm
- cilium cli
- hubble cli
- go
- yt cli

### Preparing

Clone repositories:

```bash
git clone https://github.com/go-faster/ytst.git
cd ytst/deploy
git submodule update --init --recursive
```

### Running

First, start the cluster:
```bash
./start.sh
```

Wait until ytsaurus spins up:
```bash
kubectl -n yt get pods --watch
```

Setup and run test:

> [!WARNING]
> Currently fails with `/bin/bash: line 1: ./yt-http-test: No such file or directory`: [#3](https://github.com/go-faster/ytst/issues/3)

```bash
./yt-setup.sh
./yt-test.sh
```

Manually issue yt commands:
```bash
source yt.sh
```

### Cleanup

```bash
./reset.sh
```

## Running in Minikube

### Building binary

```bash
make minikube-darwin-amd64 minikube-darwin-arm64 minikube-linux-amd64
```

### Running

> [!WARNING]
> Currently fails at `Verifying Kubernetes components...`: [#4](https://github.com/go-faster/portoshim/issues/4),[#3](https://github.com/go-faster/portoshim/issues/3)

```bash
./minikube.sh
```

### Minikube logs

```bash
./minikube/out/minikube logs
```

### Cleanup

```bash
./minikube/out/minikube delete
```

### Building image

> [!IMPORTANT]
> Pretty slow, takes about 30 minutes.

```bash
cd minikube
IN_DOCKER=1 make minikube-iso-x86_64
```
