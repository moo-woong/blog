---
title: "[Kubernetes Study] DaemonSets"
date: 2024-01-30T18:29:02+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

# DaemonSet

`DaemonSet`는 Deployment와 유사한 object로 여러 여러 pod들의 집합이다. 하지만 가장 큰 차이는 Pod instance는 노드 별 하나만 설치된다는 점이다. 이는 새로운 노드가 클러스터에 추가되는 것도 포함하며, 신규 노드가 join 시 Daemon Sets는 해당 Pod를 노드에 추가한다.

위와 같은 특징으로 Daemon Sets는 각 노드별로 배치되어야 하는 기능에 사용 가능하다. 예를 들면 노드 별 네트워크 I/O를 모니터링 하는 agent들을 배치할 수 있다. 이처럼 노드 별 agent가 필요로 하는 서비스를 배치한다면 centralized service에서는 노드의 추가, 삭제등의 동작을 DaemonSet에 일임할 수 있다.

### 사용법
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-daemon
spec:
  selector:
    machLabels:
      app: monitoring-agent
    template:
      metadata:
        labels:
          app: monitoring-agent
        spec:
          containers:
          - name: monitoring-agent
            image: monitoring-agent
```
DaemonSet object배치 방법은 ReplicaSet과 완전히 동일하다.(kind만 다르다)
