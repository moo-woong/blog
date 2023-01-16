---
title: "[Kubernetes Study] k8s components - kube-apiserver"
date: 2023-01-16T22:50:26+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## kube-apiserver?

`kube-apiserver`는 Kubernetes Cluster를 구성하데 필수적인 컴포넌트로, Cluster를 구성하는 컴포넌트들과 통신을 통해 최신의 상태를 유지할 수 있도록 합니다.

운용자가 `kubectl`을 통해 CLI 명령을 한다면, `kubectl`은 사용자의 인증을 진행한 후 변수에 설정된 `kube-apiserver`주소로 REST Query를 수행합니다. 운용자가 `kubectl get node`명령어를 통해 현재 cluster에 join 한 노드들의 정보를보려고 한다고 가정하겠습니다. `kubectl`은 가장 먼저 kube-apiserver는 요청의 정당성을 확인 한 후, `kubectl`을 통해 요청한 정보 처리를 위해 관련된 정보를 etcd에 쿼리하여 정보를 받아서 운용자에게 응답합니다.

{{< figure src="/images/kubernetes/kube-apiserver-query.png">}}

## REST Server
`kube-apiserver`로 REST API로 query를 한다고 했듯이, `kube-apiserver`는 REST API를 제공하고 있어, 해당하는 서버로 직접 통신할 수 있습니다. 운용자는 `curl`과 같은 REST Client를 통해서 인증 과정을 거친 후 Pods create와 같은 명령을 REST Client를 통해서 할 수 있습니다.

## kube-scheduler
`kube-scheduler`는 `kube-apiserver`를 계속해서 모니터링합니다. `kubectl get pod`와 같이 GET operation이 아닌 Pod를 생성하는 명령이 진행된다면 `kube-apiserver`는 에`kube-scheduler` Pod 생성이라는 이벤트를 전달합니다. `kube-scheduler`는 가용 가능한 Node들을 확인하고 해당 노드를 회신합니다.

{{< figure src="/images/kubernetes/kube-apiserver-create.png">}}

`kube-apiserver`는 Node정보를 획득한 후 `etcd`에 상태업데이트 후 Node에 설치되어 있는 `kubelet`에 Pod생성을 요청합니다. `kubelet`는 Worker Node에 설치되어있는 컨테이너 런타임(CRI-O, Containerd, Docker 등)을 통해 Pod를 생성 후 `kube-apiserver`에 결과를 통보합니다. `kubelet`으로 부터 정보를 받은 후에는 다시 `etcd`에 상태정보를 업데이트합니다.

Pod 생성과 같은 작업 뿐만 아니라 그 외에 많은 Cluster 관리 명령들은 위 예시와 대동소이하게 동작합니다. 설명 중간에 `etcd` 조회 및 업데이트 작업이 있는데, `kube-apiserver`는 타 컴포넌트들과의 오케이스트레이션을 담당하기 때문에 `etcd`에 대한 업데이트 권한은 `kube-apiserver`밖에 없습니다. 
이처럼 `kube-apiserver`는 클러스터를 구성하는 Control Plane Components들의 오케스트레이션을 담당하는 중요한 역할을 수행합니다. 
