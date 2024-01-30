---
title: "[Kubernetes Study] Taints Tolerations"
date: 2024-01-30T00:00:26+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

# Taints and Tolerations

# 개념

본 포스트에서 사용되는 예시들은 Security나 Intrusion 설정이 되지 않은 것으로 간주한다.

Taint와 Tolerations는 Label과 Selector와 유사하다. Label과 Selector는 필터링과 필터링을 이용한 객체들간의 매핑과 관련되었다면, Taint와 Tolerations는 Pod가 노드에 배치 될 때 제약사항을 만드는 것이다.

## 예시

관리자가 Pod 배치를 요청하면, 쿠버네티스 스케쥴러는 노드 중 가용 가능한 노드에 Pod를 배치하려 할 것이다. 만약 제약사항이 없다면 스케쥴러는 균등하게 Pod들을 노드에 배치할 것이다.

클러스터에 노드가 3개 있으며, 그 중 A라는 노드는 특정 목적을 위해 사용되는 노드라고 가정해보자. 배치되는 Pod가 특정 목적용 Pod가 아니라면, A노드를 `Taint(오염)` 시켜, Pod가 배치되는 것을 막을 수 있다.

특수목적 용 Pod에는 `Tolerations`를 적용하여 `Taint`된 노드에 배치될 수 있도록 만들면 해당 Pod를 A노드에 배치될 수 있다.

## 사용법
### Taint
kubectl taint를 이용해 직접 노드에 taint를 적용할 수 있다. 적용하는 taint는 `key=value` 쌍이다.  
```shell
kubectl taint nodes node-name key=value:taint-effect
```
`key=value` 쌍 다음에는`taint-effect`를 입력한다. taint-effect는 tolerations가 맞지 않은 Pod에 대해 노드가 어떤 일을 수행하지 설정하는 것이다. taint-effect는 다음 세 가지 행동이 있다.
- `NoSchedule`: 스케쥴러는 taint 노드에 Pod 배치를 시도하지만, 배치되지는 않는다.
- `PreferNoSchedule`: 스케쥴러는 taint 노드에 스케쥴링 되는 것을 시도하지만, 배치되는 것을 보증하지 않는다.
- `NoExecute`: 스케쥴러는 해당 노드에 스케쥴링 하지 않으며, 기존에 배치된 Pod들에 대해서도 tolerations가 없다면, 해당 Pod는 축출된다(killed).

**Example**
node1 노드에 blue라는 taint를 설정하며, tolarations가 blue가 아니면 스케쥴되지 않도록 
```
kubectl taint nodes node1 app=blue:NoSchedule
```

### Tolerations
Tolerations는 Pod에 적용한다.  다음의 tolerations 설정 예시다.
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec:
  containers:
  - name: nginx-container
    image: nginx
    tolerations:
  - key: "app"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
```

타 예시에 비해 설정이 좀 많다. 또한 tolerations의 모든 value 값은 쌍따옴표로 선언해야 한다.
- `key`, `value`: node에 taints에 적용한 것과 동일하다.
- `operator`: key, value와의 관계를 설정한다. `Equal`은 key, value가 매치 되어야 함을 의미한다.
- `effect` : taint의 taint-effect와 동일하다. 

Taint와 Tolerations는 `제한`하는 것이 목적이다. 즉 Tolerations가 설정된 Pod가 Taint설정된 노드에 배치되는 것을 보증하지는 않는다. 해당 Pod는 다른 노드에 배치될 수 있음을 명심해야 한다.  만약 특정 Pod가 특정 노드에 배치되긴 원한다면 `Affinity`설정을 해야 한다.

Taint와 Tolerations는쿠버네티스를 운용하면서 자동적으로 적용된 노드가 있다. 바로 마스터 노드로, 설정을 하지 않는 한, 마스터 노드에는 Pod가 배치되지 않는 걸 볼 수 있다. 이는 마스터 노드에 Taint가 설정되어 있기 때문이다. 
```shell
kubectl describe node kubemaster | grep Taint
Taints:  node-role.kubernetes.io/master:NoSchedule
```