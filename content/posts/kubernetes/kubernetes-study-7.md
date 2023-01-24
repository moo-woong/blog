---
title: "[Kubernetes Study] k8s components - kube-proxy"
date: 2023-01-24T22:39:01+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## kube-proxy?

Kubernetes cluster내에서는 같은 네임스페이스에 있는 각 Pod들은 다른 Pod들과 통신이 가능합니다. 설령 다른 워커노드에 설치된 Pod들도 마찬가지로 통신이 가능합니다. 이러한 통신을 위해서 Pod 네트워크가 필요하며, Pod 네트워크는 내부 가상 네트워크입니다. 

{{< figure src="/images/kubernetes/kube-proxy.svg">}}

저는 웹서비스 하나를 운용하고 있으며, 이를 Kubernetes를 통해 운용하고 있다고 가정하겠습니다. 저의 Backend 서버는 Node1에 배치되어 있고, 서비스의 정보를 영구적으로 저장하기 위해 데이터베이스를 사용하며, 데이터베이스는 Node2에 배치되어있습니다.

{{< figure src="/images/kubernetes/kube-proxy2.svg">}}

Backend 서버는 IP(10.32.0.35)를 통해 데이터베이스에 접근할 수 있습니다. 하지만 데이터베이스가의 IP가 항상 해당 IP를 갖는다는 보장이 없습니다. 따라서 Backend 서버는 IP가 아닌 데이터베이스를 특정한 이름을 가지고 접근해야 합니다. 이러한 접근방식은 `Service`라는 개념이며, 추후에 다루어질 예정입니다. 이제 Backend는 DB라는 서비스이름으로 접근할 수 있습니다. 

{{< figure src="/images/kubernetes/kube-proxy3.svg">}}

DB 서비스는 DNS처럼 DB라는 이름이 있으며, 실제로는 IP와 DB라는 이름을 매핑하여 사용하고 있습니다. DB서비스는 Pod와 같은 실체가 있는 컴포넌트가 아닙니다. 하지만 어떻게 DB 서비스는 어떻게 IP와 이름을 매핑할까요? `kube-proxy`는 서비스가 DNS역할을 할 수 있도록 합니다. 

{{< figure src="/images/kubernetes/kube-proxy4.svg">}}

`kube-proxy`는 Cluster를 구성하는 각 워커노드들에 설치되며 새로운 서비스가 생성될 때 마다 각 노드들에 설치되는 Pod에 접근할 수 있도록 `iptables`와 같은 룰을 서비스들에게 올바르게 알려주는 역할을 합니다. 

{{< figure src="/images/kubernetes/kube-proxy5.svg">}}

Node1의 `kube-proxy`는 `10.32.0.15`로 접근하기 위해서는 서비스의 주소인 `10.96.0.12`를 통해 접근할 수 있음을 서비스에 알려줍니다. 이러한 관련 정보를 관리하고 알려주는 `kube-proxy`를 통해서 각 Pod들은 배치된 노드에 상관 없이 권한이 있다면 해당하는 Pod에 접근할 수 있습니다. 

```
hugh@master:~$ kubectl get po -A -o wide  | grep kube-proxy
kube-system   kube-proxy-9hhnn                 1/1     Running             0                9d    192.168.83.137   worker3   <none>           <none>
kube-system   kube-proxy-npxnt                 1/1     Running             0                9d    192.168.83.136   worker2   <none>           <none>
kube-system   kube-proxy-pckqp                 1/1     Running             0                9d    192.168.83.135   worker1   <none>           <none>
kube-system   kube-proxy-z26nh                 1/1     Running             0                9d    192.168.83.134   master    <none>           <none>
```

Vanilla Kubernetes를 설치했다면 Cluster를 구성하는 master, 워커노드들 마다 설치된 `kube-proxy`를 확인할 수 있습니다. 