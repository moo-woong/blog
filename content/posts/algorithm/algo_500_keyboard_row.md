---
title: "LeetCode 공부 - Keyboard Row"
date: 2023-01-23T00:27:27+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(500) - [Keyboard Row](https://leetcode.com/problems/keyboard-row/description/)

## 문제
`string` 문자열들의 배열인 `words`가 주어진다. 일반적인 키보드 배열은 알파벳을 세 줄로 나눌 수 있다. `qqwertyuiop`가 가장 첫 번째 줄, `asdfghjkl`가 두 번째 줄 마지막으로 `zxcvbnm`가 세 번재 줄이다. `words`를 구성하는 `word`가, 키보드를 구성하는 세 줄 중 하나의 라인에서 다 완성이 된다면 배열에 삽입하여 해당 배열을 반환하라.

{{< figure src="/images/algorithm/algo_500.png">}}


### 입력
```
Input: words = ["Hello","Alaska","Dad","Peace"]
```

### 출력
```
Output: ["Alaska","Dad"]
```

## 풀이
0. 키보드 배치를 세군데로 나누고, 세 개의 `unordered_set`을 만들어서 미리 저장한다.
1. 키보드의 각 알파뱃 대소문자는 고유하므로, `word`를 구성하는 각 `char`하나가 각자 라인에 속해있는지 O(1)로 확인이 가능하다.
2. `words`를 순회하면서 각 문자가 `set`에 속해있지 않다면 flag를 false로 바꾼다.
3. `word`를 모두 순회하였을 때 `unordered_set` 중 flag가 하나라도 true면 반환 배열에 저장한다.

## 코드
```
#include<iostream>
#include<vector>
#include<unordered_set>

using namespace std;

vector<string> findWords(vector<string>& words) {
    unordered_set<char> first;
    unordered_set<char> second;
    unordered_set<char> third;

    string first_char= "qwertyuiopQWERTYUIOP";
    string second_char = "asdfghjklASDFGHJKL";
    string third_char = "zxcvbnmZXCVBNM";

    for (char i : first_char) {
        first.insert(i);
    }
    for (char i : second_char) {
        second.insert(i);
    }
    for (char i : third_char) {
        third.insert(i);
    }

    vector<string> ret;
    for (string word : words) {
        bool f1 = true, f2 = true, f3 = true;
        for (char ch : word) {
            if (f1 == true && first.find(ch) == first.end()) {
                f1 = false;
            }
            if (f2 == true && second.find(ch) == second.end()) {
                f2 = false;
            }
            if (f3 == true && third.find(ch) == third.end()) {
                f3 = false;
            }
            if (!f1 && !f2 && !f3)  break;
        }
        if (f1 || f2 || f3) {
            ret.push_back(word);
        }
    }
    return ret;
}
int main() {
    vector<string> words{
        "Hello","Alaska","Dad","Peace"
    };

    for (string i : findWords(words)) {
        cout << i;
    }
}
```