---
title: "Learning eBPF - What Is eBPF, and Why Is it Imports? 2/2"
date: 2024-03-04T11:11:53Z
categories: ["Study"]
tags: ["eBPF"]
---

[Learning eBPF](https://cilium.isovalent.com/hubfs/Learning-eBPF%20-%20Full%20book.pdf) 스터디

## 새로운 기능을 커널에 추가하기

리눅스 커널은 3,000만줄의 거대한 코드의 복합체고 매우 복잡하다. 만약 우리가 커널에 새로운 기능이 필요하다면 커널에 대해 연구하고 새로운 기능을 개발하고, 수 많은 리뷰어로 부터 리뷰를 받아 메인 스트림에 패치를 추가해야 한다.
이 과정은 때때로 지지부진하며 많은 노력과 시간이 필요하다. 또한 이 기간동안 우리의 요구사항이 변경될 수도 있다.

## 커널에 기능 추가 대신 커널 모듈 만들기

커널과 같은 거대한 커뮤니티에 기여하는건 개발자로서 좋은 경험과 이력이지만 지지부진한 시간을 소비하기 싫다면 커널에 패치 만들기 말고 커널 모듈을 만들 수 있다. 커널 모듈은  리눅스 커널은 사용자의 모듈을 로드, 언로드할 수 있도록 기능을 제공한다.
하지만 여전히 커널 모듈개발을 위한 새로운 환경에 대한 연구가 필요하며, 추가적으로 커널 모듈의 문제가 발생할 경우 커널 전체에 영향을 미칠 수 있어 리스크가 따른다. 이에 더하여 취약한 코드로 개발할 경우 악성 사용자로 부터 공격에 대한 창구가 될 수 있으므로 취약하지 않으며 타 시스템에 영향이 없는 안전한 커널 모듈을 개발해야 한다. 

eBPF는 커널모듈과는 다른 방식으로 안정성을 제공한다. eBPF는 verifier를 이용해 실행에 문제가 없는 프로그램만 로드되도록 보장해 시스템에 충돌이나 무한루프에 빠지지는 등 로직상의 오류가 있다면 로드되지 않는다.

## eBPF 프로그램의 동적 로딩

eBPF 프로그램은 커널에 동적으로 로드되거나 언로드될 수 있다. 또한 eBPF에 attach 한 이벤트가 발생하면 이벤트 발생원인에 상관없이 트리거된다. 예를들어 파일 쓰기 이벤트를 attach하면 모든 파일 쓰기 이벤트가 발생할때 eBPF 프로그램이 트리거된다. 또한 eBPF 프로그램은 실행 즉시 동작하며 재부팅이 요구되지 않는다.

## High Performance of eBPF Programs

eBPF 프로그램은 매우 빠르다. User space와 kernel space간의 동작에 오버헤드가 필요 없다. XDP로 라우팅 프로그램을 작성 했을 때, 일반적인 커널에 구현한 것에 비해 2.5배 성능이 향상되고, IPVS보다 4.3배 성능 향상을 보인바 있다. eBPF는 불필요한 User space 처리가 필요 없으며 kernel space에서 처리가 가능하고 필터를 사용하여 원하는 정보만을 User space로 전달할 수 있다.

## eBPF in Cloud Native Environments

요즘 프로그램들은 서버에서 직접 실행하는 대신에 Kubernetes와 같은 클라우드 환경에서 동작하는 일이 많다. Container의 경우 각 Container가 kernel layer를 가상화하는것이 아닌 모든 container가 kernel layer 공유한다. 즉, Pod에서 실행되는 Container는 어느 Worker node에 deploy되든 kernel들은 항상 공유하기 때문에 Pod내의 container들의 동작들 eBPF를 통해 성능 추적이나 Observility가 가능해진다.

{{< figure src="/images/ebpf/learning-ebpf-1.png">}}

eBPF 프로그램을 사용하지 않을 경우, sidecar pattern과 같이 container에 로깅이나 audit을 위한 sidecar를 포함시킬 수 있다. 이 경우에는 Pod의 재시작, 기존 Container의 수정, yaml파일의 수정 등이 수반된다. 
또한 service mesh 형태에서 로깅을 위해 특정 Pod가 추가될 경우 아래 그림 처럼 network stack을 두번 경유해야 하므로 이에 따른 오버헤드가 발생한다. 

{{< figure src="/images/ebpf/learning-ebpf-1-2.png">}}

eBPF 프로그램을 쓰면 이러한 불필요한 과정이 없다!