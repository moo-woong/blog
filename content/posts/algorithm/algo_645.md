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
Output: [2,3]

```

## 풀이
0. 주어진 배열에 대해 중복을 찾아야 하고, 빠진 값 또한 찾아야 한다. 중복된 배열은 map으로 고유성을 찾고, 누락 된 값은 정렬 후 index와 값을 비교하여 다르다면 누락된 값으로 간주한다.
1. `nums`를 정렬한다.
2. `nums`를 순회하며 `map`에 기록한다. 현재 정수가 `map`에 있다면 중복된 값이므로 해당 값을 반환 배열에 먼저 삽입한다.
3. `nums`를 다시 순회하며 index와 값을 비교한다. 값은 오름차순으로 1부터 시작하여 1씩 증가하므로, `index + 1 == val`이어야 한다. 만약 다르다면 해당 값이 누락이므로 값을 반환배열에 넣는다.


## 코드
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


