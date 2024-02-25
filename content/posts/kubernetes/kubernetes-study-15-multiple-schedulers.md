---
title: "[Kubernetes Study] Multiple Schedulers"
date: 2024-02-25T09:25:09Z
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## Scheduler
Kubernetes cluster의 default scheduler는 nodes들 전반에 걸쳐서 어떻게 Pod를 배치할지 결정하는 역할을 한다.
각 node들의 상태와 affinity, tolerations, taints, selector등의 조건들을 기준으로 Pod의 배치를 결정한다.

하지만 kubernetes가 제공하는 조건들 외에 추가적인 조건을 확인해야 한다면? 사용자가 원하는 스케쥴러를 사용할 수 있다.

## Multiple scheduler
사용자는 기본 스케쥴러 대신에 새로운 스케쥴러를 만들어 기본 스케쥴러를 대체하거나 사용자가 만든 스케쥴러를 추가로 배치할 수 있다.

사용자는 Pod가 배치될 때 스케쥴러를 지정할 수 있다.

- kubernetes의 기본 스케쥴러는 `kube-scheduler`이며, 사용자가 생성한 스케쥴러는 이름이 고유해야한다.

### default-scheduler 대체

kube-scheduler를 배치할 때 defaut-scheduler의 바이너리를 이용할 수 있다. 다음은 기본 바이너리를 이용해서 추가적인 작업을 하도록 스케쥴러를 배포하는 예시다.

```
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/my-scheduler-2-config.yaml
```

> my-scheduler-2-config.yaml
 ```yaml
 apiVersion: kubescheduler.config.k8s.io/v1
 kind: KubeSchedulerConfiguration
 profiles:
 - schedulerName: my-scheduler-2
 leaderElection:
   leaderElect: true
   resourceNmaspace: kube-system
   resourceNmae: lock-object-my-shed
 ```

 - leaderElection: muilti master 상황에서 HA 제공을 위해 leader를 선출하는 옵션. 동시에 여러 kube-scheduler가 실행되지만 하나의 kube-scheduler만이 leader가 되어 명령을 처리한다.


### 커스텀 scheduler 배포
커스텀 scheduler 배포 테스트를 위해 다음과 같이 yaml파일을 생성한다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-custo-schjeduler
  naespace: kube-system
spec:
  containers:
  - command:
    - kube-scheduler
    - --address=127.0.0.1
    - --kubeconfig=/etc/kubernetes/scheduler.conf #1
    - --config=/etc/kubernetes/my-scheduler-config.yaml #2
    image: k8s.gcr.io/kube-scheduler-amd64:v1.11.3
    name: kube-scheduler
```

- 1은 kubernetes scheduer의 default config파일로 인증정보가 명시되있다.
- 2는 사용자가 정의한(앞서 우리가 정의한) scheduler를 명기한다.

config에 명시한 config 파일을 전달하려며면 다양한 방법이 있지만 여기서는 kubernetes document에서 설명하는 Deployment 예시를 보도록 하자.

```yaml
spec:
  selector:
    matchLabels:
      component: scheduler
      tier: control-plane
  replicas: 1
  template:
    metadata:
      labels:
        component: scheduler
        tier: control-plane
        version: second
    spec:
      serviceAccountName: my-scheduler
      containers:
      - command:
        - /usr/local/bin/kube-scheduler
        - --config=/etc/kubernetes/my-scheduler/my-scheduler-config.yaml #3
        image: gcr.io/my-gcp-project/my-kube-scheduler:1.0
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10259
            scheme: HTTPS
          initialDelaySeconds: 15
        name: kube-second-scheduler
        readinessProbe:
          httpGet:
            path: /healthz
            port: 10259
            scheme: HTTPS
        resources:
          requests:
            cpu: '0.1'
        securityContext:
          privileged: false
        volumeMounts:
          - name: config-volume #2
            mountPath: /etc/kubernetes/my-scheduler
      hostNetwork: false
      hostPID: false
      volumes:
        - name: config-volume #1
          configMap:
            name: my-scheduler-config
```

다음의 과정을 따라 한다.
1. ConfigMap에 선언 
2. ConfigMap을 Volume으로 mount 
3. config 명기 

위 과정을 진행하면 Pod는 ConfigMap 타입으로 선언된 값을 Pod내에서 매핑할 수 있다.

### 커스텀 scheduler 사용
사용자가 임의로 추가한 scheduler가 다음 처럼 배치되어 있다고 가정해 보자.

```yaml
hugh@master:~/yaml $ kubectl get po -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-7ddc4f45bc-9pnx2   1/1     Running   0          14d
calico-node-47qww                          1/1     Running   0          13d
calico-node-7jhns                          1/1     Running   0          14d
calico-node-bcc6k                          1/1     Running   0          13d
calico-node-ktb4h                          1/1     Running   0          13d
coredns-5dd5756b68-2v7jg                   1/1     Running   0          14d
coredns-5dd5756b68-5mzgx                   1/1     Running   0          14d
etcd-master                                1/1     Running   5          14d
kube-apiserver-master                      1/1     Running   7          14d
kube-controller-manager-master             1/1     Running   0          14d
kube-proxy-4frxk                           1/1     Running   0          13d
kube-proxy-bsxdb                           1/1     Running   0          13d
kube-proxy-pc8ld                           1/1     Running   0          13d
kube-proxy-scnbt                           1/1     Running   0          14d
kube-scheduler-master                      1/1     Running   9          14d
my-scheduler                               1/1     Running   0          10m
```

그리고 사용자가 Pod하나를 배치할 때, 사용자가 추가한 스케쥴러를 사용하고 싶다면 `schedulerName`에 해당 scheduler를 명기하면 된다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - image: nginx
    name: nginx
  schedulerName: my-scheduler # <--
```

`my-scheduler`를 사용해 배치된 Pod는 k8s events를 통해 확인할 수 있다.

```sh
hugh@master:~/yaml $ kubectl get event -o wide
LAST SEEN   TYPE     REASON      OBJECT                       SUBOBJECT                SOURCE                                    MESSAGE                                                                    FIRST SEEN   COUNT   NAME
63s         Normal   Scheduled   pod/nginx                                             my-scheduler, my-scheduler-my-scheduler   Successfully assigned default/nginx to worker2                             63s          1       nginx.17b71994464b2560
```
