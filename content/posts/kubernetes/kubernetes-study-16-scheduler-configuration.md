---
title: "[Kubernetes Study] Scheduler configuration"
date: 2024-02-25T12:17:34Z
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

스케쥴러는 사용자가 정의한 리소스와 설정에 따라 Pod들을 배치한다.
스케쥴러는 Scheduling, Filtering, Scoring 과정을 거치며 Pod들을 배치한다.

1. Scheduling(PrioritySort)
- Pod 생성 요청들을 queue삽입하며, PriorityClass에 기반한 정렬이 이루어짐
2. Filtering(NodeResourceFit)
- Pod가 배치되는 노드들을 filtering한다. Requests/Limits 설정에 따라 부족한 리소스를 갖는 노드들은 filter out된다.
3. Scoring(NodeResourceFit)
- 배치 가능한 노드들에 대해 점수를 매긴다. 일반적으로 현재 요청된 Pod를 배치한 후 남은 리소스가 높을 수록 높은 점수를 받는다.
4. Binding
- 선택된 노드에 Pod를 배치하는 단계.

위 과정에서 스케쥴러에 설정할 수 있는 추가적인 설정기능들에 대해 알아보자.


## PrioritySort
Scheduling 단계에서 사용하는 플러그인으로 우선순위를 기반으로 soring한다.

### PriorityClass

`PriorityClass`는 Pod 배치요청이 여러개가 있을 때 Pod 생성 우선순위를 정한다.
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: true
description: "This priority clas should be used for XYZ service pods only."
```

사전에 PriorityClass가 설정되어 있다면 다음과 같이 Pod를 배치할 때 우선순위를 사용할 수 있다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-color
spec:
  priorityClassName: high-priority # <--
...OMITTED...
```

우선순위는 `value`값에 따라 좌우되며, 값이 높을 수록 우선순위가 높아져 Pod생성 요청이 queue 앞단에 배치된다.

## NodeResourceFit
### NodeName
노드명을 명시해서 스케쥴링에서 필터링 할 수 있도록 한다.

```yaml
...OMITTED...
spec:
  containers:
  - name: nginx
    image: nginx
  nodeNmae: node02 <--
```

### Imagelocality
Scoring단계에서 노드 스코어링 할 때 Pod가 사용하는 이미지가 이미 노드에 있다면(다운로드 시간이 안걸리니) 더 높은 점수를 받을 수 있도록 하는 설정이다. 필수는 아니므로 모든 노드에 Pod가 사용할 이미지가 없다면 다른 조건에 의해 노드가 결정된다.


## Custom plugin
kubernetes는 확장성이 뛰어나므로 기본 플러그인 외에도 custom plugin을 만들어 스케쥴링 단계에서 사용할 수 있다.

{{< figure src="/images/kubernetes/kube-scheduler-config.png">}}

스케쥴러에는 총 4단계의 과정에서 custom plugin을 추가할 수 있는 지점이 있다.
(자세히는 preFilter,postFilter,preScore 등 세부적으로도 추가할 수 있다)

앞서 설명한 [Multiple Schedulers](https://moo-woong.github.io/posts/kubernetes/kubernetes-study-15-multiple-schedulers/) 에서 잠시 언급된 스케쥴러의 `profiles`로 사용자 임의의 custom scheduler를 만들 때 plguin을 설정할 수 있다.

```yaml
apiVersion: kubescheduler.config.k8s.io/v1
 kind: KubeSchedulerConfiguration
 profiles:
 - schedulerName: my-scheduler-2
   plugins:
     score:
      disabled:
        - name: TaintToleation
      enalbed:
        - name: MyCustomPluginA
        - name: MyCustomPluginB
 - schedulerName: my-scheduler-2
 plugins:
     preScore:
      disabled:
        - name: '*'
     score:
       disabled:
        - name: '*'
```