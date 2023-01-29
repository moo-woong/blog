---
title: "[Kubernetes Study] k8s objects - Pod"
date: 2023-01-29T17:00:14+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## Pod?

앞선 Study에서 언급된 바와 같이 Kubernetes가 처리하는 가장 작은 단위는 Pod입니다. 이 Pod는 Containerized 애플리케이션을 encapsulation한 단위입니다. 

가장 작은 단위의 Kubernetes의 환경을 구성해보겠습니다.
- A Single cluster 
- A Single node
- A single Pod 
- A single instance in a Pod

{{< figure src="/images/kubernetes/pod-1.svg">}}

사용자가 늘어나 애플리케이션의 처리부하를 줄이기 위해서는 애플리케이션의 instance를 증설해야합니다. 

그렇다면 증설은 어떻게 할까요? Containerized 애플리케이션 instance를 Pod에 추가할까요? 앞서 설명했듯이 Kubernetes의 가장 작은 object 단위는 Pod이므로, Pod가 추가로 증설하여 추가되는 부하용량을 처리해야합니다. 

{{< figure src="/images/kubernetes/pod-2.svg">}}

만약 사용자들이 계속 증가하여 현재 Kubernetes를 구성하고 있는 Single Node의 용량이 부족해지면 새로운 노드를 추가하고, 노드를 Cluster에 Worker node로 증설 한 다음 Pod를 새로운 Worker node에 배치합니다. 

{{< figure src="/images/kubernetes/pod-3.svg">}}

Pod와 Container는 1:1관계가 아닙니다. Pod하나에 여러개의 Container가 instance화 되어 동작할 수 있습니다. 하나의 Pod에서 동작하는 여러개의 Container들은 하나의 Network로 연결되어 서로간에 자유로운 통신이 가능해집니다(localhost). 

{{< figure src="/images/kubernetes/pod-4.svg">}}

연관된 여러개의 Container들을 하나의 Pod로 관리한다면, 증설/감설 시 관련된 Container들을 Pod단위로 증설 및 감설할 수 있어 관리가 용이해집니다. 

## kubectl - pod

`kubectl run`명령어를 통해 아주 간단하게 Pod를 생성할 수 있습니다.

```
hugh@master:~$ kubectl run nginx --image=nginx
pod/nginx created
hugh@master:~$
```

`--image=nginx`옵션은 container 이미지를 나타내는 옵션으로, 현재 registry에 nginx container 이미지가 없다면 docker hub로 부터 다운로드 받아옵니다. 

`kubectl get po`명령어를 통해 현재 cluster의 namespace에 있는 Pod들의 리스트를 확인할 수 있습니다.
```
hugh@master:~$ kubectl get po
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          6m5s
hugh@master:~$ 
```

## Pod yaml

Pod의 생성은 `kubectl run`뿐만 아니라 `yaml`파일 형태로 구체적인 Pod의 생성조건을 제공하고, 해당 Pod를 생성할 수 있습니다.

### Pod yaml의 구성
다음은 Pod yaml을 구성하는 필드를 보여줍니다.
```
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    type: front-end
spec:
  containers:
    - name : nginx-container
      image: nginx
```

`apiVersion`은 사용하려는 Kubernetes object가 속한 apiVersion을 선택합니다. Pod는 v1에 속해있어, v1으로 명시합니다. 추후에 공부하게 될 Deployment, Service 등 각 object마다 속해있는 apiVersion이 다릅니다.

`kind` Kind는 object를 명시합니다. 현재는 Pod를 생성할 예정이므로 `Pod`로 작성합니다. `kind`는 대소문자를 구분합니다.

`metadata`는 현재 object의 관련된 정보들을 명세합니다. `name`, `labels`등을 작성할 수 있으며, `metadata`의 내용들은 yaml의 필수 구성요소가 아닙니다. `metadata`는 다음과 같은 특징이 있습니다.
- `metadata`를 구성하는 필드들은 dictionary type으로 key와 value로 구성됩니다. (단일 value안됨)
- `metadata`의 하위 필드들의 depth는 동일해야 합니다. 다음과 같이 `label`이 다른 필드와 다른 depth를 가질 수 없습니다.
```
metadata:
  name: myapp-pod
    labels:
      app: myapp
```

`spec`은 Pod에 사용될 Container 정보들을 명세하는 필드입니다. `metadata`와 마찬가지로 dictionary 형태의 key-value 필드들을 갖습니다. 
- `containers`는 Container의 이름, 사용할 이미지 등을 명세합니다.
- `containers`는 list 타입으로, Pod가 복수개의 container를 사용할 수 있어, 여러 container들을 명세할 수 있습니다.
- `containers.name`의 앞에 있는 `-`는 list의 element를 나타냅니다. 복수개의 container를 사용한다면 `-name`이 container 수 마다 필요합니다.

이렇게 작성한 `yaml`은 `kubectl create`나 `kubectl apply` 명령어를 통해서 cluster에 배치할 수 있습니다.

```
hugh@master:~/yaml$ kubectl create -f pod-definition.yaml
pod/myapp-pod created
hugh@master:~/yaml$ kubectl get po
NAME        READY   STATUS              RESTARTS   AGE
myapp-pod   0/1     ContainerCreating   0          4s
nginx       1/1     Running             0          22m
hugh@master:~/yaml$ kubectl get po
NAME        READY   STATUS    RESTARTS   AGE
myapp-pod   1/1     Running   0          11s
nginx       1/1     Running   0          22m
```

`kubectl get po`명령어를 통해 현재 namespace에 설치된 pod목록을 확인했을 때, 우리가 `yaml`로 명세한 `myapp-pod`가 실행중인것을 확인할 수 있습니다. 

`kubectl describe po <pod_name>`을 통해서 Pod의 관련 정보들을 확인할 수 있습니다. 정보들로는 현재 Pod의 상태, Event, Container 정보등이 있습니다.

```
hugh@master:~/yaml$ kubectl describe po myapp-pod
Name:             myapp-pod
Namespace:        default
Priority:         0
Service Account:  default
Node:             worker1/192.168.83.135
Start Time:       Sun, 29 Jan 2023 01:52:41 -0800
Labels:           app=myapp
                  type=front-end
Annotations:      cni.projectcalico.org/containerID: 8caca641e4e18fb7b5deff5b63b7b3be840ce7a027a90cecb1e841db8c2e4271
                  cni.projectcalico.org/podIP: 192.168.235.130/32
                  cni.projectcalico.org/podIPs: 192.168.235.130/32
Status:           Running
IP:               192.168.235.130
IPs:
  IP:  192.168.235.130
Containers:
  nginx-container:
    Container ID:   containerd://98324a60bb21b72acfdd1f5d2e3e03b9013d35dc45bd88bdac1d8ab0b2118e8e
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:b8f2383a95879e1ae064940d9a200f67a6c79e710ed82ac42263397367e7cc4e
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sun, 29 Jan 2023 01:52:43 -0800
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jqx7x (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-jqx7x:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m59s  default-scheduler  Successfully assigned default/myapp-pod to worker1
  Normal  Pulling    2m59s  kubelet            Pulling image "nginx"
  Normal  Pulled     2m57s  kubelet            Successfully pulled image "nginx" in 2.101256362s (2.101262396s including waiting)
  Normal  Created    2m57s  kubelet            Created container nginx-container
  Normal  Started    2m57s  kubelet            Started container nginx-container
hugh@master:~/yaml$
```