---
title: "LeetCode - Degree of an Array"
date: 2023-02-05T15:22:58+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm","map"]
---

# LeetCode(697) - [Degree of an Array](https://leetcode.com/problems/degree-of-an-array/)

## 문제
정수 배열 `nums`가 주어진다. `nums`에서 가장 많이 등장하는 정수를 찾고, `nums`에서 가장 많이 등장하는 정수를 포함하는 sub array를 만들 때, 배열의 길이를 구하라.

### 입력
```
Input: nums = [1,2,2,3,1]
```

### 출력
```
Output: 2
```
### 설명
0. 가장 많이 등장하는 정수는 `1`과 `2`다.
1. `1` 혹은 `2`가 모두 포함되는 배열의 sub array를 만들 면 다음과 같다.
```
[1, 2, 2, 3, 1], [1, 2, 2, 3], [2, 2, 3, 1], [1, 2, 2], [2, 2, 3], [2, 2]
```
2. 이 sub array 중 가장 짧은 배열의 길이를 갖는 배열은 `[2, 2]` 이며, 길이는 `2`이므로 `2`를 반환한다.

## 풀이
0. 배열에서 가장 많이 등장하는 값, 그리고 길이 계산을 위한 각 정수의 첫 번째 등장 index가 필요하다. 이를 `unordered_map`으로 관리한다.
1. 배열을 순횐한다.
2. 현재 index의 정수가 배열에서 첫 번째 등장하는 정수라면 `map`에 정수를 key로, value는 index를 넣는다.
3. 첫 번째 등장이 아니라면 등장 횟수 관리 `map`의 횟수를 증가시킨다. 현재 정수가 가장 많이 등장한 정수라면 첫 번째 등장 index 관리 map을 이용하여 현재 index와의 길이를 계산한다. 
4. 등장 횟수가 기존 최고 등장횟수와 동일하다면 가장 낮은 거리가 우선이므로, 현재 정수의 배열 길이와 기존 최대 차수의 배열길이를 비교 후 최소값을 택한다.

## 코드
```
class Solution {
public:
    int findShortestSubArray(vector<int>& nums) {
        unordered_map<int, int> first_index_map;
        unordered_map<int, int> count_index_map;

        int max_degree = 0;
        int ret = 0;
        for (int i = 0; i < nums.size(); i++) {
            // Store element's index in case of this element comes first time.
            if (first_index_map.count(nums[i]) == 0) {
                first_index_map[nums[i]] = i; 
            }
            // Otherwise, count element
            count_index_map[nums[i]]++;
            // if this element is max_degree ?
            if (count_index_map[nums[i]] > max_degree) {
                max_degree = count_index_map[nums[i]];
                ret = i - first_index_map[nums[i]] + 1;
            }
            else if (count_index_map[nums[i]] == max_degree) {
                // if degresses are same. Takes minimum space.
                ret = min(ret, i - first_index_map[nums[i]] + 1);
            }
        }
        return ret;
    }
};
```

