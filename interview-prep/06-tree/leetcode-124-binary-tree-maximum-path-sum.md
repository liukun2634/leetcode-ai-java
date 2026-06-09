# [LeetCode 124. 二叉树中的最大路径和 (Binary Tree Maximum Path Sum)](https://leetcode.com/problems/binary-tree-maximum-path-sum/)

> 难度：Hard　|　标签：树、DFS、动态规划　|	|	**树形 DP 天花板 ⭐⭐⭐⭐**

---

## 一、题目

二叉树中的 **路径** 被定义为一条从树中任意节点出发，沿父节点 - 子节点连接，达到任意节点的序列。同一个节点在一条路径序列中 **至多出现一次**。该路径 **至少包含一个节点**，且 **不一定** 经过根节点。

**路径和** 是路径中各节点值的总和。

给你一个二叉树的根节点 `root`，返回其 **最大路径和**。

**约束**

- 节点数 `[1, 3 * 10^4]`
- `-1000 <= Node.val <= 1000`

**示例**

```
输入：    1
        / \
       2   3
输出：6（路径 2 → 1 → 3）

输入：    -10
        /   \
       9    20
            / \
           15  7
输出：42（路径 15 → 20 → 7）
```

---

## 二、解题思路（学习重点）

### 1. 关键区分：**"贡献值"** vs **"路径和"**

- **路径和**：可以"拐弯"，如 `15 → 20 → 7` 在 20 处拐弯。
- **贡献值**：**从某节点向上传递给父节点时**，只能选 **左 或 右** 一支（不能既走左又走右，否则父节点没法接）。

**所以一个节点的 DFS 函数返回的是"贡献值"，而"路径和"作为副产物在每个节点更新全局答案**。

> **学习点 ①**：**"返回值 vs 全局答案"** 是树形 DP 的灵魂。
> 函数 **返回什么给父亲用**，**在自己这里更新什么全局指标**，要分得很清楚。

### 2. 状态定义

对每个节点 `node` 定义：
- `gain(node)` = "**从 `node` 出发、向下走单条路径** 的最大节点和"
- 全局 `maxSum` = "经过任意节点（含 node 本身）的最大路径和"

### 3. 递推

```text
gain(node):
    if node == null: return 0
    leftGain  = max(gain(node.left),  0)    // 负贡献直接丢
    rightGain = max(gain(node.right), 0)
    // 经过 node 的最大路径 = 左 + node + 右
    maxSum = max(maxSum, node.val + leftGain + rightGain)
    // 返回给父亲：只能选一支
    return node.val + max(leftGain, rightGain)
```

**两个 `max(..., 0)` 是关键**：如果子树贡献为负，直接 **丢掉那条支路**（不走）。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| `maxSum` 初始 0 → 全负树会错 | 初始化 `Integer.MIN_VALUE` |
| 返回时把"左+右+node"返回给父亲 → 父亲拼成 X 形不合法 | 返回时**只能选一支** |
| 漏掉 `max(gain, 0)` → 节点值为负的子树拖累答案 | 必须裁掉负贡献 |

---

## 三、详细解题步骤

**步骤 1**：声明全局变量（或用单元素数组）
```java
private int maxSum = Integer.MIN_VALUE;
```

**步骤 2**：写 DFS 函数 `gain(node)`：
  1. **递归出口**：`if (node == null) return 0;`
  2. **递归左右**：
     ```java
     int left  = Math.max(gain(node.left),  0);
     int right = Math.max(gain(node.right), 0);
     ```
  3. **在 node 这里更新全局答案**（这是"路径在 node 拐弯"的情形）：
     ```java
     maxSum = Math.max(maxSum, node.val + left + right);
     ```
  4. **返回给父亲的贡献值**（只能选一支）：
     ```java
     return node.val + Math.max(left, right);
     ```

**步骤 3**：主函数
```java
public int maxPathSum(TreeNode root) {
    gain(root);
    return maxSum;
}
```

---

## 四、Java 题解

