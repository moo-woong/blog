---
title: "LeetCode 공부 - Linked List Cycle"
date: 2023-01-10T14:50:12+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(141) - [Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/)

## 문제
Linked List의 `head`가 주어진다. 주어진 Linked List가 cycle을 갖는지 판단하라.

### 입력
```
head = [3,2,0,-4], pos = 1
```
pos는 주어지는 값이 아니고 설명을 돕기위한 예시입니다..

### 출력
```
Output: true
Explanation: There is a cycle in the linked list, where the tail connects to the 1st node (0-indexed).
```

## 풀이
0. `ListNode`의 포인터는 유니크하므로, 해당 포인터를 set으로 관리하여 중복을 확인한다.
1. `ListNode` 타입의 `unordered_set`을 만든다.
2. `unordered_set`에 현재 `ListNode`의 포인터가 없다면 현재 노드를 `set`에 삽입한다.
3. `head`가 `NULL`일 때 까지 `head = head->next`로 전체 노드를 순회한다.
4. `head`가 `NULL`을 만나면 cycle이 없으므로 false를 반환한다.
5. `unordered_set`에 현재 `head`가 존재한다면 cycle이므로 true를 반환한다.

## 코드
```
class Solution {
public:
    bool hasCycle(ListNode *head) {
        unordered_set<ListNode*> uset;

        while (head) {
            if (uset.count(head)) {
                return true;
            }
            uset.insert(head);
            head = head->next;
        }
        return false;
    }
};
```