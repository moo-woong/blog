---
title: "LeetCode 공부 - Length of Last Word"
date: 2022-12-04T20:43:20+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(59) - Length of Last Word

## 문제
단어와 공백으로 이루어진 문자열 `s`가 주어진다. 마지막 단어의 철자 개수를 반환하라.

### 입력
```
Input: s = "luffy is still joyboy"
```

### 출력
```
Output: 6
```

## 풀이
1. string `s`는 문자와 공백만으로 이루어져 있으므로, string의 맨 뒷 부분 부터 검사하여 문자를 카운트 후 문자 수를 반환한다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `lengthOfLastWord()`만 보시면 됩니다.
```
#include<iostream>

using namespace std;

int lengthOfLastWord(string s) {
    int count = 0;
    for (int i = s.size() - 1; i >= 0; i--) {
        if (s[i] == ' ') continue;        
        for (int j = i; j >= 0; j--) {
            if (s[j] == ' ')    return count;
            count++;
        }
        return count;
    }
    return count;
}
int main() {
    
    string s = "day";

    cout << lengthOfLastWord(s);
}
```