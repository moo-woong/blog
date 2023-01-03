---
title: "LeetCode 공부 - Sqrt(x)"
date: 2022-12-08T01:07:34+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeeCode(69) - Sqrt(x)

## 문제
양의 정수 `x`가 주어질 때, `x`의 제곱근을 반환하라. 반환되는 제곱근은 정수형으로 내림한 값으로 반환하라.

### 입력
```
Input: x = 8
```

### 출력
```
Output: 2
```

## 풀이
1. 주어진 양의정수에 대해 양의 제곱근을 반환하는 문제다.
2. 정밀하게 구하는 방식은 뉴튼-랩슨법을 써서 많은 연산을 통해 정확도를 높이지만, 문제는 정수를 반환하는 문제다.
3. 주어지는 `x`가 매우 큰 값일 경우 1씩 더해서 제곱근을 찾기에는 많은 연산을 필요로 한다.
4. 찾는 제곱근은 양의 제곱근이므로, 1부터 시작해서 `x`까지 연산해야한다. 정렬되어 있다고 볼 수 있으므로 이진탐색트리를 이용하여 `O(n long n)`으로 접근한다.
5. 큰 값이 있을 경우 `left` + `right`가 overflow가 발생할 수 있으므로 `long long`타입을 사용했다.
6. 다른 사람들의 풀이를 보니 중간값을 구할 때 오버플로우를 없애기 위해 다음과 같이 사용했다.
- overflow 발생하는 경우
```
int mid = (left + right) /2;
```
- overflow 없애는 방법
```
int mid = left + (right - left) / 2;
```

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `mySqrt()`만 보시면 됩니다.
```
#include<iostream>
#include<string>
using namespace std;

int mySqrt(int x) {
    if (x == 1) return 1;
    long long left = 1;
    long long right = x;
    while (left <= right) {
        long long mid = (left + right) / 2;
        if (mid == x/mid) {
            return mid;
        }
        else if (mid < x/mid) {
            left = mid + 1;
        }
        else {
            right = mid - 1;
        }
    }
    return right;
}
int main() {

    int val = 2147483647;
    
    cout << mySqrt(val);
}
```

