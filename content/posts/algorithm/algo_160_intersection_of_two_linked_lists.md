---
title: "LeetCode 공부 - Intersection of Two Linked Lists"
date: 2023-01-10T22:31:16+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(160) - [Intersection of Two Linked Lists](https://leetcode.com/problems/intersection-of-two-linked-lists/description/)

## 문제
두 Linked List의 `headA`, `headB`가 주어진다. 두 List 가 만나는 교차점이 있다면 해당 노드를 반환하고, 두 리스트가 교차하지 않고 평행하다면 `null`을 반환하라.

### 입력
```
Input: intersectVal = 8, listA = [4,1,8,4,5], listB = [5,6,1,8,4,5], skipA = 2, skipB = 3
```
skipA, skipB는 주어지는 값이 아닌 설명을 위한 예시이다.

### 출력
```
Output: Intersected at '8'
```

## 풀이
0. [문제 - Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/) 와 매우 유사하다. unordered_set을 이용해 ListNode의 고유성을 기준으로 교차점이 있는지 판단한다.
1. `headA`를 순회하며 각 Node를 unordered_set에 삽입한다.
2. `headB`를 순회하며 각 Node를 unordered_set에 이미 존재하는지 판단한다. 존재한다면 교차점이 있다고 판단, 해당 노드를 반환한다. 없다면 계속 순회한다.
3. `headB`가 NULL이라면 교차점이 없으므로 NULL을 반환한다.

## 코드
```
class Solution {
public:
    ListNode *getIntersectionNode(ListNode *headA, ListNode *headB) {
        unordered_set<ListNode*> uset;
        while(headA) {
            uset.insert(headA);
            headA = headA->next;
        }
        while(headB) {
            if(uset.find(headB) == uset.end()) {
                uset.insert(headB);
                headB = headB->next;
            } else {
                return *uset.find(headB);
            }
        }
        return NULL;
    }
};
```
