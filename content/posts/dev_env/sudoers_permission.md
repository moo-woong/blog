---
title: "[Dev/Infra] XXX is not in the sudoers file.  This incident will be reported."
date: 2023-01-03T21:25:33+09:00
categories: ["Dev/Infra"]
tags: ["CentOS","Troubleshooting"]
---

# XXX is not in the sudoers file.  This incident will be reported.

`Ubuntu`, `CentOS` 등 리눅스 환경을 새로 설치하면 만나는 오류.
개발 툴을 설정하기 위해 유틸들을 설치할때 `sudo`를 사용하다 마주하게 된다.

```
XXX is not in the sudoers file.  This incident will be reported.
```

# 원인
현재 접속중인 계정이 `sudoers`에 등록되지 않아 발생한다. `sudoers`파일에 현재 계정을 등록하여 `sudo`권한을 주자.

>`sudo`의 뜻은? "super user do".

>`su` 뜻은? "super user"


# 해결법
1. `su` 명령어로 `root`계정으로 전환
```
[hugh@localhost ~]$ su
Password:  #비밀번호 입력
[root@localhost hugh]# 
[root@localhost hugh]# 
```

2. `/etc/sudoers` 파일에서 현재 계정을 추가
```
     99 ## Allow root to run any commands anywhere
    100 root    ALL=(ALL)       ALL
    101 hugh    ALL=(ALL)       ALL # <-- sudo권한이 필요한 계정 추가
```
3. `root`계정에서 로그아웃하고 추가한 계정에서 `sudo`권한이 필요한 명령어 수행
```
[root@localhost hugh]# exit
exit
[hugh@localhost ~]$ 
[hugh@localhost ~]$ 
[hugh@localhost ~]$ sudo yum install -y vim
[sudo] password for hugh: 
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: mirror.kakao.com
 * extras: mirror.kakao.com
 * updates: mirror.kakao.com
Resolving Dependencies
--> Running transaction check
```




