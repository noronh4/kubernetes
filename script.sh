#!/bin/bash

#Unnistall docker
yum remove docker
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

#Unnistall k8s
kubeadm reset -f && systemctl stop kubelet
yum remove -y kubeadm kubectl kubelet kubernetes-cni kube*
yum autoremove -y
rm -rf /var/lib/kubelet/*

#Unnistall flannel
rm -rf /var/lib/cni/
rm -rf /run/flannel
rm -rf /etc/cni/

#Cleaning iptalbes
./limpar-iptables.sh

#Re-installing k8s
yum install -y kubelet-1.21.0-0 kubeadm-1.21.0-0 kubectl-1.21.0-0 --disableexcludes=kubernetes
kubeadm init --kubernetes-version=1.21.0 #--pod-network-cidr=10.244.0.0/16
export KUBECONFIG=/etc/kubernetes/admin.conf
sleep 5
kubectl get nodes
kubectl get pods -n kube-system
echo "============================================="
echo "============================================="
#rm -f /etc/cni/net.d/*flannel*

#Re-installing docker
yum install docker

#Download K8s images
kubeadm config images pull --kubernetes-version=1.21.0

#Installing Flannel
#echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
#kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
#sleep 5

#Installing Weave Net
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
sleep 10
kubectl get nodes
kubectl get pods -n kube-system

#List kubeadm versions
#yum list --showduplicates kubeadm --disableexcludes=kubernetes
