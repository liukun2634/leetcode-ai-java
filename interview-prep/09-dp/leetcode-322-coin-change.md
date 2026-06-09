# [LeetCode 322. 零钱兑换 (Coin Change)](https://leetcode.com/problems/coin-change/)

> 难度：Medium　|　标签：动态规划、完全背包　|　**DP 必刷 ⭐⭐⭐**

---

## 一、题目

给你一个整数数组 `coins`（表示不同面额的硬币）和一个整数 `amount`（表示总金额）。

计算并返回可以凑成总金额所需的 **最少的硬币个数**。如果没有任何一种硬币组合能组成总金额，返回 `-1`。

你可以认为每种硬币的数量是 **无限** 的。

**约束**

- `1 <= coins.length <= 12`，`1 <= coins[i] <= 2^31 - 1`
- `0 <= amount <= 10^4`

**示例**

| 输入 | 输出 | 解释 |
|---|---|---|
| `coins=[1,2,5], amount=11` | `3` | 11 = 5+5+1 |
| `coins=[2], amount=3` | `-1` | 无法凑出 |
| `coins=[1], amount=0` | `0` | 不需要硬币 |

---

## 二、解题思路（学习重点）

### 1. 为什么不能贪心？

第一反应可能是"每次选最大的硬币"，但这对 `coins=[1,3,4], amount=6` 失败：
- 贪心：`4 + 1 + 1 = 3` 枚
- 最优：`3 + 3 = 2` 枚

> **学习点 ①**：**硬币面额不能整除时贪心失效**，必须 DP。

### 2. DP 状态定义

`dp[i]` = **凑出金额 `i` 所需的最少硬币数**；不可凑 = `+∞`。

边界：`dp[0] = 0`（金额 0 不需硬币）。

转移：对每个金额 `i`，枚举每种硬币 `c`：
$$dp[i] = \min(dp[i],\; dp[i - c] + 1) \quad \text{若 } i \geq c$$

含义：从 `dp[i-c]` 加一枚 `c` 转移过来。

### 3. 这是 **完全背包 + 求最值** 的模板

- 背包容量：amount
- 物品：每种硬币（无限个）
- 求：恰好装满的最少物品数

外层 **金额**、内层 **硬币** 的循环（也可反过来），求最少所以两层 `for` 都是正向。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 用 `Integer.MAX_VALUE` 初始 `dp` → `+1` 溢出 | 用 `amount + 1` 当"不可达"哨兵 |
| 最后忘判"仍是不可达" → 错返 `amount+1` | `return dp[amount] > amount ? -1 : dp[amount];` |
| 用记忆化 DFS 没缓存 | TLE，必须缓存 |

---

## 三、Java 题解

### 解法 A：自底向上 DP（推荐）

```java
class Solution {
    public int coinChange(int[] coins, int amount) {
        int[] dp = new int[amount + 1];
        Arrays.fill(dp, amount + 1);   // 哨兵：不可达
        dp[0] = 0;
        for (int i = 1; i <= amount; i++) {
            for (int c : coins) {
                if (c <= i) dp[i] = Math.min(dp[i], dp[i - c] + 1);
            }
        }
        return dp[amount] > amount ? -1 : dp[amount];
    }
}
```

**记忆口诀**：
> **"金额从小到大，每个金额试一遍硬币，取最小 + 1。"**

### 解法 B：记忆化 DFS（自顶向下）

```java
class Solution {
    private int[] memo;
    public int coinChange(int[] coins, int amount) {
        memo = new int[amount + 1];
        Arrays.fill(memo, -2);          // -2: 未计算; -1: 不可达
        return dfs(coins, amount);
    }
    private int dfs(int[] coins, int rem) {
        if (rem < 0) return -1;
        if (rem == 0) return 0;
        if (memo[rem] != -2) return memo[rem];
        int best = Integer.MAX_VALUE;
        for (int c : coins) {
            int sub = dfs(coins, rem - c);
            if (sub >= 0) best = Math.min(best, sub + 1);
        }
        return memo[rem] = (best == Integer.MAX_VALUE) ? -1 : best;
    }
}
```

---

## 四、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(amount · |coins|)** |
| 空间 | O(amount) |

---

