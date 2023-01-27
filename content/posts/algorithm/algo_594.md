---
title: "LeetCode 공부 - Longest Harmonious Subsequence"
date: 2023-01-27T23:37:58+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(594) - [Longest Harmonious Subsequence](https://leetcode.com/problems/longest-harmonious-subsequence/)

## 문제
임의의  `harmonious array`를 정의한다. ` harmonious array`는 배열의 양 끝단의 수가  그 사이의 수보다 1이 더 큰 배열을 말한다. 배열 `nums`가 주어질 때, 해당 배열을가지고 가장 긴 `harmonious array`를 만들었을 때 자리수를 반환하라.

### 입력
```
Input: nums = [1,3,2,2,5,2,3,7]
```

### 출력
```
Output: 5
```
- 배열 `1,3,2,2,5,2,3,7`를 이용하여 `harmonious array` `3,2,2,2,3`을 만들 수 있으므로 5를 반환한다.

## 풀이
0. `map`을 이용하여 각 숫자의 출현 횟수를 카운트 한다.
1. `map`의 첫 번째 `pair`를 가르키는 `prev`변수를 생성하고 `map`을 순회한다.
2. `map`은 `key`를 기준으로 오름차순 정렬하므로, iteration 과 prev의 `key`값을 비교하여 수가 1만큼 차이가 난다면 prev와 iteration의 출현 횟수만큼이 `harmonious array`이므로 해당 값을 반환한다.
3. `harmonious array` 의 조건을 양 끝단만 +1 만큼의 차이가 있다고 생각해서 map으로 풀었으나, `21112112`와 같이 배열이 연속적일 경우도 가능하다. 이 러면 주어진 배열을 정렬하고, shift하는 방향으로 풀 수도 있다.

## 코드
```
#include<iostream>
#include<vector>
#include<algorithm>
#include<map>

using namespace std;

int findLHS(vector<int>& nums) {
    map<int, int> mp;
    for (int i : nums) {
        mp[i]++;
    }
    int ret = 0;
    pair<int, int> prev = *(mp.begin());
    for (auto i : mp) {
        if (i.first == prev.first + 1) {
            if (i.second > 1 && prev.second > 1) {
                ret = max(ret, i.second + prev.second);
            }
            else if (i.second > 1) {
                ret = max(ret, i.second  + 1);
            }
            else if (prev.second > 1) {
                ret = max(ret, prev.second + 1);
            }
            else {
                // i and prev are '1'
                ret = max(ret, 2);
            }
        }
        prev = i;
    }
    return ret;
}
int main() {
    vector<int> nums{
        1,2,1,2,1,2,1
    };

    cout << findLHS(nums);
}
```