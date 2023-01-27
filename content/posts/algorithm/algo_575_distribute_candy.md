---
title: "LeetCode 공부 - Distribute Candies"
date: 2023-01-25T00:29:52+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(575) - [Distribute Candy](https://leetcode.com/problems/distribute-candies/description/)

## 문제
Alice는 `n`개의 캔디를 가지고 있다. `i` 캔디는 `candyTpye[i]`의 타입이다. Alice는 살이쪄서 캔디를 줄여야한다..! 주치의는 Alice가 가지고 있는 캔디의 `n/2`만큼만 먹으라고 한다.

Alice는 최선의 선택을 하고싶다. `n/2`만큼을 먹어야한다면, 가능한한 많은 종류의 캔디를 먹고싶다.
만약 6종류의 캔디가 있다면, 3종류의 캔디를 먹고, 3종류의 캔디 총 6개가 있다면 있다면 `n/2`를 한 만큼인 3개만을 먹되, 3종류의 캔디를 먹고싶다. 캔디의 종류를 나타내는 `candyType`이 주어질 때, Alice가 먹을 수 있는 캔디의 최대 개수를 반환하라.

### 입력
```
Input: candyType = [1,1,2,2,3,3]
```

### 출력
```
Output: 3
```

## 풀이
0. 캔디의 종류를 `key`로 하여 unordered_map을 이용한다.
1. unordered_map의 크기(캔디 종류)가 `n/2` 이상이라면 `n/2`만큼의 값을, 이하라면 map의 사이즈만큼이 최대한의 섭취 가능한 캔디 개수이므로 해당 개수를 반환한다.

## 코드
```
class Solution {
public:
    int distributeCandies(vector<int>& candyType) {
        unordered_map<int, int> mp;
        for(int i:candyType) {
            mp[i]++;
        }
        return min(mp.size(), candyType.size() / 2);
    }
};
```