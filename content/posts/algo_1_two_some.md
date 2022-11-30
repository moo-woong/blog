---
title: "LeetCode 공부 - Two Sum"
date: 2022-11-30T23:23:39+09:00
---

# LeeCode(1) - Two Sum

## 문제
integer 배열과 target이 주어질 때, 배열에서 두 정수의 합이 target을 만족하는 두 index를 반환

### 입력
```
nums = [2,7,11,15], target = 9
```

### 출력
```
[0,1]
```

## 풀이
1. 배열 순회 중 현재 배열의 값과 target과의 diff 값이 hash table에 있으면, diff key의 value와 현재 배열 index를 리턴.
2. hash table에 diff값이 없으면, 현재 배열 index의 value를 key로, index를 value로 table에 저장.
3. 배열 순회.

## 코드
```
class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        unordered_map<int, int> umap;
        vector<int> ret;

        for (int i = 0; i < nums.size(); i++) {
            int diff = target - nums[i];
            if (umap.count(diff)) {
                ret.push_back(umap[diff]);
                ret.push_back(i);
                return ret;
            }
            umap[nums[i]] = i;
        }
        return ret;
    }
};
```