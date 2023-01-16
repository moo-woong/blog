---
title: "[Kubernetes Study] k8s components - ETCD"
date: 2023-01-15T23:03:34+09:00
series: ["Kubernetes Study"]
categories: ["Kubernetes"]
---

{{< figure src="/images/kubernetes/etcd.png">}}

## etcd?
etcd는 key-value 분산 저장소입니다. 오픈소스이며, Kubernetes에서 사용되어 유명해진 데이터베이스입니다. 분산 저장소라는 말에서 알 수 있듯이 ETCD는 Replication State Machine이며, 분산 컴퓨팅 환경에서 High Availability를 제공하고 높은 신뢰성을 제공합니다. Kubernetes의 다양한 정보들이 ETCD를 통해 저장되므로 고가용성이 중요합니다.

## Key-value store?

전통적으로 데이터베이스는 행과 열로 이루어진 Tabular Format 구성됩니다. 관계형 데이터베이스 SQL이 대표적입니다. key-value store는 NoSQL 데이터베이스의 한 종류이며, 

## Key-value store 구조
{{< figure src="/images/kubernetes/etcd-table.PNG">}}

위의 테이블은 Tabular Format의 예입니다. 행(Row)는 각 사람들의 정보를 나타내고 열(Column)은 각 타입의 값을 나타냅니다. 

테이블을 보면 John Doe, Dave Smith는 성인으로 Salary라는 Column을 갖고있으며, 나머지 10대 3명은 Salary는 없지만 Grade라는 Type의 값을 가지고 있습니다. 이렇게 Tabular Format 테이터베이스는 Type이 추가될 때 마다의 Type에 해당하지 않는 행도 영향을 받습니다.

{{< figure src="/images/kubernetes/etcd-table2.PNG">}}

Key-value store는 `Document` 또는 `Page`라는 타입으로 정보를 저장합니다. 그리고 `Document`는 `File`이라는 형태로 저장됩니다. 위 그림에서는 5개의 `File`의 예시를 보여줍니다.

`File`의 포멧과 구조는 어떠한 형태를 취하던지 상관이 없으며, Tabular Format과 비교되듯이 각 `File`들의 추가,삭제등의 작업은 다른 `File`에 영향을 미치지 않습니다.

## etcd의 역할
Kubernetes cluster에는 다양한 정보들이 존재합니다. Node, Pods, Convicts, Secrets, Accounts, Roles 등등 많은 Object, 정보들이 존재하고 이러한 정보들은 etcd를 통해서 저장되고 관리됩니다. 여러분이 `kubectl` CLI를 통해서 확인할 수 있는 정보들은 etcd에서 가져옵니다. 


etcd의 데이터의 저장과 쿼리가 빈번하게 발생합니다. 새로운 worker node를 추가하거나, pod를 생성하거나 삭제할때등을 수행하면 etcd에 저장되고 저장된 정보들은 관련 Control plane components로 최신 정보가 전달됩니다.