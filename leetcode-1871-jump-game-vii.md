# [LeetCode 1871. 跳跃游戏 VII (Jump Game VII)](https://leetcode.com/problems/jump-game-vii/)

> 难度：Medium　|　标签：字符串、动态规划、前缀和、滑动窗口、BFS

---

## 一、题目

给你一个下标从 `0` 开始的二进制字符串 `s` 和两个整数 `minJump` 和 `maxJump`。
一开始，你在下标 `0` 处（保证 `s[0] == '0'`）。当**同时**满足下列条件时，可以从下标 `i` 跳到下标 `j`：

1. `i + minJump <= j <= min(i + maxJump, s.length - 1)`
2. `s[j] == '0'`

如果可以到达 `s.length - 1`，返回 `true`，否则返回 `false`。

**约束**

- `2 <= s.length <= 10^5`
- `s[i] ∈ {'0','1'}`，`s[0] == '0'`
- `1 <= minJump <= maxJump < s.length`

**示例**

| 输入 | 输出 | 路径 |
|---|---|---|
| `s = "011010", minJump = 2, maxJump = 3` | `true`  | `0 → 3 → 5` |
| `s = "01101110", minJump = 2, maxJump = 3` | `false` | `0` 只能跳到 `[2,3]`，全是 `'1'` |

---

## 二、解题思路（学习重点）

### 1. 题目分析：把题意翻译成"图/状态"

- **状态**：下标 `i`（值 `0~n-1`）。
- **状态转移**：从 `i` 能到 `j`，当且仅当 `j ∈ [i+minJump, i+maxJump]` 且 `s[j]=='0'`。
- **目标**：判断 `n-1` 是否可达。

> 第一反应：BFS / DFS。但 `n` 可达 `10^5`，每个点扩展 `maxJump - minJump + 1 ≈ 10^5` 个邻居，朴素 BFS 是 **O(n·(max-min))**，最坏 `10^10`，必然 TLE。
> **学习点 ①**：看到"区间转移 + 大数据量"，先考虑能否优化到 **O(n)**。

### 2. 关键观察：转移条件是"区间"，反向思考

正向：从 `i` 能到达哪些 `j`？→ 一个区间 `[i+minJump, i+maxJump]`。
反向：`j` 能被哪些 `i` 到达？→ 区间 `[j-maxJump, j-minJump]`。

**反向定义 DP**：
$$dp[j] = \text{是否可从 } 0 \text{ 到达 } j$$

$$dp[j] = (s[j]=='0') \land \big(\exists\, k \in [j-maxJump,\; j-minJump],\ dp[k]=true\big)$$

> **学习点 ②**：状态转移涉及"区间是否存在某个 true"，等价于"区间求和 > 0"，天然适配**前缀和**。

### 3. 细节分析（容易踩的坑）

| 细节 | 对应技巧 |
|---|---|
| 终点 `s[n-1]=='1'` 直接返回 `false` | 边界提前剪枝 |
| 区间 `[j-maxJump, j-minJump]` 可能越界（左边 < 0） | `lo = max(0, j-maxJump)` |
| 区间可能为空（`j < minJump`） | 判断 `hi >= lo` 才有效 |
| O(1) 查区间内 true 的数量 | **前缀和** `pre[i] = Σdp[0..i-1]`，用 `int` 数组比 `boolean` 数组更易做前缀和 |
| 起点 `dp[0]=true` 一定要设置 | 初始化 |
| 同一个 `j` 不能被多次处理（BFS 解法） | **双指针 `farthest`** 记录已扩展过的最远下标，保证每个点仅入队一次，O(n) |

### 4. 两种 O(n) 解法对比（推荐都掌握）

| 解法 | 思想 | 适用场景 |
|---|---|---|
| **DP + 前缀和**（推荐先掌握） | 反向定义状态，把"区间存在性查询"转成前缀和差分 | 通用模板，容易扩展到带权 |
| **BFS + 滑动窗口指针** | 正向 BFS，但用 `farthest` 避免重复入队 | 直觉好理解，更接近题面动作 |

> **学习点 ③**：本题是「**区间转移 DP → 前缀和优化**」的经典模板，类似题：
> - LC 1851. 包含每个查询的最小区间
> - LC 1652. 拆炸弹
> - LC 2090. 半径为 k 的子数组平均值
> - LC 1024. 视频拼接（区间 DP 变形）

---

## 三、Java 题解

### 解法 A：DP + 前缀和（推荐）

