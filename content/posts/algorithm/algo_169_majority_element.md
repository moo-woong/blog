---
title: "Leetcode 공부 - Majority Element"
date: 2023-01-10T23:47:16+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(169) - [Majority Element](https://leetcode.com/problems/majority-element/description/)

## 문제
`n`의 길이를 가지는 정수형 배열 `nums`가 주어진다. `nums`에 저장된 정수 중 가장 많은 빈도의 정수를 반환하라.
가장 많은 빈도를 갖는 정수는 `2/n`개 이상이다.


### 입력
```
nums = [2,2,1,1,1,2,2]
```

### 출력
```
Output: 2
```

## 풀이
0. `key`는 정수 값을, `value`는 정수의 빈도를 나타내는 `unordered_map`을 사용한다.
1. `nums`를 순회하면서, 해당 정수의 `key`를 조회, `value`의 값을 +1 하여 빈도를 나타낸다.
2. 빈도가 `2/n`이상이라면 해당 정수가 가장 많은 빈도의 정수이므로, 해당 정수를 반환한다.

## 코드
```
class Solution {
public:
    int majorityElement(vector<int>& nums) {
        unordered_map<int, int> umap;
        int maxSize = nums.size() / 2;
        for(int num : nums) {
            int count = ++umap[num];
            if (count > maxSize) {
                return num;
            }
        }
        return 0;
    }
};
```