---
title: "LeetCode 공부 - Add Binary"
date: 2022-12-08T00:25:33+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(67) - Add Binary

## 문제
Binary를 나타내는 문자열 `s1`, `s2`가 주어질 때 두 Bianry를 합 한 문자열을 반환하라.

### 입력
```
Input: a = "1010", b = "1011"
```

### 출력
```
Output: "10101"
```

## 풀이
1. 두 문자열의 끝에서 부터 0번 째 index 까지 순회한다.
2. 순회하며 각각 `i`, `j`위치에 있는 바이너리를 계산한다.
3. `i`와 `j`의 값을 `carry`에 저장하고, `carry`는 모듈러 연산을 통해 나머지 값을 반환할 string의 첫 번째 위치에 저장한다.
4. `carry`는 나누기의 몫을 취하고, 해당 값을 유지한다. 
5. `carry`의 모듈러,나머지 연산과 `while` loop에서 index가 0 이상일 경우에만 연산하는 부분이 포인트다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `addBinary()`만 보시면 됩니다.
```
#include<iostream>
#include<string>
using namespace std;

string addBinary(string a, string b) {
    int a_size = a.size();
    int b_size = b.size();

    int a_index = a_size - 1;
    int b_index = b_size - 1;
    int carry = 0;

    string ret = "";
    while (a_index >= 0 || b_index >= 0 || carry) {
        if (a_index >= 0) {
            carry += a[a_index--] - '0';
        }
        if (b_index >= 0) {
            carry += b[b_index--] - '0';
        }
        ret.insert(0, to_string(carry % 2));
        carry /= 2;
    }
    return ret;
}

int main() {

    string s1 = "1010";
    string s2 = "1011";
    
    cout << addBinary(s1, s2);
}
```

