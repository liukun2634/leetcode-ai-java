# LeetCode 55. 跳跃游戏 (Jump Game)

> 难度：Medium　|　标签：数组、贪心、动态规划　|　**贪心 vs DP 经典对比 ⭐⭐⭐**

---

## 一、题目

给定一个非负整数数组 `nums`，你最初位于数组的 **第一个下标**。数组中的每个元素代表你在该位置可以跳跃的 **最大长度**。

判断你是否能够 **到达最后一个下标**。

**约束**

- `1 <= nums.length <= 10^4`
- `0 <= nums[i] <= 10^5`

**示例**

| 输入 | 输出 |
|---|---|
| `[2,3,1,1,4]` | `true`（0→1→4）|
| `[3,2,1,0,4]` | `false`（卡在 3 跳不到 4）|
| `[0]` | `true`（起点即终点）|

题目链接：<https://leetcode.cn/problems/jump-game/>

---

## 二、解题思路（学习重点）

### 1. 贪心：维护"最远能到达的下标"

设 `maxReach` = 已经能到的最远下标。遍历每个位置 `i`：
- 若 `i > maxReach` → 走不到 i，更别说后面，直接 `false`
- 否则 `maxReach = max(maxReach, i + nums[i])`

最终 `maxReach >= n - 1` → `true`。

**贪心正确性**：能到达 i 就能到达 i 之前所有位置；从 i 起 i+nums[i] 是新的可达上限。

> **学习点 ①**：**"是否可达"** 类问题首选 **贪心维护最远可达**，O(n) 一遍扫。"求最少步数"也是 LC 45（贪心区间分层）。

### 2. DP 视角（不推荐但要会）

`dp[i]` = 是否能到达 i。
- `dp[0] = true`
- `dp[i] = ∃ j < i, dp[j] && j + nums[j] >= i`

O(n²)，不必要。贪心 O(n) 已最优。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| `for` 循环里没及时 break | 一旦 `i > maxReach` 立即 return false |
| `maxReach >= n - 1` 就可以提前 return true | 优化但非必须 |
| 数组只有一个元素 | 直接 true |

---

## 三、详细解题步骤

**步骤 1**：初始化
```java
int maxReach = 0, n = nums.length;
```

**步骤 2**：遍历
```java
for (int i = 0; i < n; i++) {
    if (i > maxReach) return false;
    maxReach = Math.max(maxReach, i + nums[i]);
    if (maxReach >= n - 1) return true;        // 早停优化
}
return true;
```

---

## 四、Java 题解

```java
class Solution {
    public boolean canJump(int[] nums) {
        int maxReach = 0, n = nums.length;
        for (int i = 0; i < n; i++) {
            if (i > maxReach) return false;
            maxReach = Math.max(maxReach, i + nums[i]);
            if (maxReach >= n - 1) return true;
        }
        return true;
    }
}
```

**记忆口诀**：
> **"贪心维护最远可达；走不到就 false，可达终点 true。"**

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 贪心 | **O(n)** | O(1) |
| DP | O(n²) | O(n) |

---

## 六、示例验证

`nums = [2,3,1,1,4]`

| i | nums[i] | maxReach 更新前 | maxReach 更新后 |
|---|---|---|---|
| 0 | 2 | 0 ≥ 0 OK | max(0, 0+2) = 2 |
| 1 | 3 | 1 ≤ 2 OK | max(2, 1+3) = 4 |
| 2 | 1 | 2 ≤ 4 OK | max(4, 2+1) = 4 ≥ n-1=4 → return **true** ✅ |

反例 `nums = [3,2,1,0,4]`

| i | nums[i] | maxReach |
|---|---|---|
| 0 | 3 | 3 |
| 1 | 2 | 3 |
| 2 | 1 | 3 |
| 3 | 0 | 3 |
| 4 | — | 4 > 3 → **false** ✗ |

---

## 七、复盘与延伸

### 一句话总结
> **贪心：维护最远可达下标 maxReach，走不到就 false，能盖过终点就 true。**

### 新手常见疑问（FAQ）

**Q1：贪心正确性怎么证明？**
A：归纳法。前 i-1 步若都能到，maxReach 是真实最远值；i 也能到（i ≤ maxReach）后，maxReach 更新为新最远，仍然正确。

**Q2：DP 和贪心结果一样吗？**
A：等价；但贪心 O(n) 比 DP O(n²) 优。

**Q3：含 0 的位置如何处理？**
A：`nums[i] = 0` 时 `i + nums[i] = i`，maxReach 不更新。如果后续 i 超过 maxReach 就 false。算法天然处理。

**Q4：求 **最少跳几步** 到终点（LC 45）？**
A：贪心区间分层：维护当前层"能到的最远位置"`curEnd`、下一层"将能到的最远"`nextEnd`；遍历 i 到 curEnd 时 jumps++ 并更新 curEnd = nextEnd。

**Q5：负数 / 跳跃方向？**
A：本题非负且只能向后跳。若允许双向跳，问题变成图最短路（BFS）。

### 面试官常见 follow-up
1. **"求最少跳几步（[LC 45](https://leetcode.cn/problems/jump-game-ii/)）？"** → 贪心区间分层。
2. **"跳跃游戏 III（[LC 1306](https://leetcode.cn/problems/jump-game-iii/)）：左右跳到任意 0？"** → 改成 BFS。
3. **"跳跃游戏 IV（LC 1345）：同值任意跳？"** → BFS + 同值组哈希。
4. **"跳跃游戏 V/VI/VII？"** → DP / 单调队列。
5. **"统计所有能到达终点的方案数？"** → DP，`dp[i] = sum(dp[j], j 能跳到 i)`。
6. **"返回一条具体的可行路径？"** → 贪心时记录每个 i 是从哪里跳过来的，最后回溯。

### 同类型推荐（**贪心 / 跳跃家族**）
- [LC 45. 跳跃游戏 II](https://leetcode.cn/problems/jump-game-ii/)（最少步数）
- [LC 1306. 跳跃游戏 III](https://leetcode.cn/problems/jump-game-iii/)
- LC 1345. 跳跃游戏 IV
- LC 1654. 到家的最少跳跃次数
- [LC 1696. 跳跃游戏 VI](https://leetcode.cn/problems/jump-game-vi/)（DP + 单调队列）
- [LC 134. 加油站](https://leetcode.cn/problems/gas-station/)（贪心）
