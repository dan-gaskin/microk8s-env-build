# microk8s-env-build

## configure-environment.sh
The purpose of the configure-environment.sh script is to set up a 3 node microk8s cluster on your Mac, and set your local kube config file to point at the cluster. If you do not have multipass or kubectl installed locally, the script will install these via brew.

## prerequisite
- brew

## starting the cluster
After running configure-environment.sh, your cluster will be up and running. To run the cluster in the future

```
multipass start microk8s-node1 microk8s-node2 microk8s-node3; multipass exec microk8s-node1 -- /snap/bin/microk8s.start; multipass exec microk8s-node2 -- /snap/bin/microk8s.start; multipass exec microk8s-node3 -- /snap/bin/microk8s.start
```

## stopping the cluster
Run the following command

```
multipass stop microk8s-node1 microk8s-node2 microk8s-node3
```

## deleting the cluster

```
multipass delete microk8s-node1 microk8s-node2 microk8s-node3; multipass purge
```

## accessing the dashboard
Run the following command

```
kubectl proxy --accept-hosts=.* --address=0.0.0.0
```
Then navigate to http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#/error?namespace=default
