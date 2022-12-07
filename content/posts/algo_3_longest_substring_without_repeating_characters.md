---
title: "LeetCode 공부 - Longest Substring Without Repeating Characters"
date: 2022-12-05T00:01:19+09:00
---

# LeeCode(3) - Longest Substring Without Repeating Characters

## 문제
문자열 `s`가 주어질 때, 이 문자열에서 반복되지 않은 문자를 갖는 substring의 길이를 반환하라.

### 입력
```
Input: s = "abcabcbb"
```

### 출력
```
Output: 3
```

## 풀이
1. 문제 설명은 간단한데 이해가 잘 안된다. 풀어서 써보자면, 문자열 중에서 중복되지 않은 문자들의 최대 길이를 구하는 문제다. 예를들어, 문자열 `s = "abcdea"`가 있다면, `abcde` 까지 중복되지 않은 문자열이므로 결과 값은 5 이다. `s = "abcdeafg"` 라고 하면, 두 번째 index 부터인 `"bcdeafg"`에는 중복이 없으므로 이 때 반환값은 문자열 길이 7 이다. 여기서 포인트는 중복된 값이 나오면 좌측 index를 shift 하여 중복을 제외하고 계속 최대값을 유지하는 것이다.
2. 중복이 없으니 중복을 지원하지 않는 `set`을 사용하여 문자열에서 문자를 하나씩 검사하는 forward pointer와 중복 시 skip 하는 back pointer 두개를 사용하여 최대값을 구한다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `lengthOfLongestSubstring()`만 보시면 됩니다.
```
#include<iostream>
#include<algorithm>
#include<unordered_set>
using namespace std;

int lengthOfLongestSubstring(string s) {
    if (s.empty()) return 0;
    if (s.size() == 1)  return 1;
    int back = 0, front = 0;
    unordered_set<char> uset;

    int ret = 0;
    while (back < s.size() && front < s.size()) {
        if (uset.find(s[front]) == uset.end()) {
            // unordered_set에 front가 가르키는 char 가 없는 경우
            uset.insert(s[front++]);
            // 최대길이는 front index - back index이며, 중복인 경우 back이 증가되어 최대 길이가 줄어듦.
            ret = max(ret, front - back);
        }
        else {
            uset.erase(s[back++]);
        }
    }
    return ret;
}
int main() {
    
    string s = "au";
    cout << lengthOfLongestSubstring(s);
}
}
```

## 참고
- `max()`는 `algorhtihm` 헤더에 있다.
- `unodered_set`의 `find()`는 key 가 없을 시 `end()`를 반환한다.