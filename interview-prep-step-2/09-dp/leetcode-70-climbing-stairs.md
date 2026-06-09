# [LeetCode 70. 爬楼梯 (Climbing Stairs)](https://leetcode.com/problems/climbing-stairs/)

> 难度：Easy　|　标签：动态规划、数学　|　**DP 入门第一题 ⭐⭐⭐**

---

## 一、题目

假设你正在爬楼梯。需要 `n` 阶你才能到达楼顶。

每次你可以爬 `1` 或 `2` 个台阶。你有多少种不同的方法可以爬到楼顶呢？

**约束**

- `1 <= n <= 45`

**示例**

| 输入 | 输出 | 解释 |
|---|---|---|
| `n = 2` | `2` | 1+1 / 2 |
| `n = 3` | `3` | 1+1+1 / 1+2 / 2+1 |
| `n = 4` | `5` | 1+1+1+1 / 1+1+2 / 1+2+1 / 2+1+1 / 2+2 |

---

## 二、解题思路（学习重点）

### 1. 经典 DP / Fibonacci

`dp[i]` = 到第 i 阶的方法数。

转移：
$$dp[i] = dp[i-1] + dp[i-2]$$

含义：到第 i 阶 = 从第 i-1 阶迈 1 步 + 从第 i-2 阶迈 2 步。

边界：`dp[1] = 1, dp[2] = 2`。

这正是 **Fibonacci 数列**（错位 1 位）。

> **学习点 ①**：**"求方案数"** 类题型，状态转移通常是 **多种来源的累加**（求最值时是 max/min）。

### 2. O(1) 空间优化

`dp[i]` 只依赖 `dp[i-1]` 和 `dp[i-2]`，两个变量足够。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 边界 `n=1` 或 `n=2` 直接套公式爆下标 | 单独处理或合理初始化 |
| 用递归不缓存 → O(2^n) TLE | 用 dp 或 memo |
| 用 long 防 n 过大 | n ≤ 45，int 够 |

---

## 三、详细解题步骤（O(1) 空间）

**步骤 1**：边界
```java
if (n <= 2) return n;
```

**步骤 2**：滚动两个变量
```java
int prev2 = 1, prev1 = 2;
for (int i = 3; i <= n; i++) {
    int cur = prev1 + prev2;
    prev2 = prev1;
    prev1 = cur;
}
return prev1;
```

---

## 四、Java 题解

### 解法 A：O(1) 空间（推荐）

```java
class Solution {
    public int climbStairs(int n) {
        if (n <= 2) return n;
        int prev2 = 1, prev1 = 2;
        for (int i = 3; i <= n; i++) {
            int cur = prev1 + prev2;
            prev2 = prev1;
            prev1 = cur;
        }
        return prev1;
    }
}
```

### 解法 B：DP 数组（直观）

```java
class Solution {
    public int climbStairs(int n) {
        if (n <= 2) return n;
        int[] dp = new int[n + 1];
        dp[1] = 1; dp[2] = 2;
        for (int i = 3; i <= n; i++) dp[i] = dp[i-1] + dp[i-2];
        return dp[n];
    }
}
```

**记忆口诀**：
> **"dp[i] = dp[i-1] + dp[i-2]，Fibonacci 错位 1。"**

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| O(1) 空间 | **O(n)** | **O(1)** |
| DP 数组 | O(n) | O(n) |
| 矩阵快速幂 | O(log n) | O(1) |

---

## 六、示例验证

`n = 4`

| i | prev2 | prev1 | cur |
|---|---|---|---|
| init | 1 | 2 | — |
| 3 | 1 | 2 | 3 |
| 4 | 2 | 3 | **5** |

输出 `5` ✅

---

## 七、复盘与延伸

### 一句话总结
> **每阶只来自前 1 或前 2 → dp[i] = dp[i-1] + dp[i-2]，本质 Fibonacci。**

### 新手常见疑问（FAQ）

**Q1：为什么是相加而不是 max？**
A：求 **方案数**，方案之间互斥，累加；求最值才用 max/min。

**Q2：可以爬 1、2、3 阶呢？**
A：`dp[i] = dp[i-1] + dp[i-2] + dp[i-3]`，泰波那契。

**Q3：n = 45 时 dp 多大？**
A：Fibonacci(45) ≈ 1.13e9，int 够。n > 47 需要 long。

**Q4：递归怎么写？**
A：`f(n) = f(n-1) + f(n-2)`，但必须加 memo 缓存，否则 O(2^n)。

**Q5：能否 O(log n)？**
A：能，矩阵快速幂：`[[1,1],[1,0]]^n`。代码长，面试少考。

### 面试官常见 follow-up
1. **"每次能爬 1, 2, ..., m 阶？"** → `dp[i] = sum(dp[i-j], j=1..m)`，可用前缀和优化。
2. **"用最少步数到达？"** → 这就不是方案数了，是 BFS / DP min。
3. **"有些台阶有 cost（LC 746）？"** → `dp[i] = min(dp[i-1], dp[i-2]) + cost[i]`。
4. **"返回所有具体路径？"** → 回溯，O(2^n) 输出。
5. **"循环楼梯（绕一圈回起点）？"** → 拆首尾两种情况。类 LC 213 打家劫舍 II。
6. **"O(log n) 实现？"** → 矩阵快速幂；或 Binet 公式（浮点精度风险）。

### 同类型推荐（**线性 DP / Fibonacci 家族**）
- LC 746. 使用最小花费爬楼梯
- LC 198. 打家劫舍（同模板）
- LC 213. 打家劫舍 II（环形）
- LC 91. 解码方法
- LC 509. 斐波那契数
- LC 1137. 第 N 个泰波那契数
