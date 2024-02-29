---
title: "[Kubernetes Study] Rolling Update and Rollbacks"
date: 2024-02-29T12:05:58Z
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## Rollout

사용자는 Application의 revision 업데이트를 rollout을 통해 수행할 수 있다. Deployment로 배치된 Application의 rollout예시는 다음과 같다. 

<details>
  <summary>Deployment sample</summary>

  ```yaml
  apiVersion: apps/v1
  kind: Deployment
  metadata: 
    name: myapp-deployment
    labels:
      app: myapp
      type: front-end
  spec:
    template:
      metadata:
        name: myapp-pod
        labels:
          app: myapp
          type: front-end
      spec:
        containers:
        - name: nginx-container
          image: nginx
  replicas: 3
    selector:
      matchLabels:
        type: front-end
  ```
</details>


### Rollout Strategy

새로운 Revision 배포방법들은 다양하다

#### Recrease
현재 버전의 Pod instance를 모두 삭제하고 새로운 Revision application으로 구성한다.
이 경우 이전 버전의 Pod instance들이 모두 삭제되고 새로운 Revision application이 배치될 때 까지 서비스 장애가 발생한다.

#### Rolling Update
구 버전 Pod를 하나 삭제하고 Revision Pod를 새롭게 생성한다. 이 과정을 Pod의 개수만큼 수행하면 Pod가 없어 서비스를 제공하지 못하는 장애는 발생하지 않는다. Rollout의 default strategy 이기도 하다.

### Rolling update 방법(kubectl apply)
Deployment의 container revision을 한다면 해당 deployment의 container 버전 tag를 명시해서 업데이트 할 수 있다.

#### 기존
```yaml
...
...
  spec:
    template:
      metadata:
        name: myapp-pod
        labels:
          app: myapp
          type: front-end
      spec:
        containers:
        - name: nginx-container
          image: nginx
...
```

#### Revision
```yaml
...
...
  spec:
    template:
      metadata:
        name: myapp-pod
        labels:
          app: myapp
          type: front-end
      spec:
        containers:
        - name: nginx-container
          image: nginx:1.7. # <-- 변경
...
```

변경된 Deployment를 kubectl apply 명령어로 업데이트 한다.
```sh
hugh@master:~/yaml/rolling-update $ k apply -f deploy-revision.yaml 
deployment.apps/myapp-deployment configured
hugh@master:~/yaml/rolling-update $ 
hugh@master:~/yaml/rolling-update $ k get po
NAME                                READY   STATUS              RESTARTS   AGE
myapp-deployment-56b4f77799-2nvgz   0/1     ContainerCreating   0          6s     # <-- Rolling update
myapp-deployment-84ccc5558-mj7pf    1/1     Running             0          5m19s
myapp-deployment-84ccc5558-nrqbf    1/1     Running             0          5m19s
myapp-deployment-84ccc5558-r2smc    1/1     Running             0          5m19s
hugh@master:~/yaml/rolling-update $ 
```
Pod의 container 이미지를 확인해 보면 tag가 변경되었음을 확인할 수 있다.

```sh
hugh@master:~/yaml/rolling-update $ k describe po myapp-deployment-56b4f77799-2nvgz | grep "Image:"
    Image:          nginx:1.7.1
hugh@master:~/yaml/rolling-update $ k describe po myapp-deployment-84ccc5558-mj7pf | grep "Image:"
    Image:          nginx
hugh@master:~/yaml/rolling-update $ 
```

### Rolling update 방법(kubectl set)
kubectl apply 외에도 `set`명령어를 이용해 업데이트할 수 있다.

