---
title: "LeetCode 공부 - Find the Difference"
date: 2023-01-15T18:25:02+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(387) - [ind the Difference](https://leetcode.com/problems/find-the-difference/)

## 문제
문자열 `s`와 `t`가 주어진다. 문자열 `t`는 문자열 `s`를 셔플링하고, 여기에 문자 하나를 추가한 문자열이다.
주어진 문자열 `t`에서 추가된 문자를 찾아 반환하라.

### 입력
```
Input: s = "abcd", t = "abcde"
```

### 출력
```
Output: "e"
```

## 풀이
0. 소문자 알파벳만으로 구성된 문자열이므로, 모든 문자의 출현 빈도를 `int[26]`으로 해결할 수 있다.
1. `int[26]` 배열을 `s`, `t`용으로 각자 하나씩 만들고, 두 배열을 순회하면서 출현 빈도가 다른 하나의 문자를 반환한다.
2. 문자 계산은 삽입 시 `c - 'a'`로 하여 `a`는 0 번째 index에 추가되도록 하고, 반환할 때는 `index + 'a'`로 계산하여 index를 알파벳으로 변환한 후 반환한다.

## 코드
```
#include<iostream>

using namespace std;

char findTheDifference(string s, string t) {
    int arr_s[26] = { 0, };
    int arr_t[26] = { 0, };

    for (int i = 0; i < s.size(); i++) {
        arr_s[s[i] - 'a']++;
    }
    for (int i = 0; i < t.size(); i++) {
        arr_t[t[i] - 'a']++;
    }

    for (int i = 0; i < 26; i++) {
        if (arr_s[i] != arr_t[i]) {
            return i + 'a';
        }
    }
}

int main() {
    string s = "abcd";
    string t = "abcde";

    cout << findTheDifference(s,t);
}
```