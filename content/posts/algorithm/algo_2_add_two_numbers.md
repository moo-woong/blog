---
title: "LeetCode 공부 - Add Two Numbers"
date: 2022-12-04T22:19:32+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(67) - Add Two Numbers

## 문제
Non-empty 정수 Linked list 두 개가 주어진다. 각 list는 정수의 역방향, 즉 가장 낮은 자리수가 첫 번재 위치한다. 각 리스트의 정수를 더 하여 주어진 리스트와 동일하게 가장 낮은 자리 수의 정수가 먼저 오도록 배치된 LinkList를 반환하라.

### 입력
```
Input: l1 = [2,4,3], l2 = [5,6,4]
```

### 출력
```
Output: [7,0,8]
```

## 풀이
1. 두 리스트를 모두 순회하면서 리스트가 NULL이 아닐 경우, 해당 `val`값을 `sum` 변수에 합한다.
2. carry가 발생할 경우를 고려한다.
3. `head`를 local 변수로 생성하고 `head->next`에 `sum`의 mod 연산 한 값으로 Node를 생성한다.

## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `addTwoNumbers()`만 보시면 됩니다.
```
#include<iostream>
using namespace std;

//Definition for singly-linked list.
struct ListNode {
    int val;
    ListNode *next;
    ListNode() : val(0), next(nullptr) {}
    ListNode(int x) : val(x), next(nullptr) {}
    ListNode(int x, ListNode *next) : val(x), next(next) {}
};

ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
    ListNode head = ListNode(0);
    ListNode* cur = &head;
    int carry = 0;
    while (l1 || l2 || carry) {
        int sum = 0;
        if (l1 != NULL) {
            sum += l1->val;
            l1 = l1->next;
        }
        if (l2 != NULL) {
            sum += l2->val;
            l2 = l2->next;
        }
        sum += carry;
        carry = sum /10;

        cur->next = new ListNode(sum % 10);
        cur = cur->next;
    }
    return head.next;
}
int main() {
    
    ListNode l_00 = ListNode(3);
    ListNode l_01 = ListNode(4, &l_00);
    ListNode l_02 = ListNode(2, &l_01);

    ListNode l_10 = ListNode(4);
    ListNode l_11 = ListNode(6, &l_10);
    ListNode l_12 = ListNode(5, &l_11);

    addTwoNumbers(&l_02, &l_12);
}
```