---
title: "LeetCode 공부 - Search Insert Position"
date: 2022-12-04T19:44:43+09:00
---

# LeeCode(35) - Search Insert Position

## 문제
중복을 허용하지 않는 정렬된 integer `nums`와 integer type의 `target`이 주어진다. `nums`배열에서 `target`을 발견한다면 `target`이 위치한 index를 반환한다. `target`을 찾지 못하였다면 `target`이 포함될 index를 반환한다. time complexity는 `O(log n)`을 만족해야 한다.

### 입력
```
 Input: nums = [1,3,5,6], target = 7
```

### 출력
```
Output: 4
```

## 풀이
1. `O(log n)` 의 조건이 없다면, 정렬된 배열이므로 for loop으로 한번 배열을 순회하면 답을 찾을 수 있다. 하지만 이 경우 Time complexity는 `O(n)` 이므로 사용할 수 없다.
2. `O(log n)`을 만족하기 위해서는 연산 마다 경우의 수를 절반 씩 줄여야한다.
3. 가장 대표적인 `BST`가 `O(log n)`을 만족하며, 배열 또한 정렬된 상태로 주어지므로 해당 내용을 차용한다.
4. `merge sort` 알고리즘을 차용하여 구현하도록 한다. 
- 탐색해야 하는 배열의 시작, 끝을 `left`, `right`로 정의하여 그 중 가운데 값을 `target`과 비교한다.
- 중간값이 `target`보다 작다면 `left`는 그대로, `right`를 중간값으로 하여 탐색 범위를 반으로 줄인다.
- 중간값이 `target`보다 크다면 `left`는 중간값으로, 끝 값 `right`는 그대로 두어 탐색 범위를 반으로 줄인다.
- 위 과정을 반복하여 찾되, `left`가 `right`값 보다 크거나 같다면 `target`이 없는 경우로, `nums`의 마지막에 `target`이 저장되야한다. 따라서 `right`값을 반환한다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `searchInsert()와 findTarget()`만 보시면 됩니다.
```
#include<iostream>
#include<vector>

using namespace std;

int findTarget(int left, int right, int target, vector<int>& nums) {
    int mid = (left + right) / 2;

    if (left >= right) {
        return right;
    }
    
    if (nums[mid] == target) {
        return mid;
    }
    else if (nums[mid] > target) {
        return findTarget(left, mid, target, nums);
    }
    else {
        return findTarget(mid + 1, right, target, nums);
    }
}

int searchInsert(vector<int>& nums, int target) {
    if (nums.empty())   return 0;
    return findTarget(0, nums.size(), target, nums);
}
int main() {
    
    vector<int> nums{
        1,3,5,6
    };

    int target = 7;

    cout << searchInsert(nums, target);
}
```