---
title: "[Kubernetes Study] k8s components - kubelet"
date: 2023-01-24T22:22:42+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## kubelet?

[앞선 포스팅](https://moo-woong.github.io/posts/kubernetes/kubernetes-study-1/#kube-scheduler)에서 언급된것 처럼 `kubelet`은 Cluster를 구성하는 모든 워커노드에 설치됩니다. 이후 Pod배치, Pod상태 조회 요청 등 `kube-apiserver`의 요구를 받아 Pod의 설치, 삭제, 조회 등 실제적인 작업을 워커노드에서 수행합니다.

Pod의 설치가 요청되면
1. `kube-scheudler` Pod가 설치될 노드들을 파악 후, `Node1`에 Pod생성을 요청합니다.
2. `kube-scheduler`의 요청을 받은 `kube-apiserver`해당 Pod설치 정보를 `Node1`의 `kubelet`에 요청합니다.
3. `kubelet`은 해당 워커노드의 runtime-engine을 통해 Pod를 생성합니다.
4. 작업완료 후 `kubelet`은 작업완료 내용을 `kube-apiserver`에 알립니다.

{{< figure src="/images/kubernetes/kubelet.svg">}}

`kubelet`은 `kube-apiserver`, `kube-scheduler`와 달리 Vanilla kubernetes에 포함되어 있지 않습니다. (쿠버네티스 설치 포스팅)[https://moo-woong.github.io/posts/kubernetes/kubernetes/]에 기술된 바와 같이 `kubelet`은 설치될 워커노드에 먼저 설치되어 있어야 합니다.

워커노드에 설치된 `kubelet`은 프로세스로 목록으로 확인할 수 있습니다.

```
hugh@worker1:~$ ps -ef | grep kubelet
root        2499       1  0 Jan17 ?        00:56:47 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.9
hugh      387121  387081  0 05:37 pts/0    00:00:00 grep --color=auto kubelet
```