# LeetCode 51. N 皇后 (N-Queens)

> 难度：Hard　|　标签：回溯、剪枝　|　**回溯剪枝天花板 ⭐⭐⭐⭐**

---

## 一、题目

按照国际象棋的规则，皇后可以攻击与之处在 **同一行、同一列或同一斜线** 上的棋子。

**n 皇后问题** 研究的是如何将 `n` 个皇后放置在 `n×n` 的棋盘上，并且使皇后彼此之间不能相互攻击。

给你一个整数 `n`，返回所有不同的 **n 皇后问题** 的解决方案。每一种解法包含一个不同的 **n 皇后问题** 的棋子放置方案，该方案中 `'Q'` 和 `'.'` 分别代表了皇后和空位。

**约束**

- `1 <= n <= 9`

**示例**

```
输入：n = 4
输出：[
  [".Q..","...Q","Q...","..Q."],
  ["..Q.","Q...","...Q",".Q.."]
]
```

题目链接：<https://leetcode.cn/problems/n-queens/>

---

## 二、解题思路（学习重点）

### 1. 关键洞察：**逐行放置**

n 个皇后，每行恰好一个（不然同行冲突）。
→ 按行枚举每个皇后放在哪一列。

```text
backtrack(row):
    if row == n: 收解
    for col = 0..n-1:
        if (col, 斜对角) 未被占:
            放皇后
            backtrack(row + 1)
            撤销
```

### 2. 冲突检测：**3 个 set 标记列与对角线**

- 列：`cols[col] = true`
- 主对角线（左上→右下）：`(row - col)` 相同 → 用 `diag1[row - col + n]`
- 副对角线（右上→左下）：`(row + col)` 相同 → 用 `diag2[row + col]`

> **学习点 ①**：**对角线编号** —— 主对角线行列差相同；副对角线行列和相同。这是 N 皇后的精髓优化。

### 3. 剪枝

- 列、主对、副对 同时检查
- 任一被占 → 不放，continue

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 主对角线 `row - col` 可能为负 → 数组越界 | 用 `row - col + n` 偏移 |
| 用 String 拼棋盘 → 每行新建 | 用 `char[]` + `new String(arr)` |
| 用 `Set<Integer>` 代替 `boolean[]` | 也对但常数大 |
| 解集排序顺序错 | LeetCode 不强制顺序，按递归自然顺序输出即可 |

---

## 三、详细解题步骤

**步骤 1**：初始化标记数组与结果
```java
boolean[] cols = new boolean[n];
boolean[] diag1 = new boolean[2 * n - 1];     // row - col + n - 1（或 +n 也行）
boolean[] diag2 = new boolean[2 * n - 1];     // row + col
int[] queens = new int[n];                     // queens[r] = c
List<List<String>> ans = new ArrayList<>();
```

**步骤 2**：回溯
```java
backtrack(0, n, queens, cols, diag1, diag2, ans);
```

**步骤 3**：回溯函数
```java
private void backtrack(int row, int n, int[] queens,
                       boolean[] cols, boolean[] diag1, boolean[] diag2,
                       List<List<String>> ans) {
    if (row == n) {
        ans.add(buildBoard(queens, n));
        return;
    }
    for (int col = 0; col < n; col++) {
        int d1 = row - col + n - 1;
        int d2 = row + col;
        if (cols[col] || diag1[d1] || diag2[d2]) continue;
        queens[row] = col;
        cols[col] = diag1[d1] = diag2[d2] = true;
        backtrack(row + 1, n, queens, cols, diag1, diag2, ans);
        cols[col] = diag1[d1] = diag2[d2] = false;
    }
}
```

**步骤 4**：构造输出棋盘
```java
private List<String> buildBoard(int[] queens, int n) {
    List<String> board = new ArrayList<>();
    for (int r = 0; r < n; r++) {
        char[] row = new char[n];
        Arrays.fill(row, '.');
        row[queens[r]] = 'Q';
        board.add(new String(row));
    }
    return board;
}
```

---

## 四、Java 题解

