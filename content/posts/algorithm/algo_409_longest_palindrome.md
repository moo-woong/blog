---
title: "LeetCode 공부 - Longest Palindrome"
date: 2023-01-16T23:54:27+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(409) - [Longest Palindrome](https://leetcode.com/problems/longest-palindrome/description/)

## 문제
문자열 `s`가 주어진다. 문자열 s의 문자들을 재조합하여 Palidrome을 만들 때 가장 긴 Palidrome의 길이를 반환하라.

### 입력
```
Input: s = "abccccdd"

```

### 출력
```
Output: 7
```
문자열 `abccccdd`를 재조합해서 가장 큰 길이의 Palidrome을 만들면 `dccaccd`이므로, 해당 길이인 7을 반환한다.

## 풀이
0. unordered_map으로 각 문자들의 출현빈도를 카운팅하고, 짝수 수를 구해 Palidrome을 계산한다.
1. 라고 0. 처럼 생각했는데 짝수를 카운팅 후 Palidrome의 길이를 계산하는 방법을 몰라서 Solution을 보고 같이 map을 써서 본 풀이를 적는다(even이면 전체사이즈를, odd가 1 초과일때 +1 해주면 되는거였다).
2. 문자열 `s`를 순회하면서 각 문자들의 출현빈도를 카운팅한다.
3. map을 순회하면서 홀수인 수를 `odd`으로 카운팅한다.
4. `s`의 길이에 `odd`을 빼면, 전체 길이에서 Palindrome의 수를 구할 수 있다. 만약 `odd`가 1 이상이라면, `s`길이에서 `odd`를 빼고, 1을 추가하여, 하나의 문자를 가운데 두고 Palindrome을 만들 수 있으므로, 1을 추가한다. 

## 코드
```
#include<iostream>
#include<unordered_map>

using namespace std;

int longestPalindrome(string s) {
    if (s.size() == 1)   return 1;

    unordered_map<char, int> umap;
    for (int i = 0; i < s.size(); i++) {
        umap[s[i]]++;
    }
    
    int odd = 0;
    for (auto ch : umap) {
        // 문자 출현빈도가 홀수인 경우
        if (ch.second %= 2) {
            odd++;
        }
    }

    if (odd > 1) {
        // 홀수 문자가 1개 초과라면, 홀수문자만큼의 길이를 빼고
        // 하나를 더해서(Palindrome 가운데) Palindrome을 만들 수 있음.
        return s.size() - odd + 1;
    }
    // 홀수 문자가 하나면, 해당 문자를 기준으로 Palindrome을 만들 수 있음
    // 홀수 문자가 없다면, 전체문자길이만큼이 Palindrome을 만들 수 있음(순서만 바뀜)
    return s.size();
}

int main() {
    string s = "abccccdd";
    cout << longestPalindrome(s);
}
```