## 五、示例验证

`coins = [1,2,5], amount = 11`

| i | 试 1 (dp[i-1]+1) | 试 2 (dp[i-2]+1) | 试 5 (dp[i-5]+1) | dp[i] |
|---|---|---|---|---|
| 0 | — | — | — | 0 |
| 1 | dp[0]+1=1 | — | — | 1 |
| 2 | dp[1]+1=2 | dp[0]+1=1 | — | 1 |
| 3 | dp[2]+1=2 | dp[1]+1=2 | — | 2 |
| 4 | dp[3]+1=3 | dp[2]+1=2 | — | 2 |
| 5 | dp[4]+1=3 | dp[3]+1=3 | dp[0]+1=1 | 1 |
| 6 | 2 | 2 | dp[1]+1=2 | 2 |
| 7 | 2 | 3 | dp[2]+1=2 | 2 |
| 8 | 3 | 3 | dp[3]+1=3 | 3 |
| 9 | 3 | 4 | dp[4]+1=3 | 3 |
| 10 | 4 | 4 | dp[5]+1=2 | 2 |
| 11 | 3 | 3 | dp[6]+1=3 | **3** ✅ |

---

## 六、复盘与延伸

### 一句话总结
> **完全背包求最少件数：`dp[i] = min(dp[i-c] + 1)` 遍历所有硬币。**

### 新手常见疑问（FAQ）

**Q1：为什么不能贪心 “每次选最大面额的硬币”？**
A：反例 `coins=[1,3,4], amount=6`：贪心 4+1+1=3 枚；最优 3+3=2 枚。面额不能互整除时贪心不成立。唯一例外：面额是“年代制”（如 [1,5,10,25]），贪心才正确。

**Q2：为什么哨兵选 `amount + 1` 而不是 `Integer.MAX_VALUE`？**
A：`Integer.MAX_VALUE + 1` 会溢出为负数。`amount + 1` 是“不可能达到”的上界哨兵（最多需要 amount 枚面额 1 的硬币），+1 后仍然安全。

**Q3：两层循环的顺序可以互换吗？**
A：本题（求最少件数）可以：外金额内硬币、外硬币内金额都对。但 LC 518（求方案数）中互换后会重复计同一组合的不同顺序——必须外层是硬币。

**Q4：`dp[i-c]` 为什么不需要判 `dp[i-c]` 是否为“不可达”？**
A：不可达时 `dp[i-c] = amount+1`，+1 后仍然很大，min 不会选它。哨兵设计避免了 if 判断。

**Q5：返回具体硬币组合怎么办？**
A：额外开一个 `from[i]` 记录 `dp[i]` 是从哪一个 c 转移过来的；从 amount 倒推。

### 面试官常见 follow-up
1. **"求凑出 amount 的方案数（LC 518）？"** → 外硬币内金额，`dp[i] += dp[i-c]`。顺序不能颗倒。
2. **"求本身是完全平方数的最少个数（LC 279）？"** → 完全背包，硬币面额是 1²,2²,3²,…
3. **"返回字典序最小的硬币组合？"** → from 记录时遇相同件数取较小 c；倒推后排序。
4. **"硬币面额很大（如 10^9）但 amount 小？"** → 跳过 c > amount 的硬币即可；本算法复杂度 O(amount · |coins|) 不受面额大小影响。
5. **"amount 很大（如 10^9）？"** → 本 DP 能爆 → 改用 BFS（将金额当结点，边是硬币面额）或数学推导。面试少见。
6. **"每种硬币有数量限制（多重背包）？"** → 二进制拆分成 0/1 背包，或单调队列优化。

### 同类型推荐（**背包家族**）
**完全背包**：
- LC 322. Coin Change（求最少件数，本题）
- LC 518. Coin Change II（求方案数）
- LC 279. 完全平方数（拆数 = 完全背包）
- LC 139. 单词拆分（字符串完全背包）

**0/1 背包**：
- LC 416. 分割等和子集
- LC 494. 目标和
- LC 474. 一和零

**经典序列 DP**（顺路看）：
- LC 70. 爬楼梯
- LC 198. 打家劫舍
- LC 213. 打家劫舍 II
- LC 337. 打家劫舍 III（树形 DP）
