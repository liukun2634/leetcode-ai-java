# LeetCode 122. 买卖股票的最佳时机 II (Best Time to Buy and Sell Stock II)

> 难度：Medium　|　标签：数组、贪心、动态规划　|　**股票系列入门 ⭐⭐⭐**

---

## 一、题目

给你一个整数数组 `prices`，其中 `prices[i]` 表示某支股票第 `i` 天的价格。

在每一天，你可以决定是否购买和/或出售股票。你在任何时候 **最多只能持有一股** 股票。你也可以先购买，然后在 **同一天** 出售。

返回你能获得的 **最大利润**。

**约束**

- `1 <= prices.length <= 3 * 10^4`
- `0 <= prices[i] <= 10^4`

**示例**

| 输入 | 输出 | 操作 |
|---|---|---|
| `[7,1,5,3,6,4]` | `7` | 1→5 赚 4，3→6 赚 3 |
| `[1,2,3,4,5]` | `4` | 1→5 一次完成 |
| `[7,6,4,3,1]` | `0` | 不交易 |

题目链接：<https://leetcode.cn/problems/best-time-to-buy-and-sell-stock-ii/>

---

## 二、解题思路（学习重点）

### 1. 贪心：**吃下所有上涨段**

任何"先升后降"的段都对应一对买卖。等价于：**所有相邻正差求和**。

```text
profit = 0
for i = 1..n-1:
    if prices[i] > prices[i-1]:
        profit += prices[i] - prices[i-1]
```

**为什么对**：连续上涨段 `[a, b, c, d]`（a < b < c < d）一次买 a 卖 d 的利润 = `(b-a) + (c-b) + (d-c)`，与相邻差求和等价。下跌段不会被加（差 < 0 跳过）。

> **学习点 ①**：**贪心适用条件 = 无次数限制 + 同一天可买可卖**。带次数限制（LC 123/188）或冷冻期/手续费（LC 309/714）需要状态机 DP。

### 2. 状态机 DP（通用模板）

定义：
- `hold[i]` = 第 i 天持有股票时的最大利润
- `cash[i]` = 第 i 天不持有时的最大利润

转移：
$$hold[i] = \max(hold[i-1], cash[i-1] - prices[i])$$
$$cash[i] = \max(cash[i-1], hold[i-1] + prices[i])$$

最终 `cash[n-1]`。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 误以为是 LC 121 一次交易 → 写成 minPrice | 本题无次数限制 |
| 贪心忘判 `> 0` → 误加负差 | `if (prices[i] > prices[i-1])` |
| 状态机版 hold 初始化错 | `hold = -prices[0]` |

---

## 三、详细解题步骤（贪心）

**步骤 1**：遍历
```java
int profit = 0;
for (int i = 1; i < prices.length; i++) {
    if (prices[i] > prices[i-1]) profit += prices[i] - prices[i-1];
}
return profit;
```

---

## 四、Java 题解

### 解法 A：贪心（推荐）

```java
class Solution {
    public int maxProfit(int[] prices) {
        int profit = 0;
        for (int i = 1; i < prices.length; i++) {
            if (prices[i] > prices[i-1]) profit += prices[i] - prices[i-1];
        }
        return profit;
    }
}
```

**记忆口诀**：
> **"吃下所有上涨段：相邻正差求和。"**

### 解法 B：状态机 DP（为后续题铺路）

```java
class Solution {
    public int maxProfit(int[] prices) {
        int hold = -prices[0], cash = 0;
        for (int i = 1; i < prices.length; i++) {
            int newHold = Math.max(hold, cash - prices[i]);
            int newCash = Math.max(cash, hold + prices[i]);
            hold = newHold;
            cash = newCash;
        }
        return cash;
    }
}
```

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 贪心 | **O(n)** | O(1) |
| 状态机 DP | O(n) | O(1) |

---

## 六、示例验证

`prices = [7,1,5,3,6,4]`

| i | prices[i] | prices[i-1] | 差 | profit |
|---|---|---|---|---|
| 1 | 1 | 7 | -6 | 0 |
| 2 | 5 | 1 | +4 | 4 |
| 3 | 3 | 5 | -2 | 4 |
| 4 | 6 | 3 | +3 | 7 |
| 5 | 4 | 6 | -2 | 7 |

输出 `7` ✅

---

## 七、复盘与延伸

### 一句话总结
> **无次数限制 + 同日可买卖 → 贪心吃下所有相邻正差，等价于多次低买高卖。**

### 新手常见疑问（FAQ）

**Q1：为什么"相邻正差求和"等价于"低买高卖"？**
A：连续上涨段 a→d 的总利润 = d - a = (b-a) + (c-b) + (d-c)。相邻正差是上涨段的拆分；下跌段差 < 0 不加。

**Q2：能在同一天买卖吗？**
A：题目允许。这让贪心成立（不影响"最多持一股"约束，因为同日买卖等价于不交易）。

**Q3：限制 k 次交易（LC 188）怎么改？**
A：状态机 DP，开 `dp[k][2]` 表示用了 j 次交易 + 持/不持。

**Q4：含手续费（LC 714）？**
A：状态机 DP，卖出时减 fee。贪心也可以，但要小心：只有"上涨幅度 > fee"才值得卖。

**Q5：含冷冻期（LC 309）？**
A：状态机 + 第三态"冷冻"；卖出后下一天不能买。

### 面试官常见 follow-up
1. **"最多 1 次（LC 121）？"** → 维护历史最低 + 当天差。
2. **"最多 2 次（LC 123）/ 最多 k 次（LC 188）？"** → 状态机 DP `dp[i][j][0/1]`。
3. **"含冷冻期（LC 309）？"** → 三态：持/不持/冷冻。
4. **"含手续费（LC 714）？"** → 卖出时扣 fee。
5. **"返回每笔具体交易？"** → 贪心时记录每个上涨段的起止。
6. **"流式数据？"** → 贪心 O(1) 摊销。

### 同类型推荐（**股票系列**）
- LC 121. 买卖股票的最佳时机（1 次）
- LC 122. 本题（无限次）
- LC 123. 最多 2 次
- LC 188. 最多 k 次
- LC 309. 含冷冻期
- LC 714. 含手续费
- LC 901. 股票价格跨度（单调栈，非交易题）
