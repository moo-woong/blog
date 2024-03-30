---
title: "Learning eBPF - Ch.2 eBPF's "Hello World" 1/?"
date: 2024-03-04T14:26:52Z
categories: ["Study"]
tags: ["eBPF"]
draft: true
---

[Learning eBPF](https://cilium.isovalent.com/hubfs/Learning-eBPF%20-%20Full%20book.pdf) 스터디

eBPF의 강력함, 좋은점 들은 이전 챕터에서 다루었으나, 좀 더 강력함을 체감하기 위해 "Hello World" 예제를 이용해 더 잘 이해할 수 있도록 하자.

eBPF 프로그램을 위한 다양한 라이브러리와 프레임워크가 있으나, 접근하기 가장 쉬운 BCC Python 프레임워크를 이용해보자.

## BCC's "Hello World"

BCC 설치를 위해 BPF, eBPF 설정들을 확인하고 BCC를 설치하자.
[여기](https://github.com/iovisor/bcc/blob/master/INSTALL.md)서 관련 정보를 확인할 수 있다.

다음과 같은 샘플 예제를 실행해 보자

```python
from bcc import BPF

program = r"""
int hello(void *ctx) {
    bpf_trace_printk("Hello World!");
    return 0;
}
"""
b = BPF(text=program)
syscall = b.get_syscall_fnname("execve")
b.attach_kprobe(event=syscall, fn_name="hello")
b.trace_print()
```

위 예제 코드는 두 부분으로 나뉠 수 있다. 
1. eBPF 프로그램
2. eBPF 프로그램을 로드하고 결과를 읽는 User space

### eBPF 프로그램

```c
int hello(void *ctx) {
    bpf_trace_printk("Hello World!");
    return 0;
}
```

위 c 코드인 hello 함수는 `Helper Function`인 `bpf_trace_printk`를 호출gksek. `helper function`은 eBPF 프로그램 기능이라기 보다 System과 더 쉽게 상호작용하기 위해 제공되는 기능들이다.

```python
b = BPF(text=program)
```

hello 함수 전체는 파이썬에서는 문자열로 처리된다. C코드는 컴파일이 필요하지만 BCC에서 이를 대신 처리해주므로 우리는 코드를 문자열로 전달해주면 된다. 

```python
syscall = b.get_syscall_fnname("execve")

b.attach_kprobe(event=syscall, fn_name="hello")
```

eBPF 프로그램은 event를 attach 해야 한다. 본 예제에서는 `execve`를 이벤트로 설정했다. 이제 이 kernel에서 누군가가 프로그램을 실행한다면 eBPF 프로그램이 트리거 된다.

```python
b.trace_print()
```

`trace_print`함수는 프로그램이 중지될 때 까지 무한히 반복하며 모든 trace를 출력한다. 

실행해 보자.

```sh
hugh@dev:~/source/ebpf/ch2$ sudo python3 helloworld.py 
[sudo] password for hugh: 
b'           <...>-337271  [001] d..31 1988822.065540: bpf_trace_printk: Hello World!'
b'           <...>-337272  [002] d..31 1988822.074115: bpf_trace_printk: Hello World!'
b'           <...>-337273  [001] d..31 1988822.085697: bpf_trace_printk: Hello World!'
b'           <...>-337274  [001] d..31 1988822.092879: bpf_trace_printk: Hello World!'
b'           <...>-337275  [001] d..31 1988822.136918: bpf_trace_printk: Hello World!'
b'           <...>-337276  [002] d..31 1988822.143317: bpf_trace_printk: Hello World!'
b'           <...>-337277  [001] d..31 1988822.149965: bpf_trace_printk: Hello World!'
b'           <...>-337278  [001] d..31 1988822.158347: bpf_trace_printk: Hello World!'
```

뭔가 부지런하게 계속 출력된다. 내 서버에서 무엇인가 이렇게 많이 실행되고 있다.

다음 그림은 샘플 예제의 전제적인 구조를 도식화 한것이다(Apps부분은 신경 안써도 된다).
{{< figure src="/images/ebpf/learning-ebpf-2-1.png">}}

파이썬 프로그램은 C언어로 작성된 eBPF프로그램을 컴파일하고 이를 커널에 로드한다. 그리고 execve syscall kprobe에 attach한다. 이후 execve syscall이 호출될 때 마다 hello()가 트리거 된다. 

eBPF프로그램이 사용하는 `bpf_trace_printk()` `/sys/kernel/debug/tracing/trace_pipe`로 로그를 출력하도록 되어 있어 파이썬은 해당 내용을 읽어 출력한다. 이 파일은 모든 eBPF프로그램이 공유하므로 만약 eBPF 프로그램이 `bpf_trace_printk()`들을 사용한다면 여기서 나의 eBPF프로그램이 어떤걸 출력하는지 구분하기 어려울 수 있다.

## BPF Maps

`Map`은 User space와 eBPF프로그램에서 접근할 수 있는 데이터 구조다. 맵은 eBPF와 기존의 기술들을 구분짓은 매우 중요한 기술이다. (BPF맵과 eBPF맵을 혼용해서 사용하고 있으나 동일 기능으로 봐도 무방하다)
Use case는 다음과 같다.

- User space에서 eBPF프로그램이 사용할 설정정보를 작성한다.
- eBPF 프로그램이 상태정보를 저장해 다른 eBPF프로그램이 사용할 수 있도록 한다.(또는 상태정보를 비휘발성으로 저장하기 위해 사용)
- eBPF 프로그램의 metric정보를 저장해서 추후 User space에서 사용할 수 있도록 한다.

[BPF Map](https://elixir.bootlin.com/linux/v5.15.86/source/include/uapi/linux/bpf.h#L878)에 BPF Map 타입들이 정의되어 있다. 일반적으로 key-value pair이며 hash table, ring buffer, array등의 예시들을 볼 수 있다.

일부 맵들은 4바이트의 인덱스 키를 가지는 배열로 정의되며 해시 테이블 형식의 맵들도 있으며, FIFO 큐, FILO 큐 와 같이 특정 유형의 작업들에 특화된 맵들도 있다.  

일부 맵들은 특정 타입읠 저장하는 용도로 특화되기도 한다. 예를들면 [sockmap](https://lwn.net/Articles/731133/)과 [devmap](https://docs.kernel.org/bpf/map_devmap.html)은 네트워크와 관련된 소켓과 네트워크 장치들의 정보들을 가지고 있다가 eBPF프로그램이 트래픽을 리닥이렉션하는데 사용되기도 한다. 프로그램 배열 맵읜 eBPF 프로그램을 indexing하고 이후에 알아볼 `tail call`에서 eBPF 프로그램간의 chain할 때 사용되기도 한다. 

## Hash Table Map

아래 eBPF프로그램은 `execve` syscall의 entry point에 kprobe를 attach 한다. 이 프로그램은 UID가 key이고, 해당 UID로 실행중인 프로세스가 execve를 호출한 횟수를 카운트 한다.

```python
#!/usr/bin/python3  
from bcc import BPF
from time import sleep

program = r"""
BPF_HASH(counter_table); 

int hello(void *ctx) {
   u64 uid;
   u64 counter = 0;
   u64 *p;

   uid = bpf_get_current_uid_gid() & 0xFFFFFFFF;
   p = counter_table.lookup(&uid);
   if (p != 0) {
      counter = *p;
   }
   counter++;
   counter_table.update(&uid, &counter);
   return 0;
}
"""

b = BPF(text=program)
syscall = b.get_syscall_fnname("execve")
b.attach_kprobe(event=syscall, fn_name="hello")

# Attach to a tracepoint that gets hit for all syscalls 
# b.attach_raw_tracepoint(tp="sys_enter", fn_name="hello")

while True:
    sleep(2)
    s = ""
    for k,v in b["counter_table"].items():
        s += f"ID {k.value}: {v.value}\t"
    print(s)
```

1. `BFP_HASH()`는 BCC macro로 hash table map을 정의한다.
2. `bpf_get_current_uid_gid()`는 kprobe 이벤트를 트리거한 프로세스의 UID를 얻는데 사용하는 helper function이다. 상위 32bit는 GID를 나타낸다.
3. `b["counter_table"]`를 보면 BCC는 해시 테이블을 위한 Python 객체를 자동으로 생성한다. 

위 코드는 uid 마다 `execve` syscall을 할 때 마다 count값을 증가시키고 map에 저장해둔다. 만약 카운트 값이 2인 유저가 execve syscall을 호출하게 되면 해당 uid를 key로 갖는 hash map의 value값은 기존에 `2` 이고, 여기에 1을 증가시켜 다시 `3`으로 저장한다.

결과를 보자. 

> [!NOTE]
> bpf ap을 위해서는 root 권한이 필요하다.

```sh
hugh@dev:~/source/ebpf/ch2$ sudo python3 hello-map.py 
[sudo] password for hugh: 

ID 1000: 1	
ID 1000: 2	
ID 1000: 4	
ID 1000: 4	
ID 1000: 5	
ID 1000: 5	
ID 1000: 6	ID 0: 1	
ID 1000: 7	ID 0: 1	
ID 1000: 7	ID 0: 1	
ID 1000: 7	ID 0: 1	
```

위 실행결과에서 보듯이 다른 터미널에서 테스트용으로 접속한 계정의 uid는 1000이다.
```sh
hugh@dev:~/source/ebpf/ch2$ id
uid=1000(hugh)
```

`ID: 1000` 은 내가 `ls` 명령을 할 때 마다 count되었으며, `ID 0(root)`는 내가 `sudo`로 수행했을 때 root 계정으로 `ls`명령어가 실행되어 `execve`가 카운트 되었으므로 count값이 증가한 것이다.

## Ring Buffer

다음의 예제는 첫 번째 예제와 동일한 동작을 한다. execve를 사용하는 PID와 cmd동일한 결과 계속해서 출력한다. 하지만 링버퍼를 이용해 더욱 정교한 동작이 가능함을 보여주는 예제다.

```python
#!/usr/bin/python3  
from bcc import BPF

program = r"""
BPF_PERF_OUTPUT(output); 
 
struct data_t {     
   int pid;
   int uid;
   char command[16];
   char message[12];
};
 
int hello(void *ctx) {
   struct data_t data = {}; 
   char message[12] = "Hello World";
 
   data.pid = bpf_get_current_pid_tgid() >> 32;
   data.uid = bpf_get_current_uid_gid() & 0xFFFFFFFF;
   
   bpf_get_current_comm(&data.command, sizeof(data.command));
   bpf_probe_read_kernel(&data.message, sizeof(data.message), message); 
 
   output.perf_submit(ctx, &data, sizeof(data)); 
 
   return 0;
}
"""

b = BPF(text=program) 
syscall = b.get_syscall_fnname("execve")
b.attach_kprobe(event=syscall, fn_name="hello")
 
def print_event(cpu, data, size):  
   data = b["output"].event(data)
   print(f"{data.pid} {data.uid} {data.command.decode()} {data.message.decode()}")
 
b["output"].open_perf_buffer(print_event) 
while True:   
   b.perf_buffer_poll()
```

1. `BPF_PERF_OUTPUT(output);` BCC에서 pre defined된 macro인 map을 선언한다.
2. `bpf_get_current_pid_tgid()` 함수는 eBPF프로그램을 트리거한 PID를 제공하는 helper function이다.
3. `bpf_get_current_comm()`은 프로세스에서 execve syscall을 호출한 cmd를 반환하는 helper function이다.
4. `bpf_probe_read_kernel()`은 eBPF프로그램 내에서 문자열을 읽는 helper fucntion이다. 이 예제에서는 항상 `"Hello World"`를 읽도록 되어 있다.
5. `print_event()`는 콜백함수로 Perf Ring Buffer의 event에서 data를 출력하는 역할을 한다.
6. `b["output"].open_perf_buffer(print_event)`는 맨 처음 선언한 perf Ring Buffer를 open한다. `print_event`를 매개변수로 전달해 event를 출력하도록 한다.

{{< figure src="/images/ebpf/learning-ebpf-2-2.png">}}

이제 이 예제는 `hello()`라는 eBPF 프로그램을 커널에 로드하고 hello 프로그램은 `output`이라는 Ring Buffer에 `data`를 업데이트하고 user space인 Python에서 `output` 버퍼를 읽어서 출력한다.

## Function Calls

eBPF 프로그램에서 Kernel에서 제공하는 helper fucition을 호출하는 방법을 학습했다. 그러면 eBPF 프로그램을 함수화 할 수 있는 방법은 없을까? 초기에는 eBPF 프로그램에서 helper function 외에 함수를 호출하는 것을 허용하지 않았다. 이런 문제를 해결하기 위해 프로그래머들은 함수 호출 대신 함수를 inline화 시켜서 사용했다. 이와 같이 공통된 기능을 위해서 함수화 대신 inline을 사용 한다면 공통된 기능이 여러곳에 동시에 존재하므로 복사본이 여러개 생기는 문제가 발생한다.

Kernel 4.16 및 LLVM 6.0부터는 함수화를 못하도록 제한하는 것이 해제되었다. 다음으로는 eBPF에서 복합한 기능을 더 작은 부분으로 분할해서 사용하는 Tail Call을 학습해보자

## Tail Calls

eBPF프로그램에서 다른 eBPF 프로그램을 호출하는 Tail Call은 User psace에서 `execve()`를 호출하는 것과 유사하게 eBPF 프로그램을 호출하면 현재 context를 대체한다. 즉, 다시 Caller로 context가 전환되지 않는다.

Tail Call은 다음의 helper function을 이용한다.

```c
long bpf_tail_call(void *ctx, struct bpf_map *prog_array_map, u32 index)
```
세 arguments의 의미는 다음과 같다
- void *ctx: context를 전달할 때 사용
- struct bpf_map *prog_array_map: eBPF의 identifier인 file descriptor의 집합을 포함하고 있는 맵이다. 타입은 `BPF_MAP_TYPE_PROG_ARRAY`. 
- u32 index: eBPF 프로그램들 중 어떤 프로그램을 호출해야하는지 명시하는 index 

사용하는 예시를 보자. BCC를 사용한다면 tail call을 위해서 `bpf_tail_call`를 직접 사용하지 않고 더욱 간결한 형태를 지원한다.

```python
prog_array_map.call(ctx, index)
```

BCC에서 eBPF프로그램을 compile할 때 다음의 형태로 compile된다.
```python
bpf_tail_call(ctx, prog_array_map, index)
```

```python
from bcc import BPF
import ctypes as ct

program = r"""
BPF_PROG_ARRAY(syscall, 300);

int hello(struct bpf_raw_tracepoint_args *ctx) {
    int opcode = ctx->args[1];
    syscall.call(ctx, opcode);
    bpf_trace_printk("Another syscall: %d", opcode);
    return 0;
}

int hello_exec(void *ctx) {
    bpf_trace_printk("Executing a program");
    return 0;
}

int hello_timer(struct bpf_raw_tracepoint_args *ctx) {
    int opcode = ctx->args[1];
    switch (opcode) {
        case 222:
            bpf_trace_printk("Creating a timer");
            break;
        case 226:
            bpf_trace_printk("Deleting a timer");
            break;
        default:
            bpf_trace_printk("Some other timer operation");
            break;
    }
    return 0;
}

int ignore_opcode(void *ctx) {
    return 0;
}
"""

b = BPF(text=program)
b.attach_raw_tracepoint(tp="sys_enter", fn_name="hello")

ignore_fn = b.load_func("ignore_opcode", BPF.RAW_TRACEPOINT)
exec_fn = b.load_func("hello_exec", BPF.RAW_TRACEPOINT)
timer_fn = b.load_func("hello_timer", BPF.RAW_TRACEPOINT)

prog_array = b.get_table("syscall")
prog_array[ct.c_int(59)] = ct.c_int(exec_fn.fd)
prog_array[ct.c_int(222)] = ct.c_int(timer_fn.fd)
prog_array[ct.c_int(223)] = ct.c_int(timer_fn.fd)
prog_array[ct.c_int(224)] = ct.c_int(timer_fn.fd)
prog_array[ct.c_int(225)] = ct.c_int(timer_fn.fd)
prog_array[ct.c_int(226)] = ct.c_int(timer_fn.fd)

# Ignore some syscalls that come up a lot
prog_array[ct.c_int(21)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(22)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(25)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(29)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(56)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(57)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(63)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(64)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(66)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(72)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(73)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(79)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(98)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(101)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(115)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(131)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(134)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(135)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(139)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(172)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(233)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(280)] = ct.c_int(ignore_fn.fd)
prog_array[ct.c_int(291)] = ct.c_int(ignore_fn.fd)

b.trace_print()
```

1. `BPF_PROG_ARRAY(syscall, 300)` BCC에서 BPF_MAP_TYPE_PROG_ARRAY MAP 생성을 위해 제공하는 Macro다. `syscall`을 호출하고 300개의 엔트리를 할당한다.
2. `int hello(struct bpf_raw_tracepoint_args *ctx)` `sys_enter` Tracepoint에 attach할 hello 함수다. sys_enter는 syscall이 호출될 때 발생하는 이벤트를 추적할때 사용하는 Tracepoint의 일종이다.
3. `int opcode = ctx->args[1];` sys_enter의 경우 ctx에 어떤 syscall이 실행되고 있는지 구분되는 ID가 포함돼있다.
4. `syscall.call(ctx, opcode);` 여기서 BCC는 현재 syscall Tail Call로 변환된다.
5. `int hello_exec(void *ctx)` 는 syscall array map에 로드될 프로그램이다. syscall이 execve()인 경우 Tail Call로 실행된다.
6. `int hello_timer` 또한 syscall array map에 로드될 프로그램이다. 
7. `b.attach_raw_tracepoint(tp="sys_enter", fn_name="hello")` 이전의 kprove에 attach한것과 달리 `sys_enter`의 Tracepoint에 attach한다.
8. `b.load_func()`는 FD를 반환한다. 즉 위 eBPF프로그램에서 선언한 `hello`, `hello_timer`, 그리고 `ignore_opcode`의 FD를 저장하고 있는다.
9. `prog_array = b.get_table("syscall")` syscall map을 생성한다. execve()의 syscall번호는 59다. execve()호출에 대한 Tail call을 우리가 만든 `hello_exec`에 attach한다. Timer 관련 syscall들인 222~226은 `hello_timer`에 attach한다. 해당 번호들은 x86 64bit 기준이며, [여기](https://github.com/torvalds/linux/blob/v6.7/arch/x86/entry/syscalls/syscall_64.tbl)서 모든 syscall 번호를 확인할 수 있다.  

프로그램을 실행해 보자

```sh
b'            bash-5301    [000] d..3.  5999.934517: bpf_trace_printk: Creating a timer'
b'            bash-5301    [000] d..3.  5999.934575: bpf_trace_printk: Creating a timer'
b'            bash-5301    [000] d..3.  5999.934827: bpf_trace_printk: Creating a timer'
b'            bash-5301    [000] d..3.  5999.934845: bpf_trace_printk: Creating a timer'
b'            bash-5301    [000] d..3.  5999.934911: bpf_trace_printk: Deleting a timer'
b'            bash-5301    [000] d..3.  5999.934937: bpf_trace_printk: Creating a timer'
b'            bash-5301    [000] d..3.  5999.935086: bpf_trace_printk: Creating a timer'
b'            bash-5301    [000] d..3.  5999.935410: bpf_trace_printk: Deleting a timer'
b'            bash-5301    [000] d..3.  5999.935488: bpf_trace_printk: Deleting a timer'
b'            bash-5301    [000] d..3.  5999.935670: bpf_trace_printk: Deleting a timer'
b'              ls-5301    [000] d..3.  5999.935804: bpf_trace_printk: Deleting a timer'
b'              ls-5301    [000] d..3.  5999.935891: bpf_trace_printk: Deleting a timer'
b'              ls-5301    [000] d..3.  5999.937038: bpf_trace_printk: Creating a timer'
b'              ls-5301    [000] d..3.  5999.937504: bpf_trace_printk: Creating a timer'
b'              ls-5301    [000] d..3.  5999.937680: bpf_trace_printk: Creating a timer'
b'              ls-5301    [000] d..3.  5999.937887: bpf_trace_printk: Creating a timer'
```

위 결과는 수 많은 trace 중 `ls -al` 을 입력했을 때 나오는 로그다. `ls`를 하면 timer가 호출되나 보다.
