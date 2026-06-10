# LeetCode 98. 验证二叉搜索树 (Validate Binary Search Tree)

> 难度：Medium　|　标签：树、BST、DFS、递归　|　**BST 性质考查 ⭐⭐⭐**

---

## 一、题目

给你一个二叉树的根节点 `root`，判断其是否是一个 **有效的二叉搜索树（BST）**。

有效 BST 定义：
- 节点的 **左子树只包含 小于 当前节点的数**
- 节点的 **右子树只包含 大于 当前节点的数**
- 所有左子树和右子树自身必须也是 BST

**约束**

- 节点数 `[1, 10^4]`
- `-2^31 <= Node.val <= 2^31 - 1`

**示例**

```
输入：    2          输入：    5
        / \                / \
       1   3              1   4
                             / \
                            3   6
输出：true              输出：false（4 在 5 的右子树却 < 5，且 3 在 5 的右子树却 < 5）
```

题目链接：<https://leetcode.cn/problems/validate-binary-search-tree/>

---

## 二、解题思路（学习重点）

### 1. 常见陷阱：只比较 `node.left.val < node.val < node.right.val` 不够

仅比较直接子节点 → 第二个例子里 `5.left=1, 5.right=4` 不满足"右子树所有节点 > 5"，单纯比较 4>5 不成立但模板假阳；实际上**整棵右子树**的最小值要 > 5。

正确做法是 **递归时传递 (min, max) 上下界**，每个节点必须落在范围内。

### 2. 解法 A：递归 + 上下界

定义 `valid(node, min, max)`：
- `node == null` → true（空树是 BST）
- `node.val <= min || node.val >= max` → false
- 递归 `valid(node.left, min, node.val) && valid(node.right, node.val, max)`

初始调用 `valid(root, MIN_VALUE - 1, MAX_VALUE + 1)`，用 `long` 避免溢出（因为 val 可以是 `Integer.MIN/MAX_VALUE`）。

### 3. 解法 B：中序遍历严格递增

BST 的中序遍历是 **严格递增序列**。中序遍历过程中维护前一个值 `prev`，若 `cur.val <= prev` 则不是 BST。

> **学习点 ①**：BST 题型 = **中序遍历严格递增** 这个性质 + **上下界递归** 两套模板。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 只比较直接子节点 | 必须传递上下界 |
| 用 `int` 当上下界 | `MIN_VALUE-1` 会下溢；用 `long` 或 `Integer` 对象（null 表示无界） |
| 中序遍历用 `<` 还是 `<=` | BST **严格递增**，相等也不行 |
| 空树视为 BST 还是不 BST | 题目说节点数 ≥1，通常空树也算 BST |

---

## 三、详细解题步骤

### 解法 A（推荐）

**步骤 1**：递归函数
```java
private boolean valid(TreeNode node, long min, long max) {
    if (node == null) return true;
    if (node.val <= min || node.val >= max) return false;
    return valid(node.left,  min, node.val)
        && valid(node.right, node.val, max);
}
```

**步骤 2**：调用
```java
return valid(root, Long.MIN_VALUE, Long.MAX_VALUE);
```

---

## 四、Java 题解

### 解法 A：上下界递归

```java
class Solution {
    public boolean isValidBST(TreeNode root) {
        return valid(root, Long.MIN_VALUE, Long.MAX_VALUE);
    }
    private boolean valid(TreeNode node, long min, long max) {
        if (node == null) return true;
        if (node.val <= min || node.val >= max) return false;
        return valid(node.left, min, node.val)
            && valid(node.right, node.val, max);
    }
}
```

### 解法 B：中序遍历（迭代）

```java
class Solution {
    public boolean isValidBST(TreeNode root) {
        Deque<TreeNode> stack = new ArrayDeque<>();
        TreeNode cur = root;
        long prev = Long.MIN_VALUE;
        while (cur != null || !stack.isEmpty()) {
            while (cur != null) {
                stack.push(cur);
                cur = cur.left;
            }
            cur = stack.pop();
            if (cur.val <= prev) return false;
            prev = cur.val;
            cur = cur.right;
        }
        return true;
    }
}
```

**记忆口诀**：
> **"上下界递归，或中序严格递增。"**

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 上下界递归 | **O(n)** | O(h) 递归栈 |
| 中序遍历迭代 | O(n) | O(h) 栈 |

---

## 六、示例验证

```
       5
      / \
     1   4
        / \
       3   6
```

上下界递归：
- valid(5, -∞, +∞)：5 ∈ 范围 ✓
  - valid(1, -∞, 5)：1 ∈ 范围 ✓ → 子均 null ✓
  - valid(4, 5, +∞)：4 ≤ 5 → **false** ✗

返回 `false` ✅

---

## 七、复盘与延伸

### 一句话总结
> **BST 必须满足每个节点处于 (min, max) 上下界内；或等价地，中序遍历严格递增。**

### 新手常见疑问（FAQ）

**Q1：为什么只比较直接子节点不够？**
A：BST 要求 **整棵子树** 满足，比如 `5` 的右子树里如果有节点小于 5，也违反。直接比子节点漏掉子树内部的违规。

**Q2：为什么用 `long` 而不是 `int`？**
A：节点值范围是 `int` 全域。如果 root.val == `Integer.MAX_VALUE`，用 int 当 max 时无法表示"严格大于 max"。用 long 留出空间。

**Q3：相等的节点为什么不算 BST？**
A：题目定义为"严格大/严格小"。LC 700 类题里相等的节点视为允许，需看具体题面。

**Q4：中序遍历版的 `prev` 初始为什么是 `Long.MIN_VALUE`？**
A：第一个节点没有前驱，用 MIN_VALUE 兜底（任何 int 都 > MIN_VALUE）。

**Q5：递归 vs 迭代选哪个？**
A：递归代码短易写，面试默认；迭代避免爆栈，深度大时安全。

### 面试官常见 follow-up
1. **"恢复 BST（LC 99，两个节点被交换）？"** → 中序遍历找两个违反的位置，交换值。
2. **"二叉搜索树的最近公共祖先（[LC 235](https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-search-tree/)）？"** → 利用 BST 性质单边下沉，O(h)。
3. **"将 BST 转化为有序链表？"** → 中序遍历构造。
4. **"BST 的第 K 小元素（[LC 230](https://leetcode.cn/problems/kth-smallest-element-in-a-bst/)）？"** → 中序遍历计数到 k。
5. **"如果节点值可能相等（重复元素）？"** → 看题面定义；标准 BST 一般约定相等放右（或左）。
6. **"分布式 BST 检查？"** → 子树并行递归，最后合并 min/max。

### 同类型推荐（**BST 家族**）
- [LC 235. BST 的最近公共祖先](https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-search-tree/)
- [LC 700. BST 中的搜索](https://leetcode.cn/problems/search-in-a-binary-search-tree/)
- LC 701. BST 中的插入操作
- [LC 450. 删除 BST 中的节点](https://leetcode.cn/problems/delete-node-in-a-bst/)
- LC 99. 恢复二叉搜索树
- [LC 230. BST 中第 K 小的元素](https://leetcode.cn/problems/kth-smallest-element-in-a-bst/)
- [LC 108. 将有序数组转换为 BST](https://leetcode.cn/problems/convert-sorted-array-to-binary-search-tree/)
