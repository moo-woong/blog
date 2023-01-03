---
title: "Ubuntu에 Minikube 설치하기"
date: 2022-11-01T22:54:51+09:00
categories: ["Kubernetes"]
tags: ["개발환경"]
---

# Minikube 설치
 Kubernetes 학습을 위해서 환경이 필요하게 되었습니다. 개인 학습을 위해서는 Vanilla k8s, Amazon EKS, 그리고 Minikube 등 다양한 학습환경이 있습니다. 저는 Minikube로 선택했습니다. 이유는 다음과 같습니다.
 - Vanilla k8s는 환경설정에 많은 리소스도 필요하고 회사에서 proxy환경에서 설치하는데 애를 많이 먹은 기억이 있어서 환경설정에 많은 시간을 할애하기 싫었습니다.
 - Amazon EKS는 간단하게 구축이 가능하지만 약간의 비용이 발생할 수 있다는 점, 그리고 지지고 볶고 뜯고 맛보고 즐겨야하는데 EKS에서는 잘 할 수 있을까?에 대한 의구심이 있어 Amazon EKS 사용은 나중으로 미뤘습니다.
 
# 구축 환경
- Host machine: Windows 10
- Guest machine: Ubuntu 20.04 LTS

# 설치
## apt update
```
sudo apt update
sudo apt install apt-transport-https
sudo apt upgrade
```
## Virtualbox Hypervisor
하이퍼바이저(Hypervisor)는 가상머신을 운용하는데 필요한 기능들을 제공해주는 도구입니다. 가상머신이 동작하기 위해서는 CPU,Memory,Disk 등의 하드웨어 자원을 공유하고 관리하는 도구가 필요합니다. 운영체제가 없이 하이퍼바이저를 설치할 수도 있지만 우리는 Host OS(저의 경우는 Ubuntu)에서 동작하며 Host OS의 자원을 공유하는 하이퍼바이저를 Hosted Architecture로 부르기도 합니다.
```
sudo apt install virtualbox virtualbox-ext-pack
```

설치를 실행하면 License 확인창이 나오고 별다른 문제 없이 설치가 완료됩니다.

## Minikube 다운로드
Minikube는 apt를 이용하지 않고 wget으로 웹서버에서 바로 다운받습니다. 다운받은 Minikube binary를 `$PATH`에 등록하여 바로 실행가능하게 만듭니다.
```
# wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
# chmod +x minikube-linux-amd64
# sudo mv minikube-linux-amd64 /usr/local/bin/minikube
```
{{< figure src="/images/minikube_download.png">}}

## kubectl 설치
kubectl을 설치해보겠습니다. kubectl은 CLI툴로, kubernetes의 api-server와 통신하여 리소스 관리등의 다양한 작업을 수행할 수 있습니다.
```
# cd /tmp
# curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
# chmod +x ./kubectl
# sudo mv ./kubectl /usr/local/bin/kubectl
```
Minikube를 다운로드하고 권한설정, `$PATH` 경로로 이동시켰던 것 처럼 kubectl도 동일하게 진행합니다.

{{< figure src="/images/verify_kubectl.png">}}
정상적으로 kubectl을 사용할 수 있게 되었네요. 

## Docker 설치

```
# sudo mkdir -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update
# sudo apt-get install docker-ce docker-ce-cli containerd.io
# sudo usermod -aG docker $USER
```
위의 명령어들의 내용은 아래와 같습니다.
1. docker의 GPG key 등록
2. docker repository를 apt의 repository에 등록
3. apt repository 업데이트
4. docker 설치
5. 현재 유저를 docker 권한에 등록하여 sudo 없이 사용

## cri-o 설치
### 환경설정
```
# export OS_VERSION=xUbuntu_20.04
# export CRIO_VERSION=1.23
```
### CRI-O official GPG 키 등록
```
# curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS_VERSION/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-archive-keyring.gpg
# curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS_VERSION/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/libcontainers-crio-archive-keyring.gpg
```
### CRI-O apt repository 등록
```
# echo "deb [signed-by=/usr/share/keyrings/libcontainers-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS_VERSION/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
# echo "deb [signed-by=/usr/share/keyrings/libcontainers-crio-archive-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS_VERSION/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
```
### apt 업데이트
```
sudo apt update
```
### CRI-O 설치
```
sudo apt install -y cri-o cri-o-runc
```
### CRI-O 서비스실행 및 부트 시 자동실행 등록
```
# sudo systemctl daemon-reload
# sudo systemctl enable crio
# sudo systemctl start crio
```

## crictl 설치

```
# VERSION="v1.24.1"
# curl -L https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-${VERSION}-linux-amd64.tar.gz --output crictl-${VERSION}-linux-amd64.tar.gz
# sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/bin
# rm -f crictl-$VERSION-linux-amd64.tar.gz
```

## conntrack 설치
에러로그
```
😄  minikube v1.27.1 on Ubuntu 20.04
✨  Using the none driver based on user configuration

❌  Exiting due to GUEST_MISSING_CONNTRACK: Sorry, Kubernetes 1.25.2 requires conntrack to be installed in root's path
```

Kubernetes에서는 `conntrack`라는 네트워크 연결을 추적 및 관리하는 툴을 사용합니다. minikube를 실행하려는데 `conntrack`가 없으면 오류가 발생하니 `conntrack`를 설치해 줍시다.
```
# sudo apt-get install -y conntrack
```

## Minikube 실행
이제 준비는 모두 끝났습니다. 한번 실행해 보겠습니다. minikube를 실행하면 가장 처음으로는 가상이미지를 다운로드하고 single node cluster를 구성해줍니다.

```
# minikube start --vm-driver=none
```
{{< figure src="/images/minikube_running.png">}}

Done!이 나오면 정상적으로 minikube가 실행되고 있는겁니다. 초반에 설치했던 kubectl을 이용해서 kubernetes의 리소스를 살펴보겠습니다.

{{< figure src="/images/kubectl_result.png">}}
리소스들이 정상적으로 Running 상태에 있네요.
