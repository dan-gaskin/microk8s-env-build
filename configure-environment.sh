#!/bin/bash
printf "\nCheck if multipass is installed\n"
multipassinstalled=`multipass --version`
if [[ $multipassinstalled == *"Not Found"* ]]
then
   brew cask install multipass
   printf "multipass successfully installed"
else
   printf "multipass already installed"
fi

printf "\nCheck if kubectl is installed\n"
kubectlinstalled=`kubectl version`
if [[ $kubectlinstalled == *"Not Found"* ]]
then
   brew install kubectl
   printf "kubectl successfully installed"
else
   printf "kubectl already installed"
fi
printf "\nlaunching nodes\n"

multipass launch --name microk8s-node1 --mem 4G --disk 40G
multipass launch --name microk8s-node2 --mem 4G --disk 40G
multipass launch --name microk8s-node3 --mem 4G --disk 40G

printf "\nAll nodes launched, configuring nodes\n"

multipass exec microk8s-node1 -- sudo snap install microk8s --classic
multipass exec microk8s-node2 -- sudo snap install microk8s --classic
multipass exec microk8s-node3 -- sudo snap install microk8s --classic

printf "\nAll nodes configured with microk8s, configuring iptables\n"

multipass exec microk8s-node1 -- sudo iptables -P FORWARD ACCEPT
multipass exec microk8s-node2 -- sudo iptables -P FORWARD ACCEPT
multipass exec microk8s-node3 -- sudo iptables -P FORWARD ACCEPT

printf "\niptables configured, configuring permissions\n"

multipass exec microk8s-node1 -- sudo usermod -a -G microk8s multipass
multipass exec microk8s-node2 -- sudo usermod -a -G microk8s multipass
multipass exec microk8s-node3 -- sudo usermod -a -G microk8s multipass

printf "\npermissions configured, starting nodes\n"

multipass exec microk8s-node1 -- /snap/bin/microk8s.start
multipass exec microk8s-node2 -- /snap/bin/microk8s.start
multipass exec microk8s-node3 -- /snap/bin/microk8s.start

printf "\nall nodes started, enabling dns and dashboard\n"

multipass exec microk8s-node1 -- /snap/bin/microk8s.enable dns
multipass exec microk8s-node1 -- /snap/bin/microk8s.enable dashboard

printf "\ndns and dashboard enabled, retrieving 1st token for node join\n"

multipass exec microk8s-node1 -- /snap/bin/microk8s.add-node | head -n1 | cut -b 31-63 > jointoken
jointoken=`cat jointoken`

printf "\ntoken retrieved, joining 2nd node to cluster\n"

multipass exec microk8s-node2 -- /snap/bin/microk8s.join ${jointoken}

printf "\n2nd node joined to cluster, retriving token for 3rd node\n"

multipass exec microk8s-node1 -- /snap/bin/microk8s.add-node | head -n1 | cut -b 31-63 > jointoken
jointoken=`cat jointoken`

echo "\ntoken retrieved, joining 3rd node to cluster\n"

multipass exec microk8s-node3 -- /snap/bin/microk8s.join ${jointoken}

printf "\n3rd node joined to cluster, retrieving kube config\n"

rm -rf jointoken
multipass exec microk8s-node1 -- /snap/bin/microk8s.config > ~/.kube/config

printf "\nlocal kube config set, listing cluster details\n"

token=$(multipass exec microk8s-node1 -- /snap/bin/microk8s.kubectl -n kube-system get secret | grep default-token | cut -d " " -f1)
multipass exec microk8s-node1 -- /snap/bin/microk8s.kubectl -n kube-system describe secret $token
kubectl cluster-info
kubectl get no
exit
