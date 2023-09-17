---
title: "Kubernetes Raspberry Pi"
date: 2023-09-10T15:17:57+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

# 라즈베리파이로 Kubernetes 클러스터 구축하기

회사에서 동일한 구글계정을 사용해서 그런지 유튜브에 Satisfying 비디오로 서버실 선정리, 라즈베리파이로 쿠버네티스 구축하기 등 영상들이 올라왔다. 신기하네, 재밌네 로 끝났었는데 한 한국인 블로거가 빠른 실행력으로 라즈베리파이로 클러스터를 구축한 포스트를 보고 나도 하기로 마음먹었다.

https://www.binaryflavor.com/raspberry-pi-kubernetes-1/

# 구성

*환경 구성*
- 라즈베링파이4 모델B 4GB 메모리, 128GB SD Card * 4대
- L2용 8포트 iptime공유기

라즈베리파이는 6대를 준비하였으나, 2대는 추후에 master node, worker node추가 실습용으로 남겨두고, 1대의 마스터노드, 3대의 워크노드로 클러스터를 구축하기로 했다.

# 구축

라즈베리파이에 방열판 붙이고, 책상에 여유공간을 만든다고 정리도 했더니 랜선과 파워케이블이 너무 길어 도저히 눈뜨고 봐줄 수 없었다.
쿠팡으로 급하게 30cm 랜선과 전원용 USB A ot C type을 주문했다.

{{< figure src="/images/kubernetes/kube-raspberry/coupang.jpg">}}

# 준비 및 설치

## 이미지 준비
아래 경로에서 Raspberry Pi Imager를 다운받을 수 있다.

https://www.raspberrypi.com/software/

추가적으로 iso이미지를 준비하지 않아도 Imager에서 이미지를 선택하면 다운로드 및 부트이미지로 만들어 준다. 나는 CentOS를 사용하고 싶었는데, 라즈베리파이용 이미지가 준비되어 있긴 하지만 Imager에서 지원하지 않아 Ubuntu Server 22.04로 진행했다.

{{< figure src="/images/kubernetes/kube-raspberry/imager.png">}}

## 이미지 설치
라즈베리파이를 처음 설치해봐서 몰랐는데, 운영체제 설치과정이 없다. 그래서 처음 부팅한 후 로그인 프롬프트가 떠서 많이 당황했다. 설치과정이 없고 cloud-init이라고 처음에 부팅시간이 좀 더 걸리는것 같다. 이 과정이 약 2분이 걸릴 때도 있다. 

그래서 구글링 후 기본 설정 계정을 찾아보니 `ubuntu/ubuntu` 였다. 근데, 난 접속이 안된다... 계속 incorrect오류로 로그인을 할 수 없었다. 계정명을 `pi`로도 해보고 `passwd` 시도해 봤지만 여전히 안된다. 추가적으로 구글링 해보니 Imager에서 계정을 설정할 수 있었다.

{{< figure src="/images/kubernetes/kube-raspberry/credential.png">}}

설치 OS를 선택하면 톱니바퀴 모양의 설정이 나타나는데, 이 때 hostname, user 정보등을 설정할 수 있다. 나의 경우 여기서 설정한 계정으로 로그인이 가능했다.

## SSH 설정
Imager에서 설정 가능한 항목에 SSH설정도 있었다. SSH 비밀번호 접속으로 설정했는데, 부팅완료 및 DHCP IP가 할당된걸 확인하고 해당 IP로 접근하니 `permission denied(publickey)`가 발생한다. 

{{< figure src="/images/kubernetes/kube-raspberry/permission.png">}}

이건 또 뭐냐..하고 검색해보니 `/etc/ssh/sshd_config` 의 `PasswordAuthentication`를 yes로 변경해서 ssh 접속 불가를 해결했다.

{{< figure src="/images/kubernetes/kube-raspberry/ssh.png">}}

이미지 설치, ssh 설정 등 초기 준비를 라즈베리파이 4대 모두에 진행했다.
이후 iptime 설정페이지에서 DHCP로 할당된 IP들을 수동설정하여 MAC마다 IP가 할당되도록 설정했다.

