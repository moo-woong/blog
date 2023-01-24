---
title: "[Kubernetes Study] k8s components - kube-scheduler"
date: 2023-01-24T21:56:21+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## kube-scheduler?

[앞선 포스팅](https://moo-woong.github.io/posts/kubernetes/kubernetes-study-1/#kube-scheduler)에서 언급된것 처럼 `kube-shceduler`는 Pod를 배치할 때 어느 노드에 배치될지 결정합니다. `kube-scheduler`는 Pod의 배치만 결정할 뿐 실제 Pod를 Node에 배치하는 것은 각 노드에 설치된 `kubelet`이 관장합니다. 

`kube-scheduler`의 역할은 언뜻 보기에는 간단해보입니다. 하지만 실제로는 간단한 작업만을 담당하지 않습니다..! 

Cluster에는 수 각 Node에 배치될 수 많은 Pod가 있고, Worker node로 동작하는 Node들이 있을 수 있습니다. Pod가 요구하는 리소스, tolerations, nodeAffinity 등 예외조건들이 있을 수 있으며 현재 노드의 유휴 리소스에 따라 배치 가능한 Pod가 있을 수도, 없을수도 있습니다. 이러한 Combination을 `kube-scheduler`가 확인하여 알맞은 노드에 설치될 수 있도록 판단합니다.

## Pod의 설치 판단 기준
`kube-scheduler`는 현재 유휴 노드들 중에서 Pod의 요구조건에 최대한 알맞은 노드를 판단합니다. 

여기 배치될 Pod가 있습니다. 해당 Pod는 CPU자원을 10을 사용합니다. 그리고 다음과 같이 현재 노드의 CPU유휴 자원이 4,4,12 그리고 16인 노드가 있습니다.

{{< figure src="/images/kubernetes/kune-scheduler.svg">}}

먼저 `kube-scheduler`는 Pod의 요구사항을 만족시키지 못하는 Node들을 제외합니다. 이 중 `Node1`, `Node2`는 유휴 CPU 리소스가 4라서 제외됩니다. 이 과정에서 CPU뿐만 아니라 Pod가 요구하는 다른 리소스들(memory, ephemeral-storage)등 또한 필터링 조건으로 사용됩니다. 남은 두 노드중에서 `kube-scheduler`는 노드의 `Rank`를 통해서 최선의 노드를 선택합니다. `Rank`는 0-10까지 수치화된 점수입니다. 한 가지 예로 Pod가 설치된 이후의 유휴 리소스가 수치화될 수 있습니다. 위 노드들 중에서 `Node4`는 현재 Pod가 배치된 이후에 6의 CPU리소스가 남게되어 더 높은 점수를 받아 해당 Pod는 `Node4`에 배치됩니다.

이러한 상위 레벨의 동작은 기본 `kube-scheduler`의 동작이며, DevOps 엔지니어를 통해 보다 조직에 알맞은 알고리즘을 적용하여 사용할 수 있습니다.

Vanilla kubernetes를 설치했다면 `kube-system` 네임스페이스에 `kube-scheduler` Pod를 확인할 수 있습니다.

```
hugh@master:~$ kubectl get po -n kube-system
NAME                             READY   STATUS              RESTARTS         AGE
coredns-787d4945fb-jgwpn         0/1     ContainerCreating   0                9d
coredns-787d4945fb-z2km8         0/1     ContainerCreating   0                9d
etcd-master                      1/1     Running             23               9d
kube-apiserver-master            1/1     Running             22               9d
kube-controller-manager-master   1/1     Running             10 (4d13h ago)   9d
kube-proxy-9hhnn                 1/1     Running             0                9d
kube-proxy-npxnt                 1/1     Running             0                9d
kube-proxy-pckqp                 1/1     Running             0                9d
kube-proxy-z26nh                 1/1     Running             0                9d
kube-scheduler-master            1/1     Running             11 (4d13h ago)   9d
```