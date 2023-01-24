---
title: "[Kubernetes Study] k8s components - kube-controller-manager"
date: 2023-01-24T17:16:42+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## kube-controller-manager?

`kube-controller-manager`의 역할은 Kubernetes를 구성하하는 다양한 컨트롤러들을 관리하는 것입니다. 컨트롤러들은 운용자로부터 주어진 상태(desired state)를 만족시키기 위해 다음과 같은 역할을 합니다.

- 상태 모니터링
- 상태에 따른 상태 해결(교정)

`node-controller`는 Cluster를 구성하는 노드들의 상태를 모니터링 합니다. 모니터링은 `kube-apiserver`를 통해 수행하며 매 5초 마다 상태관리를 수행합니다. 또한 노드의 이상이 감지될 시 40초간의 Grace period를 두어, 40초 이후에도 health check이 실패할 경우 `NotReady` Status를 만들어 해당 노드로 스케쥴링이 되지 않도록 합니다.

{{< figure src="/images/kubernetes/controller-manager.svg">}}

`repliaction-controller`는 ReplicaSet관리와 desinered Pod 수를 모니터링하고 관리합니다.

이 외에도 Kubernetes에는 `deployment-controller`, `namespace-controller`, `job-controller` 등 많은 Controller가 존재합니다. 이렇게 많은 컨트롤러들은 `kube-controller-manager`라는 프로세스로 패키지화 되어 있습니다. Vanilla Kubernetes를 설치했다면 `kube-controller-manager-master`라는 Pod가 kube-system namespace에서 동작하고 있는것을 확인 할 수 있습니다.

```
hugh@master:~$ kubectl get po -A
NAMESPACE     NAME                             READY   STATUS              RESTARTS         AGE
kube-system   coredns-787d4945fb-jgwpn         0/1     ContainerCreating   0                9d
kube-system   coredns-787d4945fb-z2km8         0/1     ContainerCreating   0                9d
kube-system   etcd-master                      1/1     Running             23               9d
kube-system   kube-apiserver-master            1/1     Running             22               9d
kube-system   kube-controller-manager-master   1/1     Running             10 (4d13h ago)   9d
kube-system   kube-proxy-9hhnn                 1/1     Running             0                9d
kube-system   kube-proxy-npxnt                 1/1     Running             0                9d
kube-system   kube-proxy-pckqp                 1/1     Running             0                9d
kube-system   kube-proxy-z26nh                 1/1     Running             0                9d
kube-system   kube-scheduler-master            1/1     Running             11 (4d13h ago)   9d
hugh@master:~$ 
```