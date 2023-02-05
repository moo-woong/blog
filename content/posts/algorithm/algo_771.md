---
title: "LeetCode - Jewels and Stones "
date: 2023-02-05T15:52:48+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm","map"]
---

# LeetCode(771) - [Jewels and Stones](https://leetcode.com/problems/jewels-and-stones/description/)

## 문제
문자열 `jewels`와 `stones`가 주어진다. `stones`는 내가 가지고 있는 동의 종류들이고, `jewels`는 보석의 종류들이다. 내가 가지고 있는 돌들 중 보석이 몇개인지 반환하라.

### 입력
```
Input: jewels = "aA", stones = "aAAbbbb"
```

### 출력
```
Output: 3
```
### 설명
0. `stones`는 중복이 가능하다.
1. `stones`와 `jewels`의 각 문자는 대소문자가 구분된다.

## 풀이
0. `stones`를 순회하며 각 문자들을 `map`의 `key`로, 등장 횟수를 `value`로 저장한다.
1. `jewels`를 순회하며 각 문자들을 `map`에서 검색 후 등장횟수들을 모두 카운트 후 반환한다.

## 코드
```
class Solution {
public:
    int numJewelsInStones(string jewels, string stones) {
        unordered_map<char, int> mp;
        for (char c : stones) {
            mp[c]++;
        }
        int ret = 0;
        for (char c : jewels) {
            if (mp.find(c) == mp.end())  continue;
            ret = ret + mp.find(c)->second;
        }
        return ret;
    }
};
```
