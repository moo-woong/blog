---
title: "LeetCode 공부 - Palindrome Number"
date: 2022-12-01T00:27:00+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---
# LeeCode(9) - Palindrome Number

## 문제
integer `x`가 주어질 때, `x`가 Palindrome(회문)을 만족하면 `true`를 return, 아니라면 `false`를 리턴

### 입력
```
x = 121
```

### 출력
```
true
```

## 풀이
1. 입력 `x`를 string으로 변환
2. 앞부분을 가르키는 index `front`와 뒷부분을 가르키는 index `back`을 만들어 앞부분은 증가를, 뒷부분은 감소하며 전체 string 비교
3. `front`가 `back`보다 커질 때 까지 비교하여 `front`가 `back`보다 커진다면 회문으로 판단, 순회를 종료하고 `true`반환. 비교 중 다른 값이 나온다면 곧바로 `false`반환

## 코드
```
class Solution {
public:
    bool isPalindrome(int x) {
        string s = to_string(x);
        int front = 0, back = s.size() - 1;
        while (front <= back) {
            if (s[front++] != s[back--])
                return false;
        }
        return true;
    }
};
```

## 참고
- to_string은 <string> library에 있음