---
title: "LeetCode 공부 - Distribute Candies"
date: 2023-01-29T16:05:59+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(645) - [Set Mismatch](https://leetcode.com/problems/set-mismatch/)

## 문제
정수형 `set`이 배열형태로 주어진다. `set`은  1부터 `set`의 크기인 `n`까지 중복되지 않은 값으로 채워져 있어야 한다. `nums`에 하나의 정수가 다른 정수(1 <= 다른정수> <= n)로 바뀌었다. 이 중복된 수와 원래 있어야 할 수를 찾아 배열 형태로 반환하라. 

### 입력
```
Input: nums = [1,2,2,4]
```

### 출력
```
class Solution {
public:
    vector<int> findErrorNums(vector<int>& nums) {
        unordered_map<int, int> mp;
        int ret1 =0;
        int ret2 =0;

        sort(nums.begin(), nums.end());

        for (int i = 0; i < nums.size(); i++) {
            if (mp[nums[i]] > 0) {
                // Found duplicated
                ret1 = nums[i];
                // Erase duplicated value which is in ith index.
                nums.erase(nums.begin()+i);
                break;
            }
            else {
                mp[nums[i]]++;
            }
        }
        for (int i = 0; i < nums.size(); i++) {
            // if index and value is mismatch, it means that duplicated value is here.
            if (nums[i] != i + 1) {
                ret2 = i + 1;
                break;
            }
        }
        if (ret2 == 0) {
            ret2 =nums.size() + 1;
        }
        return {ret1, ret2};
        }
};
```


