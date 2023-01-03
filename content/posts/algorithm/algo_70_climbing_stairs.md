---
title: "LeeCode 공부 - Climbing Stairs"
date: 2022-12-08T01:41:17+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeeCode(70) - Climbing Stairs

## 문제
`n`개의 단이 있는 계단이 있다. 계단을 오르는 방법은 1칸씩 혹은 2칸씩 오르는 방법이 있다. `n`번째의 계단을 오르는 방법을 몇개나 있는지 반환하라.

### 입력
```
Input: n = 3
```

### 출력
```
Output: 3
Explanation: There are three ways to climb to the top.
1. 1 step + 1 step + 1 step
2. 1 step + 2 steps
3. 2 steps + 1 step
```

## 풀이
1. 풀때마다 항상 어려운 DP(Dynamic Programming)문제다.
2. 문제의 Discussion에서 설명이 잘되어있는게 있어서 이해하고 이를 번역해본다.
- 계단은 1칸 혹은 2칸씩만 오를 수 있다.
- 계단이 1칸인 경우, 경우의 수는 1칸만 올라가는 방법 뿐이다.
- 계단이 2칸인 경우, 1칸 씩 두번, 두칸을 한번에 올라서 총 2개의 방법이 있다.
- 계단이 3칸인 경우, 만약에 한칸을 먼저 오르면, 남는 계단은 2칸이다. 2칸을 오르는 방법은 앞서 계산한 두 개의 방법으로 가능하다. 계단을 두칸을 오른다면? 남은 계단은 한 칸 이므로, 앞서 계산한 한칸을 오르는 방법의 개수는 하나다.
- 즉, 현재 칸에서, n+1 계단을 오르는 방법은 현재 칸 까지 오를 때의 방법에서 +1 이고, n+2의 계단을 오르는 방법은 현재 칸 까지 오를 때의 방법에서 +2 방법이다.
- 바꿔 말하면, n 번째 계단을 오르는 방법은 n-1 방법의 개수와 n-2방법의 개수이다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `climbStairs()`만 보시면 됩니다.
```
#include<iostream>
#include<string>
using namespace std;

int climbStairs(int n) {
    int stairs[46] = { 0, };
    if (n <= 2) {
        return n;
    }
    stairs[1] = 1;
    stairs[2] = 2;

    for (int i = 3; i<=n; i++) {
        stairs[i] = stairs[i - 2] + stairs[i - 1];
    }
    return stairs[n];
}
int main() {

    int val = 4;
    
    cout << climbStairs(val);
}
```