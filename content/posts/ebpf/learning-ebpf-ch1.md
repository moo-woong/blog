---
title: "Learning eBPF - What Is eBPF, and Why Is it Imports? 1/2"
date: 2024-03-02T07:04:46Z
categories: ["Study"]
tags: ["eBPF"]
---

[Learning eBPF](https://cilium.isovalent.com/hubfs/Learning-eBPF%20-%20Full%20book.pdf) 스터디

eBPF는 개발자가 코드를 직접 커널 레이어에서 로드하고 커널의 동작을 변경할 수 있도록 허용하는 혁신적인 기술이다. 
eBPF는 고성능의 네트워킹, Observability, 보안도구에 이용할 수 있다. eBPF를 활용한 신규 애플리케이션을 만든다면
기존의 애플리케이션에 추가적인 수정이나 재설정등이 불필요한 이점이 있다.

eBPF를 이용해서 다음이 것들을 할 수 있다.

- 시스템 측면에서(low level에서), 대부분의 성능측정
- 가시성을 제공하는 고성능의 네트워킹 분석
- 비정상 행위를 탐지하거나 예방

**Note**
Moniroting: 시스템의 오류, 결함 또는 비정상적인 데이터들을 수집 및 가시화
Observability: 애플리케이션의 동작에 대한 세부적인 인사이트를 제공하기 위해 다양한 데이터(log, metric, audit)을 수집하고 분석하는 것을 의미하며 Micro-Service 아키텍쳐의 전반적인 구조적 결함을 찾는데 활용됨. 
Monitoring은 Observability의 핵심 구성 요소이며, Observability는 보다 근본적인 문제를 파악하는데 주안점을 둠.

## eBPF의 기원

eBPF는 BSD Packet Filter가 기원이다. 1993년에 게재된 논문에서 32비트 아키텍쳐에서 network 패킷을 accept할지, reject할지 판단하는 filter에 대해 발표했다.
해당 논문의 주안점은 패킷을 accept하고 reject하는 로직이 아닌 사용자가 직접 커널 레벨에서 프로그램을 작성해 커널의 동작을 변경한다는 점이며, 이 부분이 eBPF의 핵심이다.

## BPF에서 eBPF로

BFP는 우리가 아는 `extended BPF` 또는 `eBPF`로 진화되었으며 eBPF는 커널 3.18부터 포함되었으며 다음과 같은 주요 변경점이 있다.
- 64비트 아키텍쳐를 지원하도록 전면 수정되었다. 
- User space와 Kernal space 양쪽에서 접근이 가능한 `eBPF maps`가 추가 되었다.
- User space에서 호출 가능한 `bpf()` 시스템콜이 추가되었다. 
- BPF를 지원하는 몇몇 함수들이 추가되었다.
- eBPF용 프로그램이 안전하게 실행되는지 검사하는 Verifier가 추가되었다.

## 상용시스템으로의 eBPF의 진화

- 2005년 부터 kprobes(kernel probes)가 리눅스 커널에 추가되었다. kprobes는 대부분의 instruction에 트랩을 설정하도록 해주며 이 덕분에 개발자들은 디버깅과 성능측정을 위해 커널 모듈에 kprobes를 붙일 수 있었다.
- 2015년에는 eBPF프로그램을 kprobes 추가하는 기능이 추가되었고 커널의 네트워크 스택에 hooking하는 기능 또한 추가되었다. 이를 계기로 리눅스 시스템에서 audit 방식이 진화하는 계기가 되었다.
- 2016년 부터 eBPF 기반의 툴들이 사용되기 시작되었다. Netflix는 eBPF는 초능력을 가져다준다고도 하였으며, eBPF를 사용하는 Container기반의 네트워킹 프로젝트인 Cilium프로젝트가 발표되기도 했다. Meta(Facebook)은 2017년 부터 모든 트래픽이 eBPF/XDP를 거치도록 변경했다.
- 2018년에는 eBPF가 리눅스 커널에서 별도의 서브시스템으로 분리되었다. 
- 2020년에는 LSM(Linux Security Module)에 eBPF를 추가할 수 있도록 LSM BPF가 도입되었다.

## 패킷 필터라는 이름

탄생 배경이 Packet filtering이었으나, eBPF의 진화로 인해 이제 Packet filtering이라는 의미보다는 리눅스 커널을 안전하게 확장하는 방법으로 의미가 굳어졌다. 

## 리눅스 커널에서의 eBPF

리눅스 커널은 시스템에서 실행되는 애플리케이션과 하드웨어 사이의 계층이다. 애플리케이션들이 실행되는 계층은 하드웨어의 실행권한이 없는 User space라는 공간에서 실행된다. 대신에, 애플리케이션은 하드웨어를 실행하기 위해 System call(syscall)이라는 인터페이스를 사용해 커널에 특정 작업을 요청한다. syscall은 파일 쓰기, 네트워크 트래픽 수신, 메모리 접근등이 있을 수 있다. 일반적인 개발자들이라면 syscall을 직접 사용하지 않는다. 이는 고수준으로 추상화된 다양한 라이브러리들이 제공되고 있어 이 라이브러리들을 사용하고 있기 때문이다. `echo` 라는 유틸로 간단한 문자열을 출력하도록 할 때도 많은 syscall이 호출됨을 확인할 수 있다.

```sh
hugh@dev:~$ strace -c echo "hello"
hello
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 49.55    0.002829        2829         1           execve
 18.43    0.001052          35        30        12 openat
  8.99    0.000513          25        20           mmap
  7.64    0.000436          22        19           newfstatat
  5.04    0.000288          14        20           close
  2.45    0.000140          35         4           mprotect
  1.82    0.000104          34         3           munmap
  1.33    0.000076          25         3           read
  0.98    0.000056          18         3           brk
  0.96    0.000055          55         1         1 faccessat
  0.63    0.000036          36         1           write
  0.40    0.000023          23         1           set_tid_address
  0.39    0.000022          22         1           getrandom
  0.39    0.000022          22         1           rseq
  0.37    0.000021          21         1           set_robust_list
  0.33    0.000019          19         1           prlimit64
  0.30    0.000017          17         1           futex
------ ----------- ----------- --------- --------- ----------------
100.00    0.005709          51       111        13 total
hugh@dev:~$
```

애플리케이션들은 커널에 의존적이기 때문에 커널과의 상호작용을 이해하고 여기에 eBPF를 사용하면 새로운 인사이트를 얻을 수 있다.