```sh
hugh@master:~/yaml/rolling-update $ k set image deploy/myapp-deployment \
> nginx-container=nginx:1.9.1
deployment.apps/myapp-deployment image updated
hugh@master:~/yaml/rolling-update $ k get po
NAME                                READY   STATUS              RESTARTS   AGE
myapp-deployment-67b5d598df-24tr8   0/1     ContainerCreating   0          15s
myapp-deployment-84ccc5558-l94xj    1/1     Running             0          56s
myapp-deployment-84ccc5558-lld5m    1/1     Running             0          52s
myapp-deployment-84ccc5558-nrqbf    1/1     Running             0          9m53s
hugh@master:~/yaml/rolling-update $ k describe po myapp-deployment-67b5d598df-24tr8
Name:             myapp-deployment-67b5d598df-24tr8
Namespace:        default
...
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  22s   default-scheduler  Successfully assigned default/myapp-deployment-67b5d598df-24tr8 to worker2
  Normal  Pulling    21s   kubelet            Pulling image "nginx:1.9.1"
```

### Rolling update 로그
Rolling update로 revision 한다면 다음처럼 Deployment의 로그들을 확인할 수 있다. 

```sh
hugh@master:~/yaml/rolling-update $ k describe deploy myapp-deployment
Name:                   myapp-deployment
...
...
Events:
  Type    Reason             Age                  From                   Message
  ----    ------             ----                 ----                   -------
  Normal  ScalingReplicaSet  2m36s  deployment-controller  Scaled up replica set myapp-deployment-84ccc5558 to 3
  Normal  ScalingReplicaSet  2m21s  deployment-controller  Scaled up replica set myapp-deployment-59f8f48cc to 1
  Normal  ScalingReplicaSet  2m3s   deployment-controller  Scaled down replica set myapp-deployment-84ccc5558 to 2 from 3
  Normal  ScalingReplicaSet  2m3s   deployment-controller  Scaled up replica set myapp-deployment-59f8f48cc to 2 from 1
  Normal  ScalingReplicaSet  105s   deployment-controller  Scaled down replica set myapp-deployment-84ccc5558 to 1 from 2
  Normal  ScalingReplicaSet  105s   deployment-controller  Scaled up replica set myapp-deployment-59f8f48cc to 3 from 2
  Normal  ScalingReplicaSet  85s    deployment-controller  Scaled down replica set myapp-deployment-84ccc5558 to 0 from 1
```
위 로그들을 보면 Rolling update로 scale up/down을 반복하며 Pod들의 개수를 유지해 서비스 장애를 발생시키지 않고 업데이트함을 확인할 수 있다.

### Upgrade

Deployment의 rolling upgrade 전략은 하나의 Replica-set을 업그레이드 할 때 새로운 Replica-set을 만들어 개수를 조절해 가며 Revision한다.

{{< figure src="/images/kubernetes/rolling-update-upgrage.png">}}

```sh
hugh@master:~/yaml/rolling-update $ k get rs
NAME                         DESIRED   CURRENT   READY   AGE
myapp-deployment-59f8f48cc   3         3         3       5m52s # 이전 Replicaset
myapp-deployment-84ccc5558   0         0         0       6m7s  # 신규 ReplicaSet
```

## Rollback
만약 새로운 Application을 배포했는데 치명적인 문제가 있다고 가정해보자. 생각하기는 싫지만 이 경우 문제분석과 해결, 새롭게 배포하기 전 까지 서비스를 유지해야하므로 이전 버전의 Application을 사용해야 할 것이다.
k8s는 이러한 상황에서 사용할 수 있는 rollback을 제공한다.

```sh
hugh@master:~/yaml/rolling-update $ k rollout undo deploy/myapp-deployment
deployment.apps/myapp-deployment rolled back
hugh@master:~/yaml/rolling-update $
```

이렇게 rollback을 하게되면 새로운 Replica-set을 생성하는 것이 아니라 이전의 Replica-set을 재사용 한다.

```sh
hugh@master:~/yaml/rolling-update $ k get rs
NAME                         DESIRED   CURRENT   READY   AGE
myapp-deployment-59f8f48cc   0         0         0       9m11s # 이전 Replicaset
myapp-deployment-84ccc5558   3         3         3       9m26s # 신규 ReplicaSet
```