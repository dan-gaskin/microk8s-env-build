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

