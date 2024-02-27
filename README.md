# ytst

Set of tools for testing ytsaurus with porto and k8s.

```bash
cd _deploy
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
cd ytst/_deploy
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

```bash
source yt.sh
./yt-setup.sh
./yt-test.sh
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
