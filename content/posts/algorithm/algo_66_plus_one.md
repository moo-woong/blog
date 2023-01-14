---
title: "LeetCode 공부 - Plus One"
date: 2022-12-04T21:02:51+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(66) - Plus One

## 문제
정수를 표현하는 `vector<int> digits`가 주어진다. digits는 배열로 이루어져 있지만, 정수를 표현한다. 예를들어 [3,2,1] 배열인 경우, 정수 `321`을 나타낸다.
 주어진 `digits`배열에 +1 한 값을 `vector<int>`형태로 반환하라. 

### 입력
```
Input: digits = [4,3,2,1]
```

### 출력
```
Output: [4,3,2,2]
```

## 풀이
1. 맨 마지막 정수 값에 +1을 할 수 있겠으나... carry로 인한 자리수가 변경될 수 있고, 이를 위해서 예외처리가 많아질것 같다.
2. 배열을 정수로 변환하고, 정수를 배열로 변환하도록 한다.
3. ...라고 생각했으나, 자리수가 100자리까지 나오는데 100자리수를 정수형으로 저장할 수 없다.
4. 마지막 자리수 부터 검사하여 carry가 발생한다면 앞자리도 검사, 발생하지 않는다면 +1 후 return 한다.
5. 주어진 `digits`를 모두 순회하였는데도 반환되지 않는다면, 주어진 `digits`가 모두 9로 이루져 carry가 발생한 것이다. 이 경우 맨 앞에 1을 추가하여 return 한다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `plusOne()`만 보시면 됩니다.
```
#include<iostream>
#include<vector>

using namespace std;

vector<int> plusOne(vector<int>& digits) {
    for (int i = digits.size() - 1; i >= 0; i--) {
        if (digits[i] != 9) {
            digits[i] = digits[i] + 1;
            return digits;
        }
        else {
            digits[i] = 0;
        }
    }
    digits.insert(digits.begin(), 1);
    return digits;
}
int main() {
    
    vector<int> digits{
        9,9
    };

    for (auto e : plusOne(digits)) {
        cout << e;
    }
}
```

## 참고
- `vector`에서 맨 앞에 원소를 추가할 때는 `begin()`을 사용하며, `begin()`은 iteration type을 받는다.