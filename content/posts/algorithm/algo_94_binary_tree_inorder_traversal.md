---
title: "LeetCode 공부 - Binary Tree Inorder Traversal"
date: 2023-01-09T22:20:19+09:00
categories: ["Algorithm"]
tags: ["LeetCode","Algorithm"]
---

# LeeCode(94) - Binary Tree Inorder Traversal

## 문제
Binary Tree의 `root`가 주어진다. Inorder Traversal(중위순회)를 한 결과를 반환하라.

### 입력
```
root = [1,null,2,3]
```
{{< figure src="/images/algorithm/algo_94_1.png">}}

### 출력
```
[1,3,2]
```

## 풀이
1. 주어진 Binary Tree의 `root`에서 중위순회한다.
2. Inorder traversal은 Bianry Tree에서 좌측 노드를 먼저 순회 후, 자기 자신, 그리고 우측 노드를 탐색하는 방법이다.
3. 주어진 입력에서 `root`노드는 1, 좌측 노드는 없으므로 자기 자신 1이 먼저 출력되고, 우측 노드로 이동 한다.
4. 우측노드에서는 좌측노드로 이동, 마찬가지고 좌/우 노드가 없으므로 자기 자신이 출력된다.
5. 이를 반복한다.
6. 재귀함수를 통해서 좌측 노드를 검사 후 자기 자신을 반환 리스트에 삽입, 우측 노드순회를 진행한다.



## 코드
Visual studio에서 바로 실행하도록 임의의 main문을 함께 첨부합니다.
```
#include<iostream>
#include<vector>

using namespace std;

// Definition for a binary tree node.
struct TreeNode {
    int val;
    TreeNode *left;
    TreeNode *right;
    TreeNode() : val(0), left(nullptr), right(nullptr) {}
    TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
    TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
};

    
void inorderTraversal(vector<int>& ret, TreeNode* node) {
    
    if (node->left != NULL) {
        inorderTraversal(ret, node->left);
    }
    ret.push_back(node->val);
    if (node->right != NULL) {
        inorderTraversal(ret, node->right);
    }
}

vector<int> inorderTraversal(TreeNode* root) {
    vector<int> ret;
    if (root == NULL)   return ret;
    inorderTraversal(ret, root);
    return ret;
}
int main() {
    
    TreeNode one(1);
    TreeNode two(2);
    TreeNode three(3);

    one.right = &two;
    two.left = &three;

    vector<int> ans = inorderTraversal(&one);

    for (auto itr = ans.begin(); itr != ans.end(); itr++) {
        cout << *itr;
    }
    
}
```