# Kubernetes 설치

## 사전 환경 설정
Master노드 1대와 Worker 노드로 사용할 3대의 라즈베리파이에 Kubernetes 설치 전 사전 환경설정을 진행이 필요하다. 4대 모두 동일한 과정을 수행해야 하므로 번거롭다. 이를 위해 `Terminator` 의 `Broadcast` 옵션을 사용했다. `Terminator`는 내가 사용하는 mux기능을 제공하는 terminal 프로그램이다. 나도 오늘 안건데 하나의 창에서 입력할 때 여러 창에 동시에 입력이 가능하다.

{{< figure src="/images/kubernetes/kube-raspberry/terminator.png">}}

사용방법은 `Terminator`창 에서 좌측 상단에 네모 아이콘 클릭 후 `Broadcast all` 로 설정하면 된다. `Broadcast all`로 변경되면 주 입력창은 빨간색으로, 그 외 수신하는 타 창은 파란색으로 변경되며, 주 입력창에서 입력하는 모든 것들을 파란색 창으로 전달된다.

{{< figure src="/images/kubernetes/kube-raspberry/mux.png">}}


## node 설정 및 설치(라즈베리파이 환경)
이후 다음의 과정을 진행한다.
- Docker repository 설정 및 Docker 설치 
- kubelet, kubectl, kubeadm repository 설정 및 설치
- swapp off
- hostname 변경
- master 노드 설정
- worker 노드 cluster join
- deployment로 동작 확인

설치과정은 이전 포스팅인 [Kubernetes 설치](https://moo-woong.github.io/posts/kubernetes/kubernetes/)와 대동소이하지만, hostname 변경의 경우 라즈베리파이는 `hostnamesctl`로 바로 변경할 수 없다. raspi-config를 통해 변경해야 하므로 `raspi-config`를 설치하고 변경한다.

*raspi-config 설치*
```
sudo apt-get install raspi-config
```
*hostname 변경*
```
1.System Options -> S4 Hostname
``````
또는 `/etc/hostname`을 변경

> NOTE: 라즈베리파이는 `cloud-init` 이 최초에 실행되는데, `cloud-init` 은 호스트 이름, 네트워크 인터페이스 등을 설정한다. 따라서 `raspi-config`나 /etc/hostname, /etc/hosts 변경하고 재부팅 할 경우 설정들이 저장되지 않는다. 따라서 hostname이 변경되지 않도록 `/etc/cloud/cloud.cfg`에서 `preserve_hostname`의 설정을 `true`로 변경하고 작업이 요구된다.

*kernel update*

master 노드에서 kubeadm init 후 worker node에서 join 했는데 잠시 후에 다시 master node에서 `kubectl`을 수행하면 api-server와 연결할 수 없다고 오류가 발생했다. 

```
The connection to the server 127.0.0.1:6443 was refused - did you specify the right host or port?
```


이것 저것 구글링한 해결책을 수행하였지만 대부분 해결책이 아니었고,
나의 경우는 커널 버전을 업데이트 한 후 증상이 재현되지 않았다.
```
sudo apt install linux-modules-extra-raspi && reboot
```

*kubelet & kubectl & kubeadm downgrade*

포스팅일자 기준으로 설치되는 kubelet, kubectl, 그리고 kubeadm은 1.28.1 이다.
근데 worker2에서 containerd가 동작하지 않는다고 계속 cluster join을 못하는게 아닌가?
구글링으로도 해결되지 않아 버전을 강제로 v1.22.8 로 변경 후 cluster를 재구축하니 문제는 발생되지 않았다.
```
sudo apt-get install kubeadm=1.22.8-00 kubelet=1.22.8-00 kubectl=1.22.8-00 -y
```
## 동작 확인
동작 확인을 위한 nginx deployment 설치

```
kubectl create deployment nginx --image=nginx
```
결과 확인
```
kubectl get all
NAME                         READY   STATUS    RESTARTS   AGE
pod/nginx-6799fc88d8-57mwv   1/1     Running   0          4m25s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   24m

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           4m25s

NAME                               DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-6799fc88d8   1         1         1       4m25s

```
