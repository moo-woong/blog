---
title: "[Kubernetes Study] Resource requirements and limits"
date: 2024-01-30T18:15:02+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

# Resource requirements and limits

각 노드는 CPU와 Memory 리소스를 갖고 있다. 스케쥴러에 이해 Pod가 배치될 때, Pod의 리소스 요청 사항과 노드의 리소스 사용량은 스케쥴링에 직접적인 영향을 미친다.

## Requests
### 사용법
다음과 같이 `spec.containers.resources.requests` 를 이용해 Pod에 리소스 정보를 명세할 수 있다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-color
  labels:
    name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
    ports:
      - containerPort: 8080
    resources:
      requests:
        memory: "4Gi"
        cpu: 2
```

### 단위
#### CPU
CPU의 단위는 정수, 소수점, `m` 을 이용해서 설정할 수 있다. `m`은 milli의 뜻으로 1/1000이라서 cpu 0.1은 100m과 동일하며, 1은 1000m과 동일하다. 

CPU의 최소 단위는 `1m`이며 그 이하는 될 수 없다.
1CPU는 1vCPU와 동일하다. CPU의 상세 클럭은 vCPU에 정의된 코어를 따른다.

#### 메모리
메모리는 `Ki`, `Mi`, `Gi`, `K`, `M`, `G`  단위로 명세할 수 있다. 
>`ni` i가 붙는 단위는 ~비바이트로 읽는다. 키비바이트, 메비바이트, 기비바이트.

CPU와는 다르게 정수는 바이트를 의미한다. 따라서 `256Mi` 와 `268435456`는 동일 메모리를 할당 받는다.  각 단위 명세는 단음과 같다.
{{< figure src="/images/kubernetes/resource.png">}}

위 표와 같이 `1Mi` 와 `1M`은 메가 단위만 동일하고 실제 적용되는 바이트 수는 다르다.

## Limits
기본적으로 container는 리소스 사용량에 제한이 없다. 따라서 Limit을 설정하지 않은 container는 노드의 리소스 전체를 가용할 수 있다.

### 사용법
`spec.containers.resources.limits` 로 Limit을 설정할 수 있다.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-color
  labels:
    name: simple-webapp-color
spec:
  containers:
  - name: simple-webapp-color
    image: simple-webapp-color
    ports:
      - containerPort: 8080
    resources:
      requests:
        memory: "1Gi"
        cpu: 1
      limits:
        memory: "2Gi"
        cpu: 2
```

CPU의 Limit은 스로틀링이 걸리며 Limit 이상으로 CPU사용이 제한된다. 메모리의 경우 Limits 이상의 메모리를 사용하게 되면 OOM(Out of Memory)로 Pod가 Terminated 된다.

앞서 설명한대로 limits와 requests는 설정하지 않으면 노드의 자원을 모두 가용 할 수 있다. 

{{< figure src="/images/kubernetes/kubernetes/resource-threshold.png">}}

위 그림처럼 두 조건에 대해서는 4가지 조합이 있을 수 있다. 가장 최악의 설정은 아무것도 설정 하지 않는 설정으로, 두 Pod가 하나의 노드에 배치되어 있을 때 한 노드가 모든 리소스를 사용하여 나머지 하나의 Pod가 최소한의 자원을 할당받지 못해 아무것도 할 수 없다.

가장 이상적인 상황은 4번째 조합으로 Limits 없이 Request만 설정하는 것이다. 특정 상황에서 자동으로 Scale-up이 될 수 있으며 Requests할당으로 최소한의 동작을 보장하기 때문이다.

## Default resource
k8s의 기본설정은 No requests, No limits 이나, 클러스터에 임의로 기본값을 설정할 수 있다. 해당 리소스는 `LimitRange`이며 설정은 namespace 단위로 가능하다. 

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-resource-constraint
spec:
  limits:
  - default:
      cpu: 500m
    defaultRequest:
      cpu: 500m
    max:
      cpu: "1"
    min:
      cpu: 100m
    type: Container
```

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: memory-resource-constraint
spec:
  limits:
  - default:
      memory: 1Gi
    defaultRequest:
      memory: 1Gi
    max:
      memory: 1Gi
    min:
      memory: 500Mi
    type: Container
```
`LimitRange` Object는 설정된 후 신규로 배치되는 Pod에만 영향이 있으며 기존 설치된 Pod들에 대해서는 영향을 주지 않는다. 

## Resource Quotas
리소스 쿼터는 namespace 단위로 모든 pod들이 리소스 사용 총량을 제한하는 방법이다. 
```yaml
apiVersion: v1
kind: ResourceQuotas
metada:
  name: my-resource-quotas
spec:
  hard:
    requests.cpu: 4
    requests.memory: 4Gi
    limits.cpu: 10
    limits.memory: 10Gi
```
