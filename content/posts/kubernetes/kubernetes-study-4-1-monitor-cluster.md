---
title: "[Kubernetes Study] Monitor Cluster Components and Application Logs"
date: 2024-02-27T11:13:52Z
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## Monitor

k8s의 Monitoring 지표들은 다양하다. 다음의 k8s는 다음과 같은 지표들을 확인할 수 있다.

- 노드 레벨의 통계: 클러스터를 구성하는 노드의 개수 및 상태
- 성능지표: CPU, 메모리 사용량, 디스크, 네트워크 I/O
- Pod 레벨지표: Pod의 개수, Pod의 자원 사용량 등

이처럼 다양한 성능지표들을 모니터링 할 수 있으나 중앙화된 관리와 해당 정보를 가공할 수 있는 솔루션이 필요하다.

k8s에는 default로 탑재되는 모니터링 솔루션이 없지만 오픈소스로 공개된 다양한 솔루션들으 있으며 사용할 수 있다. 예를들면 Prometheus, Elastic Stack, Datadog, dynatrace등이 있다. 

### HEAPSTER

힙스터는 k8s의 모니터링 솔루션을 위한 초기 프로젝트였다. 하지만 현재는 deprecated 되었고 `MetricsServer` 라는 간소화된 구조가 만들어졌다.

### [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
metrics server는 cluster 당 1개가 존재한다. metrics server는 in-memory DB이며 pod들의 metric들을 모아 메모리로 저장하고 있으며 디스크에 저장하지 않는다. 따라서 예전 데이터들을 볼 수 없는 한계가 있다. 

#### Metrics Server 동작
k8s의 각 노드는 kubelet 을 통해 api-server와 통신한다. kubelet에는 cAdvisor(Container Advisor)라는 내부 구성요소를 포함하고 있다. cAdvisor는 Pod의 metric들을 수집하고 metrics server와 통신하는 역할을 담당한다. 

{{< figure src="/images/kubernetes/cadvisor.png">}}

#### Metrics Server 설치

k8s vanilla를 설치했으면 다음과 같이 수동으로 설치할 수 있다.

*설치*
```sh
$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
```

설치하면 readiness failure로 metrics server가 정상적으로 실행되지 않는다. 이는 인증서 오류로 기본적으로 TLS 사용 옵션이 켜져있기 때문에 발생한다. 나의 경우에는 private 망이고 테스트 목적이므로 TLS를 사용하지 않고 disable한 후 사용했다. [설정](https://github.com/kubernetes-sigs/metrics-server?tab=readme-ov-file#configuration) 은 다음을 참고한다.

```yaml
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=10250
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls  # <--- 추가
        image: registry.k8s.io/metric
```
`--kubelet-insecure-tls` 옵션을 metrics-server의 deployment에 추가하면 정상동작을 확인할 수 있다.

#### Metrics Server 사용법

```sh
$ kubectl get po -n kube-system | grep metric
metrics-server-98bc7f888-mcfrx             1/1     Running   0          2m31s


$ kubectl top node
NAME      CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
master    328m         8%     2027Mi          54%       
worker1   97m          2%     724Mi           19%       
worker2   99m          2%     753Mi           20%       
worker3   109m         2%     747Mi           20%   
```

다음과 같이 Pod, container의 정보들도 확인할 수 있다.

```sh
hugh@master:~/components $ kubectl top pod
NAME    CPU(cores)   MEMORY(bytes)   
nginx   0m           4Mi             

hugh@master:~/components $ kubectl top pod --containers
POD     NAME    CPU(cores)   MEMORY(bytes)   
nginx   nginx   0m           4Mi       
```

## Application Logs

kubernetes log 확인 방법은 docker의 docker log와 유사하다
```
kubectl logs <pod-name>
```

### Sample
`kodekloud/event-simulator` container를 Pod로 kubernetes에 배치해보자. 해당 container는 랜덤한 이벤트를 발생시키는 컨테이너다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: event-simulator-pod
spec:
  containers:
  - name: event-simulator
    image: kodekloud/event-simulator
  - name: nginx
    image: nginx
```

Pod에 container두개를 동작시키도록 해서 배치했다.
```sh
hugh@master:~/yaml/logging $ k apply -f log.yaml 
pod/event-simulator-pod created
hugh@master:~/yaml/logging $ 
```

사용자의 현재 namespace에서 pod-name의 로그를 출력한다. 

### -f 옵션(streaming)
Pod의 로그를 실시간 스트리밍으로 확인한다. 사용자가 취소하기 전까지 계속 로그를 출력한다.
```
kubectl logs -f <pod-name>
```

### -c 옵션(container)
Pod는 여러개의 container로 구성될 수 있다. `-c`옵션은 container를 선택하는 옵션이며, 여러 container가 있고 -c 옵션이 없다면 첫 번째 container가 기본으로 선택된다.

```
kubectl logs <pod-name> -c <container-name>
```

### example
```
hugh@master:~/yaml/logging $ k logs -f event-simulator-pod -c nginx
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
```

