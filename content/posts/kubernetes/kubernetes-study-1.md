---
title: "[Kubernetes Study] Cluster Architecture"
date: 2023-01-15T20:26:32+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

Kubernetes Study posts들은 Udemy의 Kubernetes 스테디셀러인 Mumshad의 [Certified Kubernetes Administrator (CKA) with Practice Tests](https://www.udemy.com/course/certified-kubernetes-administrator-with-practice-tests/) 강의를 스터디하며 강의 내용을 체득하기 위해 간략하게 정리하는 포스트입니다. 따라서 관련 내용들은 Udemy 강의 내용이며, 아직 다 학습하지는 못했지만.. 강의 내용이 아주 이해하기 쉽게 잘 설명된것 같으니 할인할 때 구매하시면 좋을것 같습니다. 저는 약 19,000에 구매했던것 같습니다.

# Kubernetes 구성요소들

Kubernetes는 contaierized 된 application들의 실행, 관리하는 플랫폼입니다. Google에서 처음 개발되었으며  오픈소스 기반으로 현재는 Linux foundation 재단에서 관리합니다. AWS, Azure, GCP 등 Public Cloud 업체들은 Kubernetes 환경을 제공하고 있고 규모가 있는 업체들의 경우 On-premise로 Kubernetes를 구축하여 Service를 제공하고 있습니다.

## Worker Nodes
`Containers`는 Worker Node에서 실행됩니다. `Worker nodes`의 리소스 용량에 따라 얼마나 많은 용량의 `Containers`들을 실행할 수 있는지 결정됩니다.
> 실제로는 Kubernetes에서는 `Container` 단위로 동작하지 않습니다. `Pod`가 Kubernetes의 가장 작은 실행단위이며, `Pod`는 1개 이상의 Container로 구성됩니다.

## Master Node
항구에는 수 많은 컨테이너 선들이 있고 항구 앞 바다에는 많은 컨테이너선들이 있습니다. 각각 컨테이너들의 정보들은 알맞은 컨테이너선에 실려야하며 언제, 어떻게 싣고 현재 상태는 어떠한지, 전체적인 정보들을 관리하는 컨트롤 타워가 필요합니다. `Master Node`는 컨트롤타워로 비유할 수 있습니다. 이제 Kubernetes는 `Master Node`를 통해서 `Container`들을 올바르게 `Worker Node`에 설치하고 모니터링 할 수 있습니다. `Master Node`의 역할은 다음과 같습니다.

- Kubernetes Cluster 관리 / 항구 전체의 관리
- 각 노드의 상태정보 저장 / 모든 화물선들의 상태정보 관리
- 각 노드의 상태 모니터링 / 모든 화물선들의 현새상태 감시
- Pods와 Worker node의 mapping 정보 관리 / 모든 화물선과 실린, 실려야하는 화물들의 관리

위와 같은 작업을 수행하기 위해서는 `Master Node`는 여러개의 Control Plane Components와 유기적으로 통신합니다. Kubernetes Cluster를 구성하는 Control Plane Components를 간략히 알아보겠습니다.

### etcd
항구의 컨트롤타워는 정보들을 저장하고 읽어들일 수 있어야합니다. 항구에는 수 많은 화물과 화물선들이 있으며, 선적과 하역 작업스케쥴 등 다양한 정보들이 저장되고 언제든지 정보들을 확인할 수 있어야합니다. Kubernetes에는 이러한 정보저장공간을 `etcd(엣시디)`라고 하며, key-value로 정보들을 저장하고 관리합니다. 

### kube-scheduler
항구에는 화물을 알맞은 화물선으로 싣기 위해 컨테이너를 옮기는 크레인이 있습니다. 이 크레인 운전자는 해당하는 화물이 어떤 화물이고, 이 화물이 어디에 실려야하는지 알고 있습니다. 이러한 크레인은 Kubernetes에는 `kube-scheduler`에 대응됩니다. `kube-scheduler`는 Pods의 requests/limits resource, nodeAffinity, tolerations 등을 기준으로 하여 현재 Worker nodes 중 capacity가 알맞은 Worker node에 Pods를 배치합니다. 

### Controller
관리팀은 항구에 있는 화물들을 전반적으로 관리합니다. 화물차들의 화물 배송 스케쥴, 화물의 파손확인, 가용 화물 확인 등 화물들의 전반적인 상태를 점검하고 모니터링은 화물팀이 관리합니다. Kubernetes에서는 `Controller`는 항구의 관리팀으로 비유할 수 있습니다. Kubernetes에는 관리하는 리소스마다 다양한 Controller가 존재합니다. 다음은 Controller 중 일부 Controller를 간략하게 설명합니다.

#### Repliaction-Controller
`Replication-COntroller`는 `Desired the number of Pods`를 보증합니다. Kubernetes의 핵심 중 하나가 `Desired State`의 제공입니다. 운영자는 몇개의 Pods가 운용되고, 어떤 포트로, 어떤 이름의 서비스를 제공할지 `Desired State`를 명시할 수 있습니다. `Replication-Controller`는 운영자가 명시한 Pods의 실행 개수가 항상 만족하도록 Pods상태 및 생성을 관리합니다.

#### Node-Controller
Kubernetes에 Join하는 다양한 노드들을 관리합니다. 새롭게 추가된 Node들을 관리하고 Node에 문제가 발생할 경우 `Node-Controller`가 관리합니다. 

### kube-apiserver
`kube-apiserver`는 Kubernetes를 구성하는 다양한 Control Plane Components들간의 통신을 담당합니다. `kube-apiserver`는 kubernetes를 orchestration할 수 있도록 제공하는 component 입니다. 시스템 운용자는 `kube-apiserver`이 제공하는 Kubernetes API를 이용하여 cluster를 관리하고 모니터링할 수 있습니다.

### Container Runtime Engine
Kubernetes는 `Containerized` 된 application들은 관리합니다. 즉, 모든 application들의 기본 단위는 container입니다(물론 앞서 설명한 바와 같이 Pod로 설치되지 Container가 직접 설치되고 운용되지는 않습니다). Containerized는 Docker, Podman, ContainerD 등 다양한 가상 Container Runtime Engine을 사용할 수 있습니다.

### Kubelet
Kubelet은 모든 Worker Node에 설치되는 컴포넌트로, Master Node의 요청에 따라 Container들을 설치/삭제/모니터링하고 관련된 정보들을 Master Node에 회신합니다. Master Node는 Worker Node에 직접 관려하지 않고 kubelet에 관련된 작업을 일임하고 결과를 통보받습니다. 이렇게 통보받은 정보들은 kube-apiserver를 통해 수신하고, etcd에 저장되며, 관련된 정보들을 알맞은 컴포넌트들에게 알려집니다. 

### kube-proxy
`kube-proxy`는 Kubernetes cluster의 네트워크를 구성하는 컴포넌트입니다. kubernetes cluster를 구성하는 Worker Node들이 서로간의 통신이 가능하도록 관련된 기능을 제공하며, 이를 통해 Cluster 전체에 퍼져있는 서비스들이 통신할 수 있습니다. 