---
title: "LeetCode 공부 - Remove Duplicates from Sorted Array"
date: 2022-12-04T19:12:59+09:00
---

# LeeCode(26) - Remove Duplicates from Sorted Array

## 문제
중복이 허용된 integer type의 오름처순 배열에서, 중복된 값들을 제거한 sorted array를 만들고, 중복을 제외한 원소의 개수를 반환하라.


### 입력
```
nums = [0,0,1,1,1,2,2,3,3,4]
```

### 출력
```
5, nums = [0,1,2,3,4,_,_,_,_,_]
```

## 풀이
1. 추가적인 배열을 할당하지 않고, 주어진 `vector<int>`를 수정할 것. 그리고 반환하는 원소의 개수 이후의 `nums` index는 don't care 한다.
2. 주어진 배열을 마사지 해서 반환해야 하므로, 배열을 순회하면서 배열의 값을 바꿔야 한다.
3. 처음 접근은 다음과 같이 진행하였다.
- 전체 배열을 0번 index부터 순회
- 현재 index가 index - 1 과 같다면 현재 index를 `index.size` 까지 shift
4. 3. 처럼 접근했더니 Time Limit Excceded가 났다... 중복이 발생하면 n 만큼 shift해야하므로 n^2 연산이 필요한데, `nums.size`가 100인줄 알았더니 `1 <= nums.length <= 3 * 10^4` 였다.
5. 중복이 아닌 값들만 count 하도록 변경한다.
- 정렬된 배열이므로 index 비교를 위한 count 값은 1부터 시작한다.
- 배열 전체를 순회한다.
- 현재 값이 `index-1` 보다 크다면 `count` index에 현재 값을 저장한다.
- 이후 count 값을 반환한다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `removeDuplicates()`만 보시면 됩니다.
```
#include<iostream>
#include<vector>

using namespace std;

int removeDuplicates(vector<int>& nums) {
    if (nums.empty())   return 1;
    
    int count = 1;
    for (int i : nums) {
        if (i > nums[count - 1]) {
            nums[count++] = i;
        }
    }
    return count;
}

int main() {
    
    
    vector<int> nums{
        0,0,1,1,1,2,2,3,3,4
    };

    cout << removeDuplicates(nums);
}
```