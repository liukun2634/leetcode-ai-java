# LeetCode 209. 长度最小的子数组 (Minimum Size Subarray Sum)

> 难度：Medium　|　标签：数组、滑动窗口、前缀和　|　**变长窗口求最短模板 ⭐⭐⭐**

---

## 一、题目

给定一个含有 `n` 个正整数的数组和一个正整数 `target`。找出该数组中满足其总和 `≥ target` 的长度最小的 **连续子数组**，并返回其长度。如果不存在符合条件的子数组，返回 `0`。

**约束**

- `1 <= target <= 10^9`
- `1 <= nums.length <= 10^5`
- `1 <= nums[i] <= 10^4`

**示例**

| 输入 | 输出 |
|---|---|
| `target=7, nums=[2,3,1,2,4,3]` | `2`（`[4,3]`）|
| `target=4, nums=[1,4,4]` | `1` |
| `target=11, nums=[1,1,1,1,1,1,1]` | `0` |

题目链接：<https://leetcode.cn/problems/minimum-size-subarray-sum/>

---

## 二、解题思路（学习重点）

### 1. 为什么能用滑动窗口？

数组全是 **正数** → 窗口和 **随窗口扩大单调递增、随收缩单调递减**。这保证了：
- 当窗口和 `≥ target` 时，可以尝试缩小左边界看能否更短
- 当 < target 时，必须扩大右边界

> **学习点 ①**：**正数 + 区间和** 的题型几乎都用滑动窗口。含负数时窗口和失去单调性，需要前缀和 + 单调队列（LC 862）。

### 2. 模板：变长窗口求最短

对比 LC 76（最小覆盖子串）：
- 都是 **"先扩到合法、再缩到刚好不合法"**
- 答案更新放在 **while 里**（每次能缩就更新一次）

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 答案放在 while 外 → 漏掉最短解 | 必须每次缩之前更新答案 |
| 答案初始 0 → 没找到时返回 0 ✓ | 用 `Integer.MAX_VALUE` 当哨兵，最后判 |
| 含负数时套用本模板 → 错 | 改用前缀和 + 单调队列 |

---

## 三、详细解题步骤

**步骤 1**：初始化
```java
int l = 0, sum = 0, ans = Integer.MAX_VALUE;
```

**步骤 2**：右指针扩展
```java
for (int r = 0; r < nums.length; r++) {
    sum += nums[r];
    while (sum >= target) {                 // 窗口已合法，尽量缩
        ans = Math.min(ans, r - l + 1);
        sum -= nums[l++];
    }
}
```

**步骤 3**：返回
```java
return ans == Integer.MAX_VALUE ? 0 : ans;
```

---

## 四、Java 题解

```java
class Solution {
    public int minSubArrayLen(int target, int[] nums) {
        int l = 0, sum = 0, ans = Integer.MAX_VALUE;
        for (int r = 0; r < nums.length; r++) {
            sum += nums[r];
            while (sum >= target) {
                ans = Math.min(ans, r - l + 1);
                sum -= nums[l++];
            }
        }
        return ans == Integer.MAX_VALUE ? 0 : ans;
    }
}
```

**记忆口诀**：
> **"右扩到合法，左缩到刚不合法；while 内更新答案。"**

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 滑动窗口 | **O(n)** | O(1) |
| 前缀和 + 二分（O(n log n)） | O(n log n) | O(n) |

---

## 六、示例验证

`target=7, nums=[2,3,1,2,4,3]`

| r | nums[r] | sum | l | 缩 | ans |
|---|---|---|---|---|---|
| 0 | 2 | 2 | 0 | — | ∞ |
| 1 | 3 | 5 | 0 | — | ∞ |
| 2 | 1 | 6 | 0 | — | ∞ |
| 3 | 2 | 8 | 0→1 | 缩：ans=4, sum=6 | 4 |
| 4 | 4 | 10 | 1→3 | 缩：ans=4, sum=8, ans=3, sum=5 | 3 |
| 5 | 3 | 8 | 3→4 | 缩：ans=3, sum=6, **缩：ans=2** | **2** |

输出 `2` ✅

---

## 七、复盘与延伸

### 一句话总结
> **正数数组 + 区间和单调 → 滑动窗口；右扩到合法，左缩到刚好不合法。**

### 新手常见疑问（FAQ）

**Q1：含负数为什么不能用滑动窗口？**
A：负数破坏单调性。缩左边界时 sum 可能变大（左边是负数），无法判断"何时停止收缩"。需用前缀和 + 单调队列（LC 862）。

**Q2：答案为什么放在 while 内？**
A：求最短，每次能缩就尝试缩并记录；只在 while 外更新会漏掉"刚好合法时"的最优 `r-l+1`。

**Q3：前缀和 + 二分版怎么做？**
A：开 `prefix[]`，对每个 r 二分找最大的 l 使 `prefix[r] - prefix[l-1] >= target`，记录 `r - l + 1`。`O(n log n)`。

**Q4：为什么不开数组记录窗口元素？**
A：只关心 sum 和长度，O(1) 变量足够。

**Q5：窗口和何时溢出？**
A：sum 最大 `10^5 * 10^4 = 10^9`，int 够；若元素是 `10^9` 则要 long。

### 面试官常见 follow-up
1. **"含负数怎么改？"** → 前缀和 + 单调递增队列。[LC 862](https://leetcode.cn/problems/shortest-subarray-with-sum-at-least-k/)。
2. **"求所有满足 sum >= target 的子数组数量？"** → 双指针变种，但要小心计数公式（不是简单 r-l+1）。
3. **"求 sum == target 的最短子数组？"** → 前缀和 + 哈希表存"最后一次出现的下标"。
4. **"求乘积 < k 的子数组数量（[LC 713](https://leetcode.cn/problems/subarray-product-less-than-k/)）？"** → 同滑窗模板，元素必须为正。
5. **"二维版：矩阵中和 ≥ target 的最小子矩阵？"** → 枚举上下边界 + 一维滑窗，O(m²n)。
6. **"数据流场景？"** → 滑窗可在线，每来一个数 O(1) 摊销更新。

### 同类型推荐（**变长窗口家族**）
- [LC 3. 无重复字符的最长子串](https://leetcode.cn/problems/longest-substring-without-repeating-characters/)（求最长）
- [LC 76. 最小覆盖子串](https://leetcode.cn/problems/minimum-window-substring/)（求最短，覆盖条件）
- [LC 713. 乘积小于 K 的子数组](https://leetcode.cn/problems/subarray-product-less-than-k/)（计数）
- [LC 1004. 最大连续 1 的个数 III](https://leetcode.cn/problems/max-consecutive-ones-iii/)（含 k 个 0）
- [LC 862. 和至少为 K 的最短子数组](https://leetcode.cn/problems/shortest-subarray-with-sum-at-least-k/)（含负数 + 前缀和 + 单调队列）
