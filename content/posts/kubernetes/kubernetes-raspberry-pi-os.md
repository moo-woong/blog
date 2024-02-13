---
title: "Kubernetes Raspberry Pi Os"
date: 2024-02-13T13:11:30Z
---

How to establish kubernetes cluster using Raspberry Pi OS

## Prepare Raspberry-pi OS image using imager

{{< figure src="/images/raspberry-pi-imager-1.png">}}
{{< figure src="/images/raspberry-pi-imager-2.png">}}

## Setting up raspberry-pi OS
### Update OS and repo
```sh
sudo apt update -y && sudo apt dist-upgrade -y
```
reboot
```sh
sudo reboot
```
### Disable and uninstall swap
```sh
sudo dphys-swapfile swapoff  
sudo dphys-swapfile uninstall  
sudo apt purge -y dphys-swapfile  
sudo apt autoremove -y
```
### Add cgroups
```sh
echo " cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1" | sudo tee -a  /boot/cmdline.txt
```
### Disable and uninstall swap
```sh
sudo dphys-swapfile swapoff  
sudo dphys-swapfile uninstall  
sudo apt purge -y dphys-swapfile  
sudo apt autoremove -y
```
Or update `cmdline`
```sh
cat /proc/cmdline
coherent_pool=1M 8250.nr_uarts=0 snd_bcm2835.enable_headphones=0 snd_bcm2835.enable_headphones=1 snd_bcm2835.enable_hdmi=1 snd_bcm2835.enable_hdmi=0  smsc95xx.macaddr=D8:3A:DD:24:4E:4F vc_mem.mem_base=0x3eb00000 vc_mem.mem_size=0x3ff00000  cgroup_enable=memory cgroup_memory=1 console=ttyS0,115200 console=tty1 root=PARTUUID=48d96ea9-02 rootfstype=ext4 fsck.repair=yes rootwait
```
### Install and update `containerd` 
```sh
sudo apt install -y containerd containernetworking-plugins
```

```sh
cat <<EOF | sudo tee /etc/containerd/config.toml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
    [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
EOF
```

### Install kubeadm, kubectl and kubelet
```
sudo apt update  
sudo apt install -y apt-transport-https ca-certificates curl  
  
// Download the Google Cloud public signing key:  
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg
  
// Add the Kubernetes apt repository:  
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  
// Update `apt` package index, install kubelet, kubeadm and kubectl, and pin their version:  
sudo apt update  
sudo apt install -y kubelet kubeadm kubectl  
sudo apt-mark hold kubelet kubeadm kubectl
```

## Prepare master node
### kubeadm init
```
sudo kubeadm init --pod-network-cidr 192.168.0.0/16
...
...

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.5:6443 --token tplxfo.kd2imdc9ykxj32oo \
	--discovery-token-ca-cert-hash sha256:3e56a146c0ef5e12a802c6e2053bd5d8e292e623a0a980de492de885566dc361 
```

### Install CNI(Calico)
```
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
kubectl apply -f ./calico.yaml

...
...
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrole.rbac.authorization.k8s.io/calico-cni-plugin created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-cni-plugin created
daemonset.apps/calico-node created
deployment.apps/calico-kube-controllers created
```

## Prepare worker nde
### kubeadm join(on each worker node)

```
hugh@worker1:~ $ sudo kubeadm join 192.168.0.5:6443 --token tplxfo.kd2imdc9ykxj32oo \
        --discovery-token-ca-cert-hash sha256:3e56a146c0ef5e12a802c6e2053bd5d8e292e623a0a980de492de885566dc361
[preflight] Running pre-flight checks
	[WARNING SystemVerification]: missing optional cgroups: hugetlb
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

hugh@worker1:~ $ 
```

## Done
```
hugh@master:~ $ kubectl get po -A
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-7ddc4f45bc-9pnx2   1/1     Running   0          56m
kube-system   calico-node-47qww                          1/1     Running   0          17m
kube-system   calico-node-7jhns                          1/1     Running   0          56m
kube-system   calico-node-bcc6k                          1/1     Running   0          17m
kube-system   calico-node-ktb4h                          1/1     Running   0          17m
kube-system   coredns-5dd5756b68-2v7jg                   1/1     Running   0          58m
kube-system   coredns-5dd5756b68-5mzgx                   1/1     Running   0          58m
kube-system   etcd-master                                1/1     Running   5          59m
kube-system   kube-apiserver-master                      1/1     Running   7          59m
kube-system   kube-controller-manager-master             1/1     Running   0          59m
kube-system   kube-proxy-4frxk                           1/1     Running   0          17m
kube-system   kube-proxy-bsxdb                           1/1     Running   0          17m
kube-system   kube-proxy-pc8ld                           1/1     Running   0          17m
kube-system   kube-proxy-scnbt                           1/1     Running   0          58m
kube-system   kube-scheduler-master                      1/1     Running   9          59m
```
### Test - deployment

### Create nginx deployment
```sh
kubectl create deployment nginx --image=nginx
deployment.apps/nginx created
```

### Expose NodePort
```sh
kubectl expose deployment nginx --type=NodePort --port=80 --target-port=80
service/nginx exposed
```

### Access nginx via exposed port
nginx exposes `32273` port. Let's access web page through the port.
```
kubectl get svc -A
NAMESPACE     NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
default       kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP                  62m
default       nginx        NodePort    10.103.92.240   <none>        80:32273/TCP             8s
kube-system   kube-dns     ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   62m
```

{{< figure src="/images/raspberry-pi-nginx-test.png">}} 
