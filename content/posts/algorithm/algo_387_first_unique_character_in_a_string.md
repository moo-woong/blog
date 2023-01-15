---
title: "LeetCode 공부 - First Unique Character in a String"
date: 2023-01-15T18:01:29+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(387) - [First Unique Character in a String](https://leetcode.com/problems/first-unique-character-in-a-string/description/)

## 문제
문자열 `s`가 주어진다. 문자열`s`를 구성하는 문자 중, 한번만 등장하는 문자를 찾고, 그 중 가장 낮은 index를 가진 문자의 index를 반환하라.

### 입력
```
Input: s = "loveleetcode"
```

### 출력
```
Output: 2
```
* 문자열 `loveleetcode` 중 중복되지 않은 문자는 `v`,`t`,`c`,`o`, 그리고 `d` 이다. 이 중 가장 낮은 index를 갖는 문자는 `v`이며, index는 2 이므로, 2를 반환한다.

## 풀이
0. 문자를 `key`로 갖고, `<int,int>` 타입의 `pair`를 `value`로 갖는 `map`을 이용한다.
1. 문자가 `map`에 없다면 순회하고 있는 현재 문자를 `key`로, `index`와 문자의 빈도를 나타내는 `count`를 `pair`로 만들어 삽입한다.
2. 문자가 `map`에 있다면 `pair`에서 `count`를 증가시킨다.
3. 문자열을 모두 순회했으면 map을 전체 순회하여 count가 1 인 piar 중 index가 가장 낮은 문자의 index를 찾아 반환한다.

## 코드
```
#include<iostream>
#include<unordered_map>

using namespace std;

int firstUniqChar(string s) {
    unordered_map<char, pair<int, int>> umap;
    for (int i = 0; i < s.size(); i++) {
        auto found = umap.find(s[i]);
        if (found == umap.end()) {
            umap.insert(make_pair(s[i], make_pair(i, 1)));
        }
        else {
            found->second.second++;
        }
    }
    int idx = 1000001;
    for (auto itr : umap) {
        if (itr.second.second == 1) {
            idx = itr.second.first < idx ? itr.second.first: idx;
        }
    }
    return idx == 1000001 ? -1 : idx;
}


int main() {
    string s = "aabb";

    cout << firstUniqChar(s);
}
```