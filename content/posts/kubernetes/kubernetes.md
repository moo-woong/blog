---
title: "VMWare로 Kubernetes 설치하기"
date: 2023-01-03T20:46:06+09:00
categories: ["Kubernetes"]
tags: ["개발환경"]
---

## VM생성 및 설정
2개 이상의 CPU Core, 2G이상의 메모리를 설정하여 VM을 생성합니다.
저는 용량이 부족해서 Kubernetes의 최소 요구사항인 2CPU, 2GMem으로 진행하였습니다.
앞으로 진행하는 절차들은 모두 모든 노드에 동일하게 진행합니다.


## Guest OS에 SSH 설치

```
$ sudo apt-get install openssh-server
```

## Docker 설치

기본적인 설치는 `Docker`의 Official [Installation Guide](https://docs.docker.com/engine/install/ubuntu/)를 따릅니다.

### Docker repository 설정

`apt` 관련 repository 설정
```
 $ sudo apt-get update

 $ sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

`Docker`의 공식 GPG Key 추가
```
$ sudo mkdir -p /etc/apt/keyrings

$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

추가된 Repository를 update
```
$ sudo apt-get update
```

### Docker engined, containerd, docker compose 설치
```
$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### Docker 설치 확인
hello-world 이미지를 다운로드 및 실행하여 Docker가 정살적으로 설치되었는지 확인
```
$ sudo docker run hello-world
```

정상적이라면 다음처럼 hello-world:latest를 다운받고 실행됨.
```
hugh@ubuntu:~$ sudo docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete 
Digest: sha256:94ebc7edf3401f299cd3376a1669bc0a49aef92d6d2669005f9bc5ef028dc333
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

hugh@ubuntu:~$ 
```

## kubeadm, kubelet, kubectl 설치

kubernetes cluster의 필수 패키지를 설치합니다. [공식 사이트](https://kubernetes.io/ko/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)를 참조하여 설치하였습니다.

>kubeadm: 클러스터의 bootstrap 명령어

>kubelet: 클러스터의 워커노드에서 api-server의 명령을 받아 작업을 수행하는 컴포넌트

>kubectl: kubernetes api-server와 통신하는 CLI 유틸

### dependencies 패키지 설치
```
$ sudo apt-get update
$ sudo apt-get install -y apt-transport-https ca-certificates curl
```

### Official GPG 키 등록
```
$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```


>2023-09-10 기준, google gpg의 url이 valid하지 않습니다. 

```
W: GPG error: https://packages.cloud.google.com/apt kubernetes-xenial InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY B53DC80D13EDEF05
E: The repository 'https://apt.kubernetes.io kubernetes-xenial InRelease' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
```

다음의 주소로 사용해보세요.

```
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg
```

```
$ echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

### apt index 업데이트 및 패키지 설치
```
$ sudo apt-get update
$ sudo apt-get install -y kubelet kubeadm kubectl
$ sudo apt-mark hold kubelet kubeadm kubectl
```

### cgroup 드라이버 설정
컨테이너 런타임, kubelet의 cgroup driver를 일치시켜야 하며, 일치하지 않을 경우 kubelet 프로세스에서 오류가 발생하므로 일치시켜주는 작업을 진행합니다. cgroup driver는 `cgroupfs`와 `systemd`가 있으며 kubelet v1.21.0 이상부터는 `systemd`가 기본입니다. 우리가 사용하는 컨테이너 런타임은 `Docker` 이므로 `Docker`의 cgroup을 `cgroupfs` 에서 `systemd`로 변경하도록 합니다.

>cgroup은 리눅스에서 프로세스에 할당된 리소스를 격리하고 제한하는데 사용합니다. `kubelet`은 자원관리를 위해 cgroup을 사용합니다.

Docker의 cgroup 드라이버 확인
```
hugh@ubuntu:~$ sudo docker info | grep Cgroup
 Cgroup Driver: cgroupfs
 Cgroup Version: 1
```

Docker service 설정파일 변경

Ubuntu에서 정상적으로 docker를 설치했다면 다음의 경로의 파일이 존재합니다.
- `/usr/lib/systemd/system/docker.service`

해당 파일의 `ExecStart`변수를 다음과 같이 수정해주세요.

수정 전
```
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

수정 후
```
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd
```

daemon 리로드 및 docker service를 재시작
```
$ systemctl daemon-reload 
$ systemctl restart docker
```

docker의 cgroup 확인
```
hugh@ubuntu:~$ sudo docker info | grep Cgroup
 Cgroup Driver: systemd
 Cgroup Version: 1
```

## swap 설정 off

kubernetes에서는 최대한의 자원을 활용하게 하므로 worker node의 리소스를 최대한 사용합니다. swap이 발생할 경우 속도 저하가 발생합니다. 또한 `kubelet`이 swap에 대해 고려하지 않습니다. 따라서 모든 노드들에 swap을 off합니다.

```
$ sudo swapoff -a
```

부팅 시 swapoff를 위해 `/etc/fstab`을 수정합니다.
```
$ sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

## hostname 변경 및 /etc/hosts 등록
kubernetes의 hostname은 고유해야 합니다. 이를 위해서 master 노드와 worker 노드의 hostname을 변경해야합니다. 저는 master 노드와 worker 노드 3대로 이루어져 있어서 다음과 같이 구성하였습니다.

```
master
worker1
worker2
worker3
```

각 노드에서 알맞은 hostname으로 변경 
```
$ sudo hostnamectl set-hostname <노드명>
```
`/etc/hosts`에서 localhost의 hostname을 변경
```
127.0.0.1       localhost
127.0.1.1       master # <-- 변경부분

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
```

## master node 설정

마스터노드의 설정을 진행합니다.

```
$ sudo kubeadm init
```

`"Status from runtime service failed"` 오류가 발생할 수 있습니다.
```
hugh@master:~$ sudo kubeadm init --pod-network-cidr 192.168.0.0/16
[sudo] password for hugh: 
[init] Using Kubernetes version: v1.26.0
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR CRI]: container runtime is not running: output: E0103 20:21:46.201539    1806 remote_runtime.go:948] "Status from runtime service failed" err="rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"
time="2023-01-03T20:21:46-08:00" level=fatal msg="getting status of runtime: rpc error: code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService"
, error: exit status 1
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```
* `--pod-network-cidr` subnet은 이 cluster에서 생성되는 Pod들의 network를 명시하는 설정입니다.
* `--pod-network-cidr`는 `calico` CNI를 설치할때 default로 사용되는 subnet이라서 해당 subnet을 사용하도록 명시하였습니다.


위와 같이 오류가 발생한다면 초기화를 진행해주세요.
```
$ sudo rm /etc/containerd/config.toml
$ sudo systemctl restart containerd
```
이후 다시 `kubeadm init`을 실행하여 성공적으로 진행되었는지 확인합니다.

```
...OMMITTED...

[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.83.134:6443 --token zifa73.5r6d1i6a0ouptd9c \
	--discovery-token-ca-cert-hash sha256:9dd31647a596dfb748d6f5c1a6def414b9e13f51041782c6872fde6921f11859 
hugh@master:~$
```

>여기까지 진행했는데 `master`노드의 용량이 부족했습니다. 처음에 10G로 잡았는데... 너무 욕심이었네요, 20G로 VM의 사이즈를 늘리고 계속 진행했습니다.

`kubeadm init`을 완료하면 위 로그에서 나오는것 처럼 master 노드에서 진행할 추가 작업을 안내합니다.
```
To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
해당 절차를 진행합니다.

또한 worker 노드에서 `kubeadm join`을 수행하라고 안내가 나타납니다. 이제 worker 노드에서 `join`을 합니다.

## worker 노드 설정

`kubeadm init`에서 안내된 내용대로 worker 노드를 master 노드에 join 합니다.
>해당 내용은 master node의 IP에 따라 다르므로 알맞게 설정합니다.


```
$ kubeadm join 192.168.83.134:6443 --token zifa73.5r6d1i6a0ouptd9c \
	--discovery-token-ca-cert-hash sha256:9dd31647a596dfb748d6f5c1a6def414b9e13f51041782c6872fde6921f11859 
```

워커 노드에서 명령어 실행 시 `kubeadm init`에서 발생한 에러가 동일하게 나타날 수 있습니다. master 노드에서 진행한 동일한 커맨드로 containerd를 재시작 후 join을 수행합니다.

다음과 같이 로그나 나오면 정상적으로 join이 된것입니다.
```
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

## 네트워크 구성

마스터 노드와 워커노드의 환경설정을 완료했습니다. 마스터 노드에서 `kubectl get no`를 통해서 nodes들의 상태를 확인해봅니다.

```
hugh@master:~$ kubectl get nodes
NAME      STATUS     ROLES           AGE     VERSION
master    NotReady   control-plane   21m     v1.26.0
worker1   NotReady   <none>          3m11s   v1.26.0
worker2   NotReady   <none>          62s     v1.26.0
worker3   NotReady   <none>          57s     v1.26.0
```

마스터 노드는 worker노드들의 존재를 알지만 STATUS가 NotReady입니다. 이는 pod network가 현재 deploy된 상태가 아니기 때문입니다.
pod network를 설치해봅니다.

다양한 `CNI(Container Network Interface)`가 있지만, 저는 `calico`를 설치해보겠습니다.

Calico 설정파일 다운로드
```
hugh@master:~$ cd ~/calico/
hugh@master:~/calico$ curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
```
> calico 주소는 변경될 수 있습니다. 2023-09-10 기준으로는 https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml 로 redirect 되므로, 변경된 주소로 사용해야 합니다.

Calico CNI 설치
```
hugh@master:~/calico$ kubectl apply -f calico.yaml 
poddisruptionbudget.policy/calico-kube-controllers created
serviceaccount/calico-kube-controllers created
serviceaccount/calico-node created
configmap/calico-config created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/caliconodestatuses.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipreservations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
daemonset.apps/calico-node created
deployment.apps/calico-kube-controllers created
```

정상설치 되었다면 calico관련 pod들이 Running status인것을 확인할 수 있습니다.
```
hugh@master:~/calico$ kubectl get po -A
NAMESPACE     NAME                                      READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-57b57c56f-bmcnw   1/1     Running   0          105s
kube-system   calico-node-djvgt                         1/1     Running   0          105s
kube-system   calico-node-g9bcp                         1/1     Running   0          105s
kube-system   calico-node-hdwtj                         1/1     Running   0          105s
kube-system   calico-node-nhdpq                         1/1     Running   0          105s
kube-system   coredns-787d4945fb-9vcsv                  1/1     Running   0          9m30s
kube-system   coredns-787d4945fb-kxtsk                  1/1     Running   0          9m30s
kube-system   etcd-master                               1/1     Running   24         9m44s
kube-system   kube-apiserver-master                     1/1     Running   0          9m45s
kube-system   kube-controller-manager-master            1/1     Running   0          9m46s
kube-system   kube-proxy-9zkvx                          1/1     Running   0          2m29s
kube-system   kube-proxy-lkdk6                          1/1     Running   0          9m30s
kube-system   kube-proxy-nc56s                          1/1     Running   0          4m34s
kube-system   kube-proxy-tw5xc                          1/1     Running   0          3m14s
kube-system   kube-scheduler-master                     1/1     Running   0          9m44s
```

설치 후 node들이 정상적으로 Ready 상태로 변경된걸 확인할 수 있습니다.

```
$ kubectl get no
NAME      STATUS   ROLES           AGE   VERSION
master    Ready    control-plane   40m   v1.26.0
worker1   Ready    <none>          21m   v1.26.0
worker2   Ready    <none>          19m   v1.26.0
worker3   Ready    <none>          19m   v1.26.0
```

## 동작 확인

kubernetes 관련 컴포넌트, 마스터 및 워커노드 설정이 완료되었습니다. 임의의 pod를 설치하여 정상적으로 동작하는지 확인해보겠습니다.

### Deployment 설치
```
$ kubectl create deployment nginx --image=nginx
```
### NodePort Service 설치
```
$ kubectl expose deployment nginx --type=NodePort --port=80 --target-port=80

$ kubectl get svc
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        43m
nginx        NodePort    10.106.136.69   <none>        80:30910/TCP   8s
```

### Master 노드를 통해 nginx 서비스 접근 확인

{{< figure src="/images/kubernetes/nginx_access.png">}}