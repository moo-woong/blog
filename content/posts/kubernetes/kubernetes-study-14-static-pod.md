---
title: "Kubernetes Study 14 Static Pod"
date: 2024-02-13T13:24:42Z
draft: true
---

## Static Pod란?

kubelet은 kube-apiserver를 통해서 Pod가 어떤 노드에 배치되어야 하는지 알아낸다.
이러한 Node를 결정하는 것은 kube-scheduler에 의해 결정되며, ETCD 데이터베이스에 저장된다.

이러한 일련의 작업을 해주는 k8s의 기본 리소스인 kube-apiserver와 kube-scheduler, ETCD 등이 없다면 어떻게 될까?

각 워커노드에서 동작하는 kubelet은 독립적으로 동작할 수 있다.
만약 Pod설정 정보인 yaml파일들이 `/etc/kubernetes/manifests` 하위에 있다면, kubelet은 해당 파일들을 주기적으로 검사해서
yaml에 설정된 대로 Pod들을 설치할 것이다.

파일이 존재한다면 Pod를 생성하는것 뿐만 아니라 Pod내에 container의 재시작, Pod 재생성 등의 작업 또한 가능하다.

그리고 Pod정보가 `/etc/kubernetes/manifests`에서 지워진다면, Pod또한 삭제된다.

이처럼 kubelet이 kube-apiserver와 통신하지 않고 직접 자신의 워커노드에서 Pod들을 생성 및 관리하는 것을 Static Pod라고 한다.

> 위와 같은 방법으로는 Pod만 생성할 수 있으며, Deplyment, StatefulSet, Service등의 리소스는 생성할 수 없다.

## 폴더 경로

기본 경로는 `/etc/kubernetes/manifests` 이나, 이는 kubelet 옵션으로 변경이 가능하다.

systemd 설정파일인 `/etc/systemd/system/kubelet.service.d/10-kubeadm.conf` 를 확인하면 다음과 같다.
{{< figure src="/images/kubernetes/14-kubelet-service.png">}}

해당 설정엣 다음과 같이 `config`에서 yaml파일을 지정한다.

{{< figure src="/images/kubernetes/14-kubelet-service-2.png">}}

kubeconfig.yaml은 다음과 같이 설정한다.
```
staticPodPath: /etc/kubernetes/manifests
```

## kube-apiserver와 static Pod

kubelet이 kube-apiserver와 통신하지 않고 staticPodPath를 이용해 Pod를 생성해도 kube-apiserver는 Pod를 인지할 수 있다.
이게 가능한 이유는 kubelet이 kube-apiserver에 object를 미러링해서 동일하게 만들기 때문이다. 하지만 kube-apiserver를 이용해서 설정하는 kubectl을 사용할 수 없으므로, kubectl을 이용한 Pod정보 수정등은 불가능하고 삭제만이 가능하다. 
kube-apiserver를 통해 보여지는 pod의 이름은 아래와 같이 node이름이 suffix로 추가된다.

{{< figure src="/images/kubernetes/14-node-name.png">}}


## Use case - master 노드들의 기본 Pod 설정
그러면 왜 Static Pod와 같은걸 k8s에서 지원할까? 다음과 같은 시나리오를 상정할 수 있다.

여러 master 노드에서 각자 k8s 필수 object들을 static pod로 설정할 수 있다.

{{< figure src="/images/kubernetes/14-master.png">}}

이와 같은 설정을 한다면 특정 object가 crash 될 때, kube-apiserver와 통신이 불가능 해도 kubelet 자체적으로 pod를 재시작 할 수 있어 복구가 가능하다. 

## Static Pod와 DaemonsSet의 차이

- Static Pod는 kubelet에 의해 생성되나, DaemonSet은 kube-apiserver(Daemonset Controller)를 통해 생성된다.
- 두 설치 과정 모두 kube-scheduler에 의해 관리되지 않는다.
