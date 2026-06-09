# LeetCode 121. 买卖股票的最佳时机 (Best Time to Buy and Sell Stock)

> 难度：Easy　|　标签：数组、动态规划、贪心　|	|	**贪心入门 ⭐⭐⭐**

---

## 一、题目

给定一个数组 `prices`，它的第 `i` 个元素 `prices[i]` 表示一支给定股票第 `i` 天的价格。

你只能选择 **某一天** 买入这只股票，并选择在 **未来的某一个不同的日子** 卖出该股票。设计一个算法来计算你所能获取的最大利润。

返回你可以从这笔交易中获取的最大利润。如果你不能获取任何利润，返回 `0`。

**约束**

- `1 <= prices.length <= 10^5`
- `0 <= prices[i] <= 10^4`

**示例**

| 输入 | 输出 | 说明 |
|---|---|---|
| `[7,1,5,3,6,4]` | `5` | 买 1 卖 6 |
| `[7,6,4,3,1]` | `0` | 一直跌，不交易 |

题目链接：<https://leetcode.cn/problems/best-time-to-buy-and-sell-stock/>

---

## 二、解题思路（学习重点）

### 1. 题意翻译

求：`max(prices[j] - prices[i])`，其中 `i < j`。

### 2. 一遍扫描：**维护历史最低买入价**

边走边问"**今天卖出能赚多少？**"：
- 当前价 `prices[i]`
- 历史最低买入价 `minPrice`
- 今日利润 = `prices[i] - minPrice`

全程取最大。同时更新 `minPrice = min(minPrice, prices[i])`。

> **学习点 ①**：**"求最大差 / 双下标关系"** 的经典模板 = **边扫边维护"对面端"的最优值**。
> 同模板：LC 122（多次交易，差分贪心）、LC 309（含冷冻期 DP）、LC 188（最多 k 次交易）。

### 3. DP 视角

`dp[i]` = 前 i 天的最大利润：
$$dp[i] = \max(dp[i-1],\; prices[i] - \min(prices[0..i]))$$

由于只用 `min` 和 `dp[i-1]` → 两个变量足矣。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| `minPrice` 初始化 `Integer.MAX_VALUE` 后忘了更新顺序 | 必须 **先算利润、再更新 min**（其实顺序无所谓，因为同一天不能买卖；但建议先算利润思路更清晰） |
| 误以为是"区间最大值 − 区间最小值" | 必须满足 `min` 在 `max` 之前出现 |

---

## 三、详细解题步骤

**步骤 1**：初始化
```java
int minPrice = Integer.MAX_VALUE;
int maxProfit = 0;
```

**步骤 2**：遍历每一天 `prices[i]`：
  1. **更新历史最低买入价**：`minPrice = Math.min(minPrice, prices[i]);`
  2. **更新最大利润**：`maxProfit = Math.max(maxProfit, prices[i] - minPrice);`

**步骤 3**：返回 `maxProfit`。

> 注：步骤 2 的两行可以互换。若先算利润再更新 min，今天的利润 = 今天卖 − 之前最低，逻辑也对（同一天买卖利润为 0，不会改变 max）。

---

## 四、Java 题解

### 解法 A：一遍扫描（推荐）

```java
class Solution {
    public int maxProfit(int[] prices) {
        int minPrice = Integer.MAX_VALUE;
        int maxProfit = 0;
        for (int p : prices) {
            minPrice = Math.min(minPrice, p);
            maxProfit = Math.max(maxProfit, p - minPrice);
        }
        return maxProfit;
    }
}
```

**记忆口诀**：
> **"扫一遍：刷新历史最低买，今天卖了能赚多少。"**

### 解法 B：DP 状态机（为后续股票系列铺路）

定义 `hold[i]` = 第 i 天持有股票时的最大现金，`cash[i]` = 第 i 天不持有时的最大现金。

```java
class Solution {
    public int maxProfit(int[] prices) {
        int hold = -prices[0], cash = 0;
        for (int i = 1; i < prices.length; i++) {
            hold = Math.max(hold, -prices[i]);        // 只能买一次 → 持有最小成本
            cash = Math.max(cash, hold + prices[i]);  // 卖出
        }
        return cash;
    }
}
```

> 状态机版是 **LC 122 / 309 / 188** 的通用模板。先把本题理解透。

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n)** |
| 空间 | **O(1)** |

---

## 六、示例验证

`prices = [7,1,5,3,6,4]`

| i | price | minPrice | maxProfit |
|---|---|---|---|
| 0 | 7 | 7 | 0 |
| 1 | 1 | 1 | 0 |
| 2 | 5 | 1 | 4 |
| 3 | 3 | 1 | 4 |
| 4 | 6 | 1 | **5** |
| 5 | 4 | 1 | 5 |

输出 `5` ✅

---

## 七、复盘与延伸

### 一句话总结
> **维护历史最低买入价，每天问"今天卖能赚多少"，取全程最大。**

### 新手常见疑问（FAQ）

**Q1：与「区间最大 − 区间最小」区别是什么？**
A：后者不保证最小点出现在最大点之前，可能给出「高价买入后底价卖出」的非法方案。本算法的 minPrice 是“当天及之前”的最小，天然满足 i < j。

**Q2：minPrice 初始为 `Integer.MAX_VALUE` 是必须的吗？**
A：不是，初始为 `prices[0]` 也对，从 i=1 开始扫；但初始 MAX 后从 i=0 开始代码更简洁。

**Q3：为什么先更新 minPrice 还是先算利润，顺序重要吗？**
A：不重要。先更新后 profit = p - p = 0（同天买卖），不会提升 max；先算后更新逻辑也对。习惯上推荐先 min后 profit 以避免负数。

**Q4：DP 状态机版本 hold/cash 代表什么？**
A：`hold` = 今天持股状态下的最佳现金（买入后从 0 变负）；`cash` = 今天不持股状态下的最佳现金。仅一次交易：hold 只能 `-p`（不能由 cash + ... 转移）。LC 122 多次交易时 hold = max(hold, cash - p)。

**Q5：可不可以不买卖（返回 0）？**
A：可以。maxProfit 初始 0，若价格一路下跌，maxProfit 始终 0，返回正确。

### 面试官常见 follow-up
1. **"不限交易次数（LC 122）？"** → 贪心：所有相邻正差都吃下（上涨都赚到上一场事件）。或状态机 DP。
2. **"最多 2 次（LC 123） / 最多 k 次（LC 188）？"** → 状态机 DP 震纺出 k 个 hold/cash 状态。
3. **"含冷冻期（LC 309）？"** → 状态机加一个冷冻状态。
4. **"含手续费（LC 714）？"** → 卖出时减 fee 即可。
5. **"返回买卖日期？"** → 更新 maxProfit 时同步记录 “起价日” 与 “今天”。
6. **"股价流式进来（一个一个接收）？"** → 本算法天然在线：每收到一个价格，O(1) 更新 minPrice 与 maxProfit。

### 同类型推荐（**股票系列**）
- LC 122. 买卖股票最佳时机 II（多次交易）
- LC 123. 买卖股票最佳时机 III（最多 2 次）
- LC 188. 买卖股票最佳时机 IV（最多 k 次）
- LC 309. 含冷冻期
- LC 714. 含手续费

**"扫描维护对面端最优"模板**：
- LC 11. 盛最多水的容器
- LC 42. 接雨水（双指针 + 前后缀最大）
- LC 53. 最大子数组和（Kadane）
- LC 152. 乘积最大子数组
