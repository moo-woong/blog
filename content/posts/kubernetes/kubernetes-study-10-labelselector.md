---
title: "[Kubernetes Study] Labelselector"
date: 2024-01-29T23:42:35+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

## Label selector

kubectl의 `--seletor` 옵션을 이용해서 필터링을 직접 가능하다

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp
  labels:
    app: App1
    function: Front-end
...
...
spec:
  containers:
  - name: simple-webapp
    image: siple-webapp
    ports:
      - containerPort: 8080
```

```shell
kubectl get pods --selector app=App1
```

Label은 `ReplicaSet`, `Pod`, `Service` 등 다른 객체들 간의 연결에도 사용할 수 있다.
다음의 `ReplicaSet`의 예제다.

```yaml
apiVersion: v1
kind: ReplicaSet
metadata:
  name: simple-webapp
  labels:
    app: App1
    function: Front-end
spec:
  replicas: 3
  selector:
    matchLabels:
      app: App1
  template:
    metadata:
      labels:
        app: App1
        function: Front-end
    spec:
      containers:
      - name: simple-webapp
        image: simple-webapp
```

`metadata.labels`는 ReplicaSet에 할당되는 Label이다. `spec.selector.matchLabels`는 ReplicaSet과 매치되는 Pod를 지정한다. 위 yaml파일이 실행되면, ReplicaSet과 Pod가 연결된다.

ReplicaSet과 Pod를 연결한 것과 같이 Service와 Pod를 연결할 수도 있다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app: App1
  ports:
  - protocol: TCP
    port: 80
    targetPort 9376
```
위처럼 `spec.selector`를 이용해 Service와 연결된 Pod를 특정할 수 있다.

# Annotations
`annotation`은 객체에 추가적인 정보를 입력할 때 사용된다. 빌드버전 등 프로그램의 정보를 적을 수도 있으며, email이나 연락처 등 관리자가 원하는 정보 아무거나 추가할 수 있다.

```yaml
apiVersion: v1
kind: ReplicaSet
metadata:
  name: simple-webapp
  labels:
    app: App1
    function: Front-end
  annotations:
    buildversoin: 1.34
spec:
  replicas: 3
  selector:
    matchLabels:
      app: App1
  template:
    metadata:
      labels:
        app: App1
        function: Front-end
    spec:
      containers:
      - name: simple-webapp
        image: simple-webapp
```