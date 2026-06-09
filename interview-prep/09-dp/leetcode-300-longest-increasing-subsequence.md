# [LeetCode 300. 最长递增子序列 (Longest Increasing Subsequence)](https://leetcode.com/problems/longest-increasing-subsequence/)

> 难度：Medium　|　标签：动态规划、二分查找、贪心　|　**LIS 模板 ⭐⭐⭐**

---

## 一、题目

给你一个整数数组 `nums`，找到其中最长 **严格递增子序列** 的长度。

**子序列**：不要求连续，只需保持原相对顺序。

**约束**

- `1 <= nums.length <= 2500`
- `-10^4 <= nums[i] <= 10^4`

**进阶**：能将算法的时间复杂度降低到 **O(n log n)** 吗？

**示例**

| 输入 | 输出 | 一个 LIS |
|---|---|---|
| `[10,9,2,5,3,7,101,18]` | `4` | `[2,3,7,101]` |
| `[0,1,0,3,2,3]` | `4` | `[0,1,2,3]` |
| `[7,7,7,7,7,7,7]` | `1` | `[7]` |

---

## 二、解题思路（学习重点）

### 1. 解法一：O(n²) 经典 DP

`dp[i]` = **以 `nums[i]` 结尾的 LIS 长度**。

转移：对每个 `i`，向前看所有 `j < i`：
$$dp[i] = \max\{dp[j] + 1\;\big|\; j < i,\ nums[j] < nums[i]\} \cup \{1\}$$

答案 = `max(dp)`。

> **学习点 ①**：序列 DP 的状态几乎都是"以 i 结尾"，**这是为了保证子序列连续依赖关系**。

### 2. 解法二：O(n log n) 贪心 + 二分（必背）

维护一个数组 `tails`，**`tails[k]` 表示长度为 `k+1` 的所有递增子序列的"末尾元素的最小值"**。

遍历 `nums`，对每个 `x`：
- 用 **二分查找** 在 `tails` 里找到 **第一个 >= x** 的位置 `pos`：
  - 若 `pos == tails.size()` → `x` 比所有 tails 都大 → **追加** 到 tails 末尾，LIS 长度 +1
  - 否则 → **替换** `tails[pos] = x`（让长度为 pos+1 的子序列末尾更小，给后续元素留出更大空间）

`tails` 的长度即 LIS 长度。

> **学习点 ②**：`tails` 数组在过程中是 **严格递增** 的（这是它本身的不变量），所以可以二分。**注意 `tails` 本身不一定是真正的 LIS**，只是长度对。
>
> **学习点 ③**："找第一个 >= x" 用 `Arrays.binarySearch` 的返回值 `-(insertion_point) - 1` 处理；或自己写 `lowerBound`。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 把 "严格递增" 看成 "非递减" | "严格" 用 `lowerBound`（>= x 替换）；"非递减" 用 `upperBound`（> x 替换） |
| 误以为 tails 就是真正的 LIS | 它只是 **长度** 正确，并非具体序列；要还原 LIS 需要额外记录前驱 |
| O(n²) 内层 j 写成 `for j=i+1`（方向反了） | 应该 `for j in [0, i)` |

---

## 三、Java 题解

### 解法 A：O(n²) DP（入门必背）

```java
class Solution {
    public int lengthOfLIS(int[] nums) {
        int n = nums.length, best = 1;
        int[] dp = new int[n];
        Arrays.fill(dp, 1);
        for (int i = 1; i < n; i++) {
            for (int j = 0; j < i; j++) {
                if (nums[j] < nums[i]) dp[i] = Math.max(dp[i], dp[j] + 1);
            }
            best = Math.max(best, dp[i]);
        }
        return best;
    }
}
```

### 解法 B：O(n log n) 贪心 + 二分（**面试必背**）

```java
class Solution {
    public int lengthOfLIS(int[] nums) {
        int[] tails = new int[nums.length];
        int size = 0;
        for (int x : nums) {
            int pos = lowerBound(tails, 0, size, x);
            tails[pos] = x;
            if (pos == size) size++;
        }
        return size;
    }
    // 返回 [l, r) 内第一个 >= target 的下标
    private int lowerBound(int[] a, int l, int r, int target) {
        while (l < r) {
            int m = (l + r) >>> 1;
            if (a[m] < target) l = m + 1;
            else r = m;
        }
        return l;
    }
}
```

