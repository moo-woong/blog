---
title: "LeetCode 공부 - Intersection of Two Arrays"
date: 2023-01-14T18:01:03+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(349) - [Intersection of Two Arrays](https://leetcode.com/problems/intersection-of-two-arrays/description/)

## 문제
두 정수 배열 `nums1`과 `nums2`가 주어진다. 두 배열에서 공통된 값을 가지는 수의 배열을 반환하라.

* 반환되는 배열의 순서는 상관이 없다.
* 공통된 값은 중복으로 반환하면 안된다.

### 입력
```
Input: nums1 = [4,9,5], nums2 = [9,4,9,8,4]
```

### 출력
```
Output: [9,4]
```

## 풀이
0. `nums1`를 순회하면서 `map`에 삽입한다.
1. `nums2`를 순회하면서 `map`에 이미 값이 있는지 확인한다.
2. 값이 있다면 중복된 값이므로 반환될 배열에 삽입한다. 배열은 중복으로 삽입하면 안되므로 이미 값이 존재한다면 무시한다.

## 코드
```
#include<iostream>
#include<algorithm>
#include<vector>
#include<unordered_map>

using namespace std;

vector<int> intersection(vector<int>& nums1, vector<int>& nums2) {
    unordered_map<int, int> umap;
    vector<int> ret;
    for (int num : nums1) {
        umap[num] = 0;
    }
    for (int num : nums2) {
        if (umap.count(num) > 0 && find(ret.begin(), ret.end(), num) == ret.end()) {
            ret.push_back(num);
        }
    }
    return ret;
}


int main() {
    vector<int> nums1{
        4,9,5
    };
    vector<int> nums2{
        9,4,9,8,4
    };
    for (int num : intersection(nums1, nums2)) {
        cout << num;
    }
}
```