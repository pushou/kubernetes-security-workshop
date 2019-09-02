#!/bin/bash

echo "🚀 Initializing machine"
sudo apt-get update
sudo apt-get install -y docker.io unzip

export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y google-cloud-sdk

gcloud auth configure-docker --quiet

echo "📦 Installing dependencies"
sudo apt-get update
sudo apt-get install -y python3-pip python-pip software-properties-common

echo "📦 Installing ansible"
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update
sudo apt install -y ansible

echo "🏗 Installing kubespray"
git clone https://github.com/kubernetes-sigs/kubespray.git

cd kubespray

pip3 install -r requirements.txt
pip install netaddr

echo "🔧 Configuring kubespray"
cp -r inventory/sample inventory/cluster
cp ~/hosts.yml inventory/cluster/hosts.yml

echo "☸ Deploying Kubernetes"
ansible-playbook -i inventory/cluster/hosts.yml cluster.yml -b -v   --private-key=~/.ssh/id_rsa

ssh controller sudo cp /etc/kubernetes/admin.conf /home/ubuntu/kubeconfig
ssh controller sudo chown ubuntu:ubuntu /home/ubuntu/kubeconfig
mkdir ~/.kube
scp controller:~/kubeconfig ~/.kube/config

