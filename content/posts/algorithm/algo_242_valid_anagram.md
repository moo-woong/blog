---
title: "Leetcode 공부 - Valid Anagram"
date: 2023-01-14T00:06:19+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(242) - [Valid Anagram](https://leetcode.com/problems/valid-anagram/)

## 문제
문자열 `s`와 `t`가 주어진다. 두 문자열이 Anagram인지 판단하여 Anagram이면 true를, 아니라면 false를 반환하라.


### 입력
```
Input: s = "anagram", t = "nagaram"
```

### 출력
```
Output: true
```

## 풀이
0. `s`와 `t`를 정렬하고, 문자열만큼의 길이를 순회하면서 해당 index에 `s`와  `t`가 다르다면 false를 반환한다.
1. 문자열 순회가 끝나면 true를 반환한다.

## 코드
```
#include<iostream>
#include<algorithm>

using namespace std;


bool isAnagram(string s, string t) {
    if (s.size() == 0 || t.size() == 0) return false;
    if (s.size() != t.size())   return false;
    sort(s.begin(), s.end());
    sort(t.begin(), t.end());

    for (int i = 0; i < s.size(); i++) {
        if (s[i] != t[i])    return false;
    }
    return true;
}

int main() {
    string s = "anagram";
    string t = "nagaram";
    cout << isAnagram(s, t);
    
}
```

## 코드2
0. 문자를 key로, 문자의 나타난 횟수를 value로 한 `unordered_map`으로 관리한다.
1. `s`와 `t`를 순회하면서 `s`에서 나타난 문자는 +1 카운트를, `t`에서 나타난 문자를 -1로 value를 업데이트 한다.
2. `s`와 `t`의 순회가 끝났을 때, unordered_map에 있는 값이 모두 0이라면 true를 반환하고 아니라면 false를 반환한다.
3. 코드1의 실행속도는 20ms, 코드2의 실행속도는 9ms이다.
```
#include<iostream>
#include<unordered_map>

using namespace std;


bool isAnagram(string s, string t) {
    if (s.size() != t.size())    return false;
    
    unordered_map<char, int> umap;
    
    for (int i = 0; i < s.size(); i++) {
        umap[s[i]]++;
        umap[t[i]]--;
    }
    for (auto position : umap) {
        if (position.second > 0) {
            return false;
        }
    }
    return true;
    
}

int main() {
    string s = "anagram";
    string t = "nagaram";
    cout << isAnagram(s, t);
    
}
```