**记忆口诀**：
> **"tails 保最小末尾，二分找 lowerBound，能加就加不能就替。"**

---

## 四、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| DP | O(n²) | O(n) |
| 贪心 + 二分 | **O(n log n)** | O(n) |

---

## 五、示例验证

`nums = [10, 9, 2, 5, 3, 7, 101, 18]`，贪心 + 二分过程：

| 当前 x | tails 操作 | tails |
|---|---|---|
| 10 | 追加 | [10] |
| 9 | 替换 tails[0] | [9] |
| 2 | 替换 tails[0] | [2] |
| 5 | 追加 | [2,5] |
| 3 | 替换 tails[1] | [2,3] |
| 7 | 追加 | [2,3,7] |
| 101 | 追加 | [2,3,7,101] |
| 18 | 替换 tails[3] | [2,3,7,18] |

`size = 4` ✅

---

## 六、复盘与延伸

### 一句话总结
> **维护"长度为 k 的递增子序列的最小末尾"，二分插入更新；最终长度即 LIS。**

### 新手常见疑问（FAQ）

**Q1：`tails` 是真正的 LIS 吗？**
A：**不是**。示例 `[10,9,2,5,3,7,101,18]` 最终 tails = `[2,3,7,18]`，但真正的 LIS 有 `[2,3,7,101]` 含 101。tails 只保证长度正确。

**Q2：为什么严格递增用 `lowerBound` 而非递增用 `upperBound`？**
A：`lowerBound` 找首个 `≥ x`，遇到同值也替换，不让同值並列（严格）；`upperBound` 找首个 `> x`，同值不动 → 同值可以多个並列（非递减允许重复）。

**Q3：为什么贪心“越小越好”是正确的？**
A：长度为 k 的子序列的末尾越小，越能接纳后面更多元素，从而产生更长的序列。贪心选择在未来使结果不变坏。

**Q4：代码中 `pos == size` 才追加是什么意思？**
A：`x` 比 tails 里所有元素都大，lowerBound 返回 `size`（尾后索引）。该点位本来没元素，所以是“追加”，长度 +1。其他情况是“覆盖”，长度不变。

**Q5：能不能不用手写 `lowerBound`，用 JDK API？**
A：能：`Arrays.binarySearch(tails, 0, size, x)` 返回为负数时表示未找到，`-pos-1` 是插入点；找到时返回下标。面试手写 lowerBound 更靶示。

### 面试官常见 follow-up
1. **"返回一个具体的 LIS序列？"** → O(n²) DP 记录前驱下标 + 反推；O(n log n) 记 `tail_idx[i]` + “层号”反推。
2. **"LIS 个数（不是长度，LC 673）？"** → DP 同时维护 `cnt[i]` 表示以 i 结尾的 LIS 个数。
3. **"二维 LIS（俄罗斯套娃信封）？"** → 宽升高降排序后对高跑 LIS。即 **LC 354**。
4. **"最长不递减 / 最长不递增怎么改？"** → 严格变为非严格时，二分换成 `upperBound`。
5. **"需要 「最长山形子序列」或「双向 LIS」？"** → 从左/右各跱一遍 LIS、取 `left[i] + right[i] - 1` 最大。即 **LC 1671 / 845**。
6. **"n=10⁶ 量级还能跳么？"** → O(n log n) 可以。需 long 避免下标溢出。

### 同类型推荐（**LIS 家族**）
- LC 354. 俄罗斯套娃信封问题（二维 LIS）
- LC 673. 最长递增子序列的个数（同时维护 cnt）
- LC 1671. 得到山形数组的最少删除次数（双向 LIS）
- LC 1218. 最长定差子序列（特化为哈希）
- LC 1143. 最长公共子序列（DP 入门姊妹题）
- LC 583. 两个字符串的删除操作（基于 LCS）
- LC 72. 编辑距离（LCS 进阶）
