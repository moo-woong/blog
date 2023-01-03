---
title: "LeetCode 공부 - Remove Element"
date: 2022-12-04T19:26:04+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeeCode(27) - Remove Element

## 문제
중복이 허용되며, 정렬되지 않은 integer 배열 `nums`와 `val`가 주어진다. `nums`에서 `val`가 제거된 배열을 반환한다. 추가적인 array 할당은 할 수 없으며, `in-place`로 수정한다.

### 입력
```
 nums = [0,1,2,2,3,0,4,2], val = 2
```

### 출력
```
5, nums = [0,1,4,0,3,_,_,_]
```

## 풀이
1. 문제 [26](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)과 유사한 내용이다.
2. 전체 배열을 순회하면서 `val`와 다른 값이라면 `count` index에 현재 값을 저장한다.
3. 정렬되지 않은 값이라고 하더라도, `count` index로 `in-place`에 저장된 값들은 이미 `val`과 비교된 값이므로, 현재 element와 비교만 하면 된다.
4. 문제 [26](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)의 경우 정렬된 값이므로 index를 1 부터 시작했지만 비정렬 배열이므로 0번째 index부터 시작한다.
5. Empty 배열일 경우, NULL을 반환한다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `removeElement()`만 보시면 됩니다.
```
#include<iostream>
#include<vector>

using namespace std;

int removeElement(vector<int>& nums, int val) {
    if (nums.empty())   return NULL;
    
    int count = 0;
    for (int i : nums) {
        if (i != val) {
            nums[count++] = i;
        }
    }
    return count;
}

int main() {
    
    
    vector<int> nums{
        0,1,2,2,3,0,4,2
    };

    int val = 2;

    cout << removeElement(nums, val);
}
```