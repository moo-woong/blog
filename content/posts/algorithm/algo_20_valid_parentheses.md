---
title: "LeetCode 공부 - Valid Parentheses"
date: 2022-12-01T23:05:08+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeeCode(20) - Valid Parentheses

## 문제
소괄호, 중괄호, 대괄호로 이루어진 문자열이 주어진다. 이 문자열의 괄호들이 알맞은 pair라면 true를, 아니라면 false를 반환한다.


### 입력
```
 s = "()[]{}"
```

### 출력
```
true
```

## 풀이
1. 전형적인 stack문제로, 괄호가 닫힐때 마다 pair를 확인한다.
2. 주어진 문자열의 문자들을 순회하면서 문자가 여는괄호면 stack에 쌓고, 닫는 괄호라면, 현재 stack에서 top()과 pair비교 후 pair라면 pop을, 아니면 false를 리턴한다.


## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `isValid()`만 보시면 됩니다.
```
#include<iostream>
#include<string>
#include<stack>

using namespace std;

bool isValid(string s) {
    stack<char> st;

    for (char c : s) {
        if (c == '(' || c == '{' || c == '[') {
            st.push(c);
        }
        else {
            if (st.empty())   return false;
            if (c == ')' && st.top() == '(') {
                st.pop();
                continue;
            }
            else if (c == '}' && st.top() == '{') {
                st.pop();
                continue;
            }
            else if (c == ']' && st.top() == '[') {
                st.pop();
                continue;
            }
            else {
                return false;
            }
        }
    }
    return st.empty();
}

int main() {
    string s = "()[]{}";

    cout << isValid(s);
}
```

## 참고
- `stack`은 `stack` 헤더에 있다.
- `stack`에서 삽입은 `push()`, 마지막 element 조회는 `top()`, 마지막 element를 pop은 `pop()`을 사용한다.
- 현재 stack이 비어있는 상황에서 순회하는 문자가 닫은 괄호일 때, `top()`을 먼저 하게되면 오류가 발생한다. 닫는 괄호일 때는 `empty()`를 먼저 해주자.
- `Parentheses` 는 괄호라는 의미이다. 나도 오늘 알았다. 