---
title: "LeetCode 공부 - Missing Nuimber"
date: 2023-01-14T17:24:09+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(268) - [Missing Number](https://leetcode.com/problems/missing-number/description/)

## 문제
`0 ~ n`까지의 수를 가진 배열 `nums`가 주어진다. `nums`는 `n`개의 고유한 수를 가진다. `nums`에서 누락된 유일한 수 를 반환하라.

### 입력
```
Input: nums = [9,6,4,2,3,5,7,0,1]

```

### 출력
```
Output: 8
```
설명: `nums`의 크기는 9이며, 이는 9개의 고유한 수를 가진다. 고유한 수는 [0,9] 사이의 값을 가질 수 있다. 8은 이 배열에서 빠져있는 고유한 수이다.

```
Constraints:

n == nums.length
1 <= n <= 104
0 <= nums[i] <= n
All the numbers of nums are unique.
```

## 풀이
0. 주어진 `nums`를 오름차순으로 정렬한다. 이후 Binary Search를 통해서 빠져있는 수를 찾는다.
1. 0부터 n 까지 고유한 수를 가지므로, 배열의 현재 index와 값이 고유해야한다. 만약 현재 index보다 값이 크다면 index 앞에서 숫자 하나가 빠진것이다.
2. index보다 수가 크다면 pivot mid를 앞쪽으로, 그 외에는 아직 빠진 수가 없으므로 pivot mid를 뒤쪽으로 옮겨서 binary search를 수행한다.

## 코드
```
#include<iostream>
#include<algorithm>
#include<vector>

using namespace std;

int missingNumber(vector<int>& nums) {
    sort(nums.begin(), nums.end());
    
    int start = 0;
    int mid = 0;
    int end = nums.size();

    while (start < end) {
        mid = (start + end) / 2;
        if (nums[mid] > mid) {
            end = mid;
        }
        else {
            start = mid + 1;
        }
    }
    return start;
}

int main() {
    vector<int> nums{
        3,0,1
    };
    cout << missingNumber(nums);
}
```