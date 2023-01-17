---
title: "LeetCode 공부 - Next Greater Element I"
date: 2023-01-17T23:29:00+09:00
draft: true
---

# LeetCode(409) - [Next Greater Element I](https://leetcode.com/problems/next-greater-element-i/description/)

## 문제
정수형 배열 `nums1`과 `nums2`가 주어진다. `nums1`은 `nums2`의 부분 집합이다. 따라서, `nums1`에 있는 `i`번째 정수는 `nums2`에 존재한다. 다음의 조건에 맞은 정수를 저장하여 배열을 반환하라.
1. `nums1`의 `i`번째 정수를 `nums2`에서 찾는다.
2. `nums2`에서 찾은 정수 `n`을 `n`의 index에서 부터 배열의 마지막까지, n 보다 큰 값 중 가장 먼저 있는 정수를 찾는다.
3. 반환할 배열 `i`번째 과정 2에서 찾은 수를 담는다. 만약 없다면 -1을 저장한다.


### 입력
```
nums1 = [4,1,2], nums2 = [1,3,4,2]
```

### 출력
```
[-1,3,-1]
```
1. `nums1`의 0 번째 숫자는 4이다. 4는 `nums2`에 2번 째 index이다. 해당 index에서 `nums2`마지막까지, 4보다 큰 값은 없으므로 -1이다.
2. `nums1`의 1 번째 숫자는 1이다. 1은 `nums2`에 0번 째 index이다. 해당 index에서 1보다 큰 값 중 가장 가까이 있는 수는 3이다.
3. ``nums1``의 2 번째 숫자는 2이다. 2는 `nums2`에서 마지막 index로, 배열의 끝까지 2보다 큰 숫자는 없으므로 -1이다.

## 풀이
0. 문제가 참 어렵다. `nums1[i]`의 값 `n`을 `nums2[j]`에서 찾고, `nums2` 마지막까지 `n`보다 큰 값을 찾을때 까지 순회하여 풀 수 있다. 이 경우 O(n*m) 이 된다. `nums1`은 `nums2`의 부분집합이므로 최대 O(n^2)이 될 수 있다.
1. `nums2`를 `현재 인덱스에서 오름차순으로 큰 값들`을 stack으로 저장하고, nums2를 순회하면서 map을 채운다.
2. nums2의 마지막 index부터 시작하며, stack의 top이 현재 index보다 크다면, map에 `현재값:stack의 top 값` 으로 저장하고, 작다면  자신보다 큰 값이 top일 때 까지 pop 하고 현재 값을 push 한다. 이 뜻은 하위 index에서 자신보다 큰 값이 없다는 뜻이다. 
2. map은 이미 완성되어 있으므로 nums1을 순회하면서 map의 value만으로 반환배열을 채운 후 반환한다.

## 코드
```
#include<iostream>
#include<vector>
#include<unordered_map>
#include<stack>

using namespace std;

vector<int> nextGreaterElement(vector<int>& nums1, vector<int>& nums2) {
    stack<int> st;
    vector<int> ret;
    unordered_map<int, int> umap;

    for(int index = nums2.size() -1 ; index >= 0; index--) {
        int val = nums2[index];
        if (st.empty()) {
            umap[val] = -1;
            st.push(val);
        }
        else {
            while (!st.empty() && val > st.top()) {
                st.pop();
            }
            if (st.empty()) {
                st.push(val);
                umap[val] = -1;
            }
            else {
                umap[val] = st.top();
                st.push(val);
            }
        }
    }
    
    for (int num : nums1) {
        ret.push_back(umap.find(num)->second);
    }
    return ret;
}

int main() {
    vector<int> nums1{
        4,1,2
    };
    vector<int> nums2{
        1,3,4,2
    };
    for (int i : nextGreaterElement(nums1, nums2)) {
        cout << i;
    }
}
```