```java
class Solution {
    public List<List<String>> solveNQueens(int n) {
        boolean[] cols = new boolean[n];
        boolean[] diag1 = new boolean[2 * n - 1];
        boolean[] diag2 = new boolean[2 * n - 1];
        int[] queens = new int[n];
        List<List<String>> ans = new ArrayList<>();
        backtrack(0, n, queens, cols, diag1, diag2, ans);
        return ans;
    }
    private void backtrack(int row, int n, int[] queens,
                           boolean[] cols, boolean[] diag1, boolean[] diag2,
                           List<List<String>> ans) {
        if (row == n) {
            ans.add(buildBoard(queens, n));
            return;
        }
        for (int col = 0; col < n; col++) {
            int d1 = row - col + n - 1;
            int d2 = row + col;
            if (cols[col] || diag1[d1] || diag2[d2]) continue;
            queens[row] = col;
            cols[col] = diag1[d1] = diag2[d2] = true;
            backtrack(row + 1, n, queens, cols, diag1, diag2, ans);
            cols[col] = diag1[d1] = diag2[d2] = false;
        }
    }
    private List<String> buildBoard(int[] queens, int n) {
        List<String> board = new ArrayList<>();
        for (int r = 0; r < n; r++) {
            char[] row = new char[n];
            Arrays.fill(row, '.');
            row[queens[r]] = 'Q';
            board.add(new String(row));
        }
        return board;
    }
}
```

**记忆口诀**：
> **"逐行放，列 + 两对角线标记；冲突跳，到底收。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n!)** —— 每行选列时实际可选数随深度减少 |
| 空间 | O(n) 递归栈 + O(n) 标记数组 |

---

## 六、示例验证

`n = 4`，简化流程（找到一个解）：

```
row 0: 试 col 0 → 占 (0,0)
  row 1: 试 col 0 ✗ col 1 ✗(对角) col 2 ✓ → 占 (1,2)
    row 2: col 0 ✗(对角(2-0+3)=5? wait...) 实际 col 0 ✗ 1 ✗ 2 ✗ 3 ✗ → 回溯
  row 1: 试 col 3 → 占 (1,3)
    row 2: col 1 ✓ → 占 (2,1)
      row 3: col 0 ✗(对角) 1 ✗(同列) 2 ✗ 3 ✗ → 回溯
    row 2: 继续...
  ...
row 0: col 1 → 占 (0,1)
  ... 最终找到 [.Q.., ...Q, Q..., ..Q.] ✅
```

返回 2 个解 ✅

---

## 七、复盘与延伸

### 一句话总结
> **逐行放皇后；列与两条对角线用 boolean 数组 O(1) 判冲突；回溯时撤销标记。**

### 新手常见疑问（FAQ）

**Q1：主对角线为什么用 `row - col`？**
A：主对角线（从左上到右下）上的格子 row 与 col 同步增长，差 `row - col` 相同。如 (0,0)(1,1)(2,2) 差都是 0。

**Q2：副对角线为什么用 `row + col`？**
A：从右上到左下，row 增 col 减，和不变。如 (0,2)(1,1)(2,0) 和都是 2。

**Q3：`+ n - 1` 是为什么？**
A：`row - col ∈ [-(n-1), n-1]`，加 `n-1` 偏移到 `[0, 2n-2]`，作为数组下标。

**Q4：N 皇后 II（只要数量）有什么不同？**
A：去掉 buildBoard，count++ 替代 ans.add。代码更简洁，可用位运算进一步优化。

**Q5：位运算解法是什么？**
A：用 int 位图代替 boolean[]：lowestBit + Brian Kernighan 技巧极速判可放位置。竞赛常见，面试可作为亮点。

### 面试官常见 follow-up
1. **"N 皇后 II（LC 52，只求数量）？"** → 同思路，count++ 替代构造解。
2. **"位运算优化？"** → 用 int 表示列与两对角线；`int avail = ~(cols | d1 | d2) & ((1<<n)-1)`，循环取最低位。
3. **"输出所有解的对称变换（旋转、镜像）？"** → 找到一个解后枚举 8 种变换。
4. **"n × m 的棋盘（非正方形）？"** → 同思路但 cols 大小是 m；diag 数组大小调整。
5. **"放 k < n 个皇后？"** → 递归出口改为 `placed == k`；可能不要求每行一个。
6. **"皇后允许攻击但限制为 K 步内？"** → 改成 BFS 或图论问题。

### 同类型推荐（**回溯剪枝家族**）
- LC 52. N 皇后 II（计数）
- LC 37. 解数独（多重剪枝）
- LC 22. 括号生成
- LC 79. 单词搜索
- LC 212. 单词搜索 II（Trie + 回溯）
- LC 131. 分割回文串
