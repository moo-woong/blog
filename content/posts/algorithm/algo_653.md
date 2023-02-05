---
title: "LeetCode - Two Sum IV - Input is a BST"
date: 2023-02-05T15:09:52+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm","set"]
---

# LeetCode(653) - [Two Sum IV - Input is a BST](https://leetcode.com/problems/two-sum-iv-input-is-a-bst/)

## 문제
Binary Search Tree의 `root node` 와 정수 `k`가 주어진다.
BST정수 중 두 정수를 조합하여 `k`를 만들 수 있다면 `true`를, 아니라면 `false`를 반환하라.

{{< figure src="/images/algorithm/algo_653.png">}}


### 입력
```
Input: root = [5,3,6,2,4,null,7], k = 9
```

### 출력
```
Output: true
```

## 풀이
0. set은 key의 유일성을 보장하며, 고유한 key 검색 시 O(1)의 시간복잡도를 가진다. k - 특정 노드 값이면, 나머지 값에 대해 검색연산을 수행하여 값을 찾을 수 있다.
1. BST를 순회하면서 각 노드의 숫자들을 set 에 저장한다.
2. set을 순회하면서 `k` - `node->val`의 값이 set에 있다면 true를 아니라면 false를 반환한다.


## 코드
```
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    set<int> st;

    void traverseTree(TreeNode* cur) {
        if (cur->left != NULL) {
            traverseTree(cur->left);
        }
        if (cur->right != NULL) {
            traverseTree(cur->right);
        }
        st.insert(cur->val);
    }
    bool findTarget(TreeNode* root, int k) {
        traverseTree(root);
        if (st.size() == 1)    return false;

        int diff = 0;
        for (int itr : st) {
            if (itr > (k /2 )) {
                return false;
            }
            
            diff = k - itr;
            auto found = st.find(diff);

            if (found == st.end())  {
                continue;
            }
            if (*found != itr) {
                return true;
            }
        }
        return false;
    }
};
```