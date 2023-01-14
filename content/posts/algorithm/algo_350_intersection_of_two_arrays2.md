---
title: "LeetCode 공부 - Intersection of Two Arrays II"
date: 2023-01-14T18:48:45+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(349) - [Intersection of Two Arrays II](https://leetcode.com/problems/intersection-of-two-arrays-ii/)

## 문제
두 정수 배열 `nums1`과 `nums2`가 주어진다. 두 배열에서 공통된 값을 가지는 수의 배열을 반환하라.

* 반환되는 배열의 순서는 상관이 없다.
* 겹치는 값이 여러번이라면, 겹치는 횟수만큼 반환한다.

### 입력
```
Input: nums1 = [1,2,2,1], nums2 = [2,2]
```

### 출력
```
Output: [2,2]
```
* `nums1`에 2 가 두번 존재하고, `nums2`에도 2가 두 번존재하므로, [2,2]로 반환한다.
* 만약 `nums1`에 2가 한 번 등장한다면, 반환은 [2] 이다.

## 풀이
0. `nums1`를 순회하면서 map에 삽입한다. 이미 값이 있다면 +1을 증가한다.
1. `nums2`를 순회하면서 map에 이미 값이 있는지 확인한다. 
2. 값이 있다면 등장횟수(value)를 -1 하고, 중복된 값이므로 반환될 배열에 삽입한다. 
3. key가 있더라도 등장횟수(value)가 0이면 이미 중복처리를 한것이므로 무시한다.

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
        umap[num]++;
    }
    for (int num : nums2) {
        if (umap[num] > 0) {
            ret.push_back(num);
            umap[num]--;
        }
    }
    return ret;
}


int main() {
    vector<int> nums1{
        1,2,2,1
    };
    vector<int> nums2{
        2,2
    };
    for (int num : intersection(nums1, nums2)) {
        cout << num;
    }
}
```