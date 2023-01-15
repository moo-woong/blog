---
title: "LeetCode 공부 - Ransom Note"
date: 2023-01-14T20:22:37+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(383) - [Ransom Note](https://leetcode.com/problems/ransom-note/description/)

## 문제
문자열 `ransomNote`와 `magazine` 이 주어진다. `ransomNote`를 이용해 `magazine`의 일부를 구성할 수 있다면 true를, 아니라면 false를 반환하라.

* 구성에 있어서 순서는 상관이 없다.
* `ransomNote`가 `aab` 이고, `magazine`이 `baa`라면, `ransomNote`의 재배열이 `magazine`의 일부이므로 true이다.

### 입력
```
Input: ransomNote = "aa", magazine = "aab"
```

### 출력
```
Output: true
```

## 풀이
0. `ransomNote`를 모두 소비했을 때 `magazine`의 일부일 경우 true를 반환한다.
1. `ransomNote`에 있는 문자가 `magazine`에 없다면 false이다.
2. `ransomNote`의 문자열을 순회하며 각 문자들을 `map`에 `key`로 하고 `value`는 등장 횟수마다 +1 한다.
3. `magazine`의 문자열을 순회하며 각 문자들을 `map`에 `key`로 하고 `value`를 등장횟수 마다 -1 한다.
4. `map`은 `ransomNote`의 모든 문자들을 `magazine`에서 소비했으므로 모든 `key`의 `value`가 0 미만이면 true를 반환하고 그 외에는 false를 반환한다.

## 코드
```
#include<iostream>
#include<unordered_map>

using namespace std;

bool canConstruct(string ransomNote, string magazine) {
    unordered_map<char, int> umap1;

    for (char c : ransomNote) {
        umap1[c]++;
    }

    for (char c : magazine) {
        umap1[c]--;
    }

    for (auto itr : umap1) {
        if (itr.second > 0) {
            return false;
        }
    }
    return true;
}


int main() {
    string s = "aab";
    string t = "baa";

    cout << canConstruct(s, t);
}
```