```java
class Solution {
    private int maxSum = Integer.MIN_VALUE;

    public int maxPathSum(TreeNode root) {
        gain(root);
        return maxSum;
    }

    private int gain(TreeNode node) {
        if (node == null) return 0;
        int left  = Math.max(gain(node.left),  0);
        int right = Math.max(gain(node.right), 0);
        maxSum = Math.max(maxSum, node.val + left + right);  // 拐弯路径
        return node.val + Math.max(left, right);             // 只能选一支
    }
}
```

**记忆口诀**：
> **"左右取大去负贡，自己加和更新答；返父只能选一支。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n)** |
| 空间 | O(h) 递归栈，h 为树高 |

---

## 六、示例验证

```
       -10
      /   \
     9    20
          / \
         15  7
```

| 节点 | left | right | 经此拐弯和 | maxSum | 返回给父亲 |
|---|---|---|---|---|---|
| 9 | 0 | 0 | 9 | 9 | 9 |
| 15 | 0 | 0 | 15 | 15 | 15 |
| 7 | 0 | 0 | 7 | 15 | 7 |
| 20 | 15 | 7 | 20+15+7=**42** | **42** | 20+15=35 |
| -10 | 9 | 35 | -10+9+35=34 | 42 | -10+35=25 |

输出 `42` ✅

---

## 七、复盘与延伸

### 一句话总结
> **DFS 返回"单边向上的最大贡献"；在每个节点用"左+自己+右"更新全局答案。**

### 新手常见疑问（FAQ）

**Q1：为什么返回时只能选一支？**
A：返回值是“给父节点接上后继续往上走”的贡献。路径不能是 X 形。如果返回左+自己+右，父节点再接一支就“三叉路广场”了。

**Q2：为什么负贡献裁掉 (`max(..., 0)`)？**
A：加进来只会更小。裁掉等于“这一支不走”，路径从 node 自己开始。

**Q3：全负树（如 `[-3]`）怎么办？**
A：`maxSum` 初始 `Integer.MIN_VALUE`。叶子 -3 时 left=right=0，拐弯和 = -3，maxSum 被更为 -3。返回正确。

**Q4：`maxSum` 为什么要全局变量而不是返回值？**
A：返回值被状态 `gain` 占用了（供父节点拼接），不能同时背「路径拐弯和」这个另一状态。双状态 DP 可以返回两个值（`int[2]`），但代码冷。

**Q5：怎么返回具体路径上的节点？**
A：更新 maxSum 时同步记 `(leftPath, node, rightPath)`；left/right path 需在递归中同步返回路径与贡献。

### 面试官常见 follow-up
1. **"求二叉树直径（路径节点数最大）？"** → 同模板，返回贡献是边数；全局 max(left+right)。即 **LC 543**。
2. **"最长同值路径（路径上节点值相同）？"** → 同模板加一个“子节点与父同值才能拼接”的条件。即 **LC 687**。
3. **"二叉树偌间里最大金额不互相打劫（LC 337）？"** → 返回双状态 `(偊, 不偊)`，同是树形 DP。
4. **"路径需要从根到叶呢？"** → 递归不需全局变量，直接返回 `node.val + max(left, right)`，在叶子节点报价。
5. **"多叉树怎么改？"** → 对所有孩子贡献取 max；全局更新用“node + 前两大贡献”。
6. **"树节点有 weight、边有 cost，求加权路径和？"** → 加上边的贡献即可，模板不变。

### 同类型推荐（**树形 DP 家族**，全是高频）
- LC 543. 二叉树的直径（返回贡献是"边数"，全局是"两边相加"）
- LC 687. 最长同值路径
- LC 1372. 二叉树中的最长交错路径
- LC 968. 监控二叉树（树形 DP + 状态机）
- LC 337. 打家劫舍 III（"偷 / 不偷"双状态返回）
- LC 110. 平衡二叉树（返回高度，全局判平衡）
- LC 236. 最近公共祖先（递归返回"子树是否含 p/q"）