```java
class Solution {
    public boolean canReach(String s, int minJump, int maxJump) {
        int n = s.length();
        // 剪枝：终点是 '1' 必不可达
        if (s.charAt(n - 1) == '1') return false;

        boolean[] dp = new boolean[n];
        int[] pre = new int[n + 1]; // pre[i] = dp[0]+dp[1]+...+dp[i-1] (true 计为 1)

        dp[0] = true;
        pre[1] = 1; // dp[0] = true

        for (int j = 1; j < n; j++) {
            if (s.charAt(j) == '0') {
                int lo = Math.max(0, j - maxJump);
                int hi = j - minJump;
                // 区间 [lo, hi] 内是否至少有一个 dp[k] = true
                if (hi >= lo && pre[hi + 1] - pre[lo] > 0) {
                    dp[j] = true;
                }
            }
            pre[j + 1] = pre[j] + (dp[j] ? 1 : 0);
        }
        return dp[n - 1];
    }
}
```

**记忆口诀**：
> **"反向定义 dp[j]，区间存在变求和，前缀和差分一行搞定。"**

### 解法 B：BFS + 双指针（避免重复入队）

```java
class Solution {
    public boolean canReach(String s, int minJump, int maxJump) {
        int n = s.length();
        if (s.charAt(n - 1) == '1') return false;

        Deque<Integer> queue = new ArrayDeque<>();
        queue.offer(0);
        int farthest = 0; // 已经被"扩展过"的最远下标，避免重复加入队列

        while (!queue.isEmpty()) {
            int i = queue.poll();
            if (i == n - 1) return true;

            int start = Math.max(i + minJump, farthest + 1);
            int end   = Math.min(i + maxJump, n - 1);
            for (int j = start; j <= end; j++) {
                if (s.charAt(j) == '0') queue.offer(j);
            }
            farthest = Math.max(farthest, end);
        }
        return false;
    }
}
```

**核心技巧**：`farthest` 保证每个下标最多被遍历一次 → 整体 **O(n)**。

---

## 四、复杂度

| 解法 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| DP + 前缀和 | **O(n)** | O(n)（`dp` + `pre`） |
| BFS + 双指针 | **O(n)** | O(n)（队列） |

> 朴素 BFS 是 O(n·(maxJump−minJump))，最坏 O(n²)，会 TLE。**必须**优化到 O(n)。

---

## 五、示例验证（手工跑一遍）

### 示例 1：`s = "011010"`, minJump = 2, maxJump = 3

| j | s[j] | lo=max(0,j-3) | hi=j-2 | 区间 dp | dp[j] | pre[j+1] |
|---|---|---|---|---|---|---|
| 0 | '0' | — | — | 初始化 | **T** | 1 |
| 1 | '1' | — | — | 跳过 | F | 1 |
| 2 | '1' | 0 | 0 | dp[0]=T | (s='1') F | 1 |
| 3 | '0' | 0 | 1 | dp[0]=T | **T** | 2 |
| 4 | '1' | 1 | 2 | F,F | F | 2 |
| 5 | '0' | 2 | 3 | F,T | **T** | 3 |

`dp[5] = true` ✅ 路径 `0 → 3 → 5`。

### 示例 2：`s = "01101110"`, minJump = 2, maxJump = 3

| j | s[j] | lo | hi | 区间 dp | dp[j] |
|---|---|---|---|---|---|
| 0 | '0' | — | — | 初始化 | **T** |
| 1 | '1' | — | — | — | F |
| 2 | '1' | 0 | 0 | T | (s='1') F |
| 3 | '0' | 0 | 1 | T,F | **T** |
| 4 | '1' | 1 | 2 | F,F | F |
| 5 | '1' | 2 | 3 | F,T | (s='1') F |
| 6 | '1' | 3 | 4 | T,F | (s='1') F |
| 7 | '0' | 4 | 5 | F,F | **F** |

`dp[7] = false` ✅

---

## 六、复盘与延伸（提升记忆）

### 一句话总结
> **区间转移问题 → 反向定义 dp → 前缀和把区间存在性查询降到 O(1)。**

### 自我提问（合上代码默答）
1. 为什么要反向定义 `dp[j]` 而不是正向 `dp[i] → dp[j]` 更新？
   → 反向把"我从哪些点来"变成区间查询，前缀和能直接处理。正向是"区间更新"，需要差分数组，稍复杂。
2. 前缀和数组为什么长度是 `n+1`？
   → 让 `pre[hi+1] - pre[lo]` 表示闭区间 `[lo, hi]` 的和，避免下标越界判断。
3. 朴素 BFS 为什么 TLE？怎么优化？
   → 同一个下标可能被多个前驱重复加入队列；用 `farthest` 单调推进保证每点只入队一次。
4. 终点是 `'1'` 时为什么可以直接返回 `false`？
   → 转移条件要求 `s[j]=='0'`，终点不满足就永远不可达。

### 同类型题推荐（巩固模板）
- LC 1306. 跳跃游戏 III（BFS）
- LC 1340. 跳跃游戏 V（记忆化 DP）
- LC 1696. 跳跃游戏 VI（DP + 单调队列）← **强烈推荐对比，区间最大值用单调队列，本题区间存在性用前缀和**
- LC 1340 / 1654 / 2297（跳跃系列）
