---
title: "Leetcode 공부 - Container Duplicate"
date: 2023-01-13T23:13:43+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(217) - [Contains Duplicate](https://leetcode.com/problems/contains-duplicate/)

## 문제
정수 배열 `nums`가 주어진다. 중복된 정수가 배열에 있다면 `true`를 반환하고 중복이 없다면 `false`를 반환하라

### 입력
```
Input: nums = [1,1,1,3,3,4,3,2,4,2]
```

### 출력
```
Output: true
```

## 풀이
0. 배열을 순회하면서 각 값들을 `set`에 넣는다.
1. `set`에 현재 배열의 값과 동일한 값이 있다면 중복이므로 `true`를 반환한다.
2. 배열을 모두 순회했다면 중복이 없으므로 `false`를 반환한다.

## 코드
```
bool containsDuplicate(vector<int>& nums) {
        unordered_set<int> uset;
        for(int num : nums) {
            if(uset.count(num) > 0) {
                return true;
            }
            uset.insert(num);
        }
        return false;
    }
```