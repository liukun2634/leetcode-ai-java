# LeetCode 199. 二叉树的右视图 (Binary Tree Right Side View)

> 难度：Medium　|　标签：树、BFS、DFS　|　**层序遍历变种 ⭐⭐⭐**

---

## 一、题目

给定一个二叉树的 **根节点** `root`，想象自己站在它的右侧，按照从顶部到底部的顺序，返回从右侧所能看到的节点值。

**约束**

- 二叉树的节点个数的范围是 `[0, 100]`

**示例**

```
输入：    1            ←   1
        / \              \
       2   3          ←      3
        \   \              \
         5   4          ←      4

输出：[1, 3, 4]
```

题目链接：<https://leetcode.cn/problems/binary-tree-right-side-view/>

---

## 二、解题思路（学习重点）

### 1. 等价于"每层最后一个节点"

从右侧看：每一层只能看到 **最右边那个** 节点。

### 2. 解法 A：BFS + 每层最后一个

复用 LC 102 层序模板，每层取最后一个值（即当 k == size - 1 时收集）。

### 3. 解法 B：DFS 优先右子树 + depth

DFS 顺序为 "右 → 左"，记录每层第一个访问到的节点：
- 用 `depth` 表示当前层
- 如果 `ans.size() == depth`（这一层还没被记录），加入当前节点

> **学习点 ①**：「每层第一个/最后一个」类题型可用两种思路 —— BFS 取层末，或 DFS 调换访问顺序。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| BFS 没快照 size | 一定先 `int size = queue.size();` |
| DFS 默认左到右 → 取的是左视图 | 必须 "右 → 左" 顺序递归 |
| 空树没处理 | 直接返回空 list |

---

## 三、详细解题步骤

### 解法 A：BFS

**步骤 1**：初始化
```java
List<Integer> ans = new ArrayList<>();
if (root == null) return ans;
Deque<TreeNode> queue = new ArrayDeque<>();
queue.offer(root);
```

**步骤 2**：层序循环，收集每层最后一个
```java
while (!queue.isEmpty()) {
    int size = queue.size();
    for (int k = 0; k < size; k++) {
        TreeNode node = queue.poll();
        if (k == size - 1) ans.add(node.val);
        if (node.left  != null) queue.offer(node.left);
        if (node.right != null) queue.offer(node.right);
    }
}
return ans;
```

### 解法 B：DFS（右→左）

```java
public List<Integer> rightSideView(TreeNode root) {
    List<Integer> ans = new ArrayList<>();
    dfs(root, 0, ans);
    return ans;
}
private void dfs(TreeNode node, int depth, List<Integer> ans) {
    if (node == null) return;
    if (ans.size() == depth) ans.add(node.val);  // 这一层第一个访问到的
    dfs(node.right, depth + 1, ans);              // 先右
    dfs(node.left,  depth + 1, ans);
}
```

---

## 四、Java 题解

### 解法 A：BFS（推荐）

```java
class Solution {
    public List<Integer> rightSideView(TreeNode root) {
        List<Integer> ans = new ArrayList<>();
        if (root == null) return ans;
        Deque<TreeNode> queue = new ArrayDeque<>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            int size = queue.size();
            for (int k = 0; k < size; k++) {
                TreeNode node = queue.poll();
                if (k == size - 1) ans.add(node.val);
                if (node.left  != null) queue.offer(node.left);
                if (node.right != null) queue.offer(node.right);
            }
        }
        return ans;
    }
}
```

### 解法 B：DFS

```java
class Solution {
    public List<Integer> rightSideView(TreeNode root) {
        List<Integer> ans = new ArrayList<>();
        dfs(root, 0, ans);
        return ans;
    }
    private void dfs(TreeNode node, int depth, List<Integer> ans) {
        if (node == null) return;
        if (ans.size() == depth) ans.add(node.val);
        dfs(node.right, depth + 1, ans);
        dfs(node.left,  depth + 1, ans);
    }
}
```

**记忆口诀**：
> **"BFS 取层末，或 DFS 先右后左。"**

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| BFS / DFS | **O(n)** | O(n)（队列 / 递归栈） |

---

## 六、示例验证

题目示例（树如上）：

**BFS 流程**：
| 层 | size | 节点 | 收集 |
|---|---|---|---|
| 1 | 1 | 1 | 1 |
| 2 | 2 | 2, 3 | 3 |
| 3 | 2 | 5, 4 | 4 |

输出 `[1, 3, 4]` ✅

---

## 七、复盘与延伸

### 一句话总结
> **每层最右一个：BFS 取 size-1 位置；或 DFS 先右后左，每层第一个进 ans。**

### 新手常见疑问（FAQ）

**Q1：DFS 为什么是 `ans.size() == depth` 而不是 `>`？**
A：每层至多收 1 个；当 ans 大小恰等于当前 depth 时（说明这层还没有），加入。后续同层节点已经满足 `ans.size() > depth` 不再加。

**Q2：DFS 为什么要先右后左？**
A：保证每层 **第一个访问** 到的是最右。如果先左，得到的就是 **左视图**（LC 199 的姊妹题，可顺手做）。

**Q3：右子树为 null 时怎么办？**
A：BFS 自动跳过；DFS 进入 null 立刻 return，不影响。

**Q4：如果树极度向左偏（如全是左孩子）？**
A：每层只有一个节点，那个节点就是右视图。算法仍正确。

**Q5：DFS vs BFS 空间？**
A：BFS 最坏 O(n)（最宽层）；DFS O(h)（树高）。完全二叉树 h=log n，BFS 反而更费内存。

### 面试官常见 follow-up
1. **"左视图怎么改？"** → BFS 取 `k == 0` 那个；DFS 先左后右。
2. **"俯视图 / 仰视图？"** → 需投影到水平坐标，复杂得多。需 DFS + 记录 (col, row)。[LC 314](https://leetcode.cn/problems/binary-tree-vertical-order-traversal/)。
3. **"每层最大值（LC 515）？"** → 同 BFS 模板，每层维护 max。
4. **"每层平均值（[LC 637](https://leetcode.cn/problems/average-of-levels-in-binary-tree/)）？"** → BFS 取层和 / size。
5. **"二叉树的边界（LC 545）？"** → 左视图 + 右视图 + 叶子。
6. **"N 叉树的右视图？"** → BFS 模板里改 `for (TreeNode child : node.children)`。

### 同类型推荐（**层序变种家族**）
- [LC 102. 二叉树的层序遍历](https://leetcode.cn/problems/binary-tree-level-order-traversal/)（基础）
- [LC 107. 二叉树的层序遍历 II](https://leetcode.cn/problems/binary-tree-level-order-traversal-ii/)（自底向上）
- [LC 103. 锯齿形层序遍历](https://leetcode.cn/problems/binary-tree-zigzag-level-order-traversal/)
- LC 515. 每层最大值
- [LC 637. 每层平均值](https://leetcode.cn/problems/average-of-levels-in-binary-tree/)
- LC 545. 二叉树的边界
- [LC 314. 二叉树的垂序遍历](https://leetcode.cn/problems/binary-tree-vertical-order-traversal/)
