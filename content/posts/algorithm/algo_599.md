---
title: "LeetCode 공부 - Distribute Candies"
date: 2023-01-29T15:28:59+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(599) - [Minimum Index Sum of Two Lists](https://leetcode.com/problems/minimum-index-sum-of-two-lists/)

## 문제
문자열 배열 `list1`과 `list2`가 주어진다. 다음과 같은 조건을 갖는 문자열들을 반환하라.
- `list1`, `list2`모두에 존재하는 문자열
- 문자열 중, 가장 낮은 인덱스를 갖는 문자열
- 가장 낮은 index가 양쪽 배열 모두 동일하다면 두 문자열을 배열 형태로 반환.

### 입력
```
list1 = ["Shogun","Tapioca Express","Burger King","KFC"], list2 = ["Piatti","The Grill at Torrey Pines","Hungry Hunter Steakhouse","Shogun"
```

### 출력
```
Output: ["Shogun"]
```

## 풀이
0. 문자열을 `key`로, `index`를 value로 하는 `map`에 `list1`의 문자열들을 삽입한다.
1. `list2`를 순회하면서 각 문자열들이 `map`에 있다면 두 배열 모두에 존재하는 문자열이므로 `priority_queue`에 삽입한다. 삽입할 때 key는 `list1`의 문자열 index + `list2`의 문자열 index 합으로 하며, value는 문자열이다. 정렬 순은 오름차순으로 한다.
2. 조건 중, index의 합이 동일하다면 모두 반환하라고 하였으므로 `priority_queue`를 top부터 pop 하면서, 첫 번째 element와 index가 같다면 반환 배열에 삽입하고, 아니라면 top만 반환한다.

## 코드
```
#include<iostream>
#include<vector>
#include<algorithm>
#include<unordered_map>
#include<queue>

using namespace std;

vector<string> findRestaurant(vector<string>& list1, vector<string>& list2) {
    unordered_map<string, int> mp1;
    priority_queue<pair<int, string>, vector<pair<int,string>>, greater<pair<int,string>>> pq;
    vector<string> ret;
    for (int i = 0; i < list1.size(); i++) {
        mp1.insert(pair<string, int>(list1[i], i));
    }

    for (int i = 0; i < list2.size(); i++) {
        int idx = 0;
        auto found = mp1.find(list2[i]);
        if (found == mp1.end()) {
            continue;
        }
        else {
            pq.push(make_pair(found->second + i, list2[i]));
        }
    }
    auto prev = pq.top();
    while (!pq.empty()) {
        if (pq.top().first == prev.first) {
            ret.push_back(pq.top().second);
            prev = pq.top();
            pq.pop();
        }
        else {
            break;
        }
    }
    return ret;
}
int main() {
    vector<string> list1{
        "happy","sad","good"
    };

    vector<string> list2{
        "sad","happy","good"
    };

    for (string s : findRestaurant(list1, list2)) {
        cout << s;
    }
}
```

