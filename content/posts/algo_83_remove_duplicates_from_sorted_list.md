---
title: "LeetCode 공부 - Remove Duplicates from Sorted List"
date: 2022-12-08T23:40:46+09:00
draft: true
---
# LeeCode(83) - Remove Duplicates from Sorted List

## 문제
정수를 포함하는 구조체 리스트가 정렬되어 주어진다. 중복된 노드를 제외한 리스트 head를 반환하라

### 입력
```
Input: head = [1,1,2,3,3]
```

### 출력
```
Output: [1,2,3]
```

## 풀이
1. List를 head부터 NULL이 아닐때 까지 순회하면서 현재 노드의 `val`과 다음 노드의 `val`이 같다면, `cur` 노드의 `next`를 `next->next`로 한칸 건너 뛴다. `val`과 같지 않다면 `cur`노드는 다음 노드를 가리킨다.

## 코드
LeetCode에서 바로 실행해서 이번에는 `main`이 없습니다.
```
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* deleteDuplicates(ListNode* head) {
        ListNode* cur = head;
        while(cur) {
            int val = cur->val;
            if(cur->next != NULL && cur->val == cur->next->val) {
                cur->next = cur->next->next;
            } else {
                cur = cur->next;
            }
        }

        return head;
    }
};
```


