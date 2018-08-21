#!/bin/bash
set -e

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v$MINIKUBE_VERSION/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export CHANGE_MINIKUBE_NONE_USER=true

# Start Minikube
sudo -E minikube start \
  --kubernetes-version=v$KUBERNETES_VERSION \
  --vm-driver=none \
  --bootstrapper=kubeadm \
  --alsologtostderr

minikube update-context

# Wait for Kubernetes to be ready
echo "Waiting for Kubernetes to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes
  if kubectl get pods --namespace=kube-system -lk8s-app=kube-dns|grep Running ; then
    break
  fi
  sleep 2
done

minikube status
