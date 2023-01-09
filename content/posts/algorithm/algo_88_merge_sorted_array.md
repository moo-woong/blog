---
title: "LeetCode 공부 - Merge Sorted Array"
date: 2023-01-07T00:20:44+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeeCode(88) - Merge Sorted Array

## 문제
두 개의 오름차순으로 정렬된 정수형 배열 `nums1`과 `nums2`가 주어진다. 또한 `nums1`의 element의 수를 나타내는 `m`과 `nums2`의 수를 나타내는 `n`이 주어진다. 

두 배열을 병합하여 오른차순으로 정렬된 배열을 반환하라.

*추가적인 배열을 선언하지 않고 nums1에 정렬된 배열을 반환하라.*

### 입력
```
Input: nums1 = [1,2,3,0,0,0], m = 3, nums2 = [2,5,6], n = 3
```

### 출력
```
Output: [1,2,2,3,5,6]
```

## 풀이
1. 하나의 배열을 내부적으로 선언하고, 두 배열의 index들을 하나씩 증가하며 새로 선언한 배열 index에 할당한 다음, 입력받은 두 배열을 모두 순회하면 선언한 배열을 `nums1`이 복사하여 풀 수 있다.
2. 1.의 경우 space complexity가 증가하므로 Memory usage를 감안한 더 좋은 방법을 생각해본다.
3. 정렬된 배열이며, 반환해야 할 `nums1` 배열은 반환될 크기가 이미 할당되어 있다. 따라서 마지막 index를 사용할 수 있다.
4. 마지막 index부터 비교하며 큰 수를 `nums1`의 마지막 index에 저장한다.



## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `merge()`만 보시면 됩니다.
```
#include<iostream>
#include<vector>
using namespace std;

void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
    int num1Point = m - 1; // the index to point last of nums1
    int num2Point = n - 1; // the index to point last of nums2
    int revsPoint = m + n - 1; // the index to point reserve 

    while (num1Point >= 0 && num2Point >= 0) {
        if (nums1[num1Point] > nums2[num2Point]) {
            nums1[revsPoint--] = nums1[num1Point--];
        }
        else {
            nums1[revsPoint--] = nums2[num2Point--];
        }
    }

    // At this point, num2Point is positive, then nums1 array is an empty.
    // nums1 and nums2 are ordered list. Copy nums2 til nums2 is an empty

    while (num2Point >= 0) {
        nums1[revsPoint--] = nums2[num2Point--];
    }
}
int main() {
    
    vector<int> nums1{
        1,2,3,0,0,0
    };
    vector<int> nums2{
        2,5,6
    };
    /*
    vector<int> nums1{
        4,5,6,0,0,0
    };
    vector<int> nums2{
        1,2,3
    };
    */
    merge(nums1, 3, nums2, 3);

    for (int i = 0; i < nums1.size(); i++) {
        cout << nums1[i];
    }
}
```