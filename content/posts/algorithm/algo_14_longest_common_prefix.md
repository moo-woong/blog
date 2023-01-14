---
title: "LeetCode 공부 - Longest Common Prefix"
date: 2022-12-01T22:37:08+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(14) - Longest Common Prefix

## 문제
문자열 배열이 주어진다. 이 문자열 배열에서 문자가 공통인 부분만큼 문자열로 반환하라.

### 입력
```
strs = ["flower","flow","flight"]
```

### 출력
```
"fl"
```

## 풀이
1. 문자열들을 사전순으로 정렬하고, 첫 번째 문자열을 기준으로 비교하여 같은 문자라면 index를 순차적으로 증가시킨다.
2. 문자가 같을 때 까지 증가하다가 다른 문자가 나오면 기존까지 저장한 문자열을 반환한다.

## 코드
```
string longestCommonPrefix(vector<string>& strs) {
    vector<string> s = strs;
    sort(s.begin(), s.end());
    string ret = "";
    string pilot = s.at(0);
    
    for (int i = 0; i < pilot.size(); i++) {
        char c = pilot[i];
        for (int j = 1; j < strs.size(); j++) {
            if (s[j][i] != c) {
                return ret;
            }
        }
        ret.push_back(c);
    }
    return ret;
}
```

## 참고
- `sort()`는 `algorithm` header에 있다.
- `sort()`를 사용하지 않아도 결과는 동일하게 나온다. `sort()`의 이유는 사전순으로 한번 더 정렬하기 때문에 fail case를 빠르게 판단할 수 있다.
- `string`에서 `char` 타입을 넣으려면, `str.push_back(c)`혹은 `str += c `로 가능하다. 
- `vector`에서 index 접근은 `at()`이다. 

