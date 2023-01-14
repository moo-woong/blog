---
title: "LeetCode 공부 - Merge Two Sorted Lists"
date: 2022-12-01T23:38:10+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeetCode(21) - Merge Two Sorted Lists

## 문제
두 Linked List의 header가 주어진다. 두 리스트를 정렬하여 하나의 리스트로 반환하라.


### 입력
```
list1 = [1,2,4], list2 = [1,3,4]
```

### 출력
```
[1,1,2,3,4,4]
```

## 풀이
1. 두 리스트를 순회하면서 작은값을 취하고, 취한 리스트는 다음 노드로 이동하여 두 리스트가 모두 NULL일 때 까지 순회한다.
2. 두 리스트는 모두 정렬된 상태이므로, 함수 도입부에서 한 리스트가 NULL이라면 다른 리스트를 반환한다.
3. 두 리스트 모두 NULL인 경우가 있어서 헷갈렸는데, `list1`이 NULL일 경우 NULL인 `list2`를 리턴해도 무방했다.
4. header를 리턴해야 하므로 header와 cur 두 pointer를 사용해서 cur로 순회하고 head는 첫 번째 node를 포인트 하도록 한다.


## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다. `mergeTwoLists()`만 보시면 됩니다.
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

ListNode* mergeTwoLists(ListNode* list1, ListNode* list2) {
    if (list1 == NULL)
        return list2;

    if (list2 == NULL)
        return list1;

    // Set a head node
    ListNode* cur = NULL;
    ListNode* head = NULL;
    
    if (list1->val <= list2->val) {
        cur = list1; list1 = list1->next;
    }
    else
    {
        cur = list2;
        list2 = list2->next;
    }
    
    head = cur;
    // Iterate two nodes
    while (list1 != NULL || list2 != NULL) {
        if (list1 != NULL && list2 != NULL) {
            if (list1->val <= list2->val) {
                cur->next = list1;
                list1 = list1->next;
            }
            else {
                cur->next = list2;
                list2 = list2->next;
            }
        }
        else if (list1 == NULL) {
            // Only list2 remains
            cur->next = list2;
            list2 = list2->next;
        }
        else {
            // Only list1 remains
            cur->next = list1;
            list1 = list1->next;
        }
        cur = cur->next;
    }
    return head;
}

int main() {
    ListNode list_12(4);
    ListNode list_11(2, &list_12);
    ListNode list_1(1, &list_11);

    ListNode list_22(4);
    ListNode list_21(3, &list_22);
    ListNode list_2(1, &list_21);
    ListNode* ret = mergeTwoLists(&list_1, &list_2);

    while (ret != NULL) {
        cout << ret->val;
        ret = ret->next;
    }
}
}
```
