# LeetCode 1143. 最长公共子序列 (Longest Common Subsequence)

> 难度：Medium　|　标签：字符串、动态规划　|　**双串 DP 模板姊妹题 ⭐⭐⭐⭐**

---

## 一、题目

给定两个字符串 `text1` 和 `text2`，返回这两个字符串的最长 **公共子序列** 的长度。如果不存在公共子序列，返回 `0`。

**子序列**：不要求连续，但保持相对顺序。

**约束**

- `1 <= text1.length, text2.length <= 1000`
- 仅含小写字母

**示例**

| 输入 | 输出 | LCS |
|---|---|---|
| `"abcde", "ace"` | `3` | "ace" |
| `"abc", "abc"` | `3` | "abc" |
| `"abc", "def"` | `0` | "" |

题目链接：<https://leetcode.cn/problems/longest-common-subsequence/>

---

## 二、解题思路（学习重点）

### 1. 状态定义（与 LC 72 编辑距离同模板）

`dp[i][j]` = `text1` 前 `i` 个字符与 `text2` 前 `j` 个字符的 LCS 长度。

### 2. 状态转移

考虑 `text1[i-1]` 与 `text2[j-1]`（最后一个字符）：
- **相等** → LCS 长度 = 前 i-1 与 j-1 的 LCS + 1
  $$dp[i][j] = dp[i-1][j-1] + 1$$
- **不等** → 取消去一个的 LCS 较大者
  $$dp[i][j] = \max(dp[i-1][j],\; dp[i][j-1])$$

初始：`dp[0][*] = dp[*][0] = 0`（空串与任何串的 LCS 是 0）。

> **学习点 ①**：**双串 DP** 的状态总是 `dp[i][j] = 前 i 与前 j 的 X`。LC 72 编辑距离、LC 583 最少删除、LC 712 ASCII 删除都是同模板。

### 3. 滚动数组 O(n) 空间

`dp[i][j]` 只依赖 `dp[i-1][j-1]`、`dp[i-1][j]`、`dp[i][j-1]`。用一维 + 一个 prev 变量。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 状态 i, j 是长度还是下标？ | **长度**（前 i 个）|
| 比较字符时下标偏移 | `text1.charAt(i-1)` |
| 不等时只取一边而非 max | 错；必须 max |
| 误以为是子串（连续） | 子序列不要求连续 |

---

## 三、详细解题步骤

**步骤 1**：初始化二维数组
```java
int m = text1.length(), n = text2.length();
int[][] dp = new int[m + 1][n + 1];
```

**步骤 2**：双重循环
```java
for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
        if (text1.charAt(i-1) == text2.charAt(j-1)) {
            dp[i][j] = dp[i-1][j-1] + 1;
        } else {
            dp[i][j] = Math.max(dp[i-1][j], dp[i][j-1]);
        }
    }
}
```

**步骤 3**：返回 `dp[m][n]`。

---

## 四、Java 题解

### 解法 A：二维 DP（推荐先掌握）

```java
class Solution {
    public int longestCommonSubsequence(String text1, String text2) {
        int m = text1.length(), n = text2.length();
        int[][] dp = new int[m + 1][n + 1];
        for (int i = 1; i <= m; i++) {
            for (int j = 1; j <= n; j++) {
                if (text1.charAt(i-1) == text2.charAt(j-1)) {
                    dp[i][j] = dp[i-1][j-1] + 1;
                } else {
                    dp[i][j] = Math.max(dp[i-1][j], dp[i][j-1]);
                }
            }
        }
        return dp[m][n];
    }
}
```

**记忆口诀**：
> **"相等 = 左上 + 1；不等 = max(上, 左)。"**

### 解法 B：滚动数组 O(n) 空间

```java
class Solution {
    public int longestCommonSubsequence(String text1, String text2) {
        int m = text1.length(), n = text2.length();
        int[] dp = new int[n + 1];
        for (int i = 1; i <= m; i++) {
            int prev = 0;       // 保存 dp[i-1][j-1]
            for (int j = 1; j <= n; j++) {
                int temp = dp[j];   // 即将被覆盖的 dp[i-1][j]
                if (text1.charAt(i-1) == text2.charAt(j-1)) {
                    dp[j] = prev + 1;
                } else {
                    dp[j] = Math.max(dp[j], dp[j-1]);
                }
                prev = temp;
            }
        }
        return dp[n];
    }
}
```

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 二维 DP | O(m·n) | O(m·n) |
| 滚动数组 | O(m·n) | **O(n)** |

---

## 六、示例验证

`text1 = "abcde", text2 = "ace"`

```
       ""  a  c  e
   "" [ 0  0  0  0]
   a  [ 0  1  1  1]
   b  [ 0  1  1  1]
   c  [ 0  1  2  2]
   d  [ 0  1  2  2]
   e  [ 0  1  2  3]
```

`dp[5][3] = 3` ✅

---

## 七、复盘与延伸

### 一句话总结
> **dp[i][j] = 前 i 与前 j 的 LCS；相等抄左上加 1，不等取上/左较大。**

### 新手常见疑问（FAQ）

**Q1：子序列与子串区别？**
A：**子序列**不要求连续（abcde 的 ace 是子序列）；**子串**要连续。LC 5/LC 1143 类是子序列，LC 718 是子串。

**Q2：求"最长公共子串（连续）"怎么改？**
A：转移变成 `dp[i][j] = dp[i-1][j-1] + 1` 当相等时；不等时直接 `dp[i][j] = 0`（不能跨越）。答案取所有 dp 最大。LC 718。

**Q3：怎么还原 LCS 字符串？**
A：从 `dp[m][n]` 反向回溯：相等就加入并往左上走；不等就走 max 的方向。

**Q4：滚动数组里 `prev` 是什么？**
A：保存 `dp[i-1][j-1]`（左上角的旧值），在 `dp[j]` 被覆盖前保留下来。

**Q5：能否用 `Map` 记忆化递归？**
A：能。`memo(i, j) = ...`。代码更直观但常数大。

### 面试官常见 follow-up
1. **"最少删除使两串相等（[LC 583](https://leetcode.cn/problems/delete-operation-for-two-strings/)）？"** → 答案 = m + n - 2 * LCS。
2. **"编辑距离（[LC 72](https://leetcode.cn/problems/edit-distance/)）？"** → 三种操作 + 1。
3. **"最长公共子串（[LC 718](https://leetcode.cn/problems/maximum-length-of-repeated-subarray/)）？"** → 不等时 dp=0。
4. **"最长公共子序列的字典序最小？"** → 反向回溯时取字典序较小的字符。
5. **"三串 LCS？"** → 三维 dp[i][j][k]，O(n³)。
6. **"超长字符串（m,n=10^5）？"** → O(mn) 1e10 超时，需 Hunt-Szymanski / Bit-parallel 算法。

### 同类型推荐（**双串 DP 家族**）
- [LC 72. 编辑距离](https://leetcode.cn/problems/edit-distance/)
- [LC 583. 两个字符串的删除操作](https://leetcode.cn/problems/delete-operation-for-two-strings/)
- [LC 712. 两字符串的最小 ASCII 删除和](https://leetcode.cn/problems/minimum-ascii-delete-sum-for-two-strings/)
- [LC 718. 最长公共子数组](https://leetcode.cn/problems/maximum-length-of-repeated-subarray/)（子串）
- [LC 1035. 不相交的线](https://leetcode.cn/problems/uncrossed-lines/)（同 [LC 1143](https://leetcode.cn/problems/longest-common-subsequence/)）
- [LC 392. 判断子序列](https://leetcode.cn/problems/is-subsequence/)
- LC 115. 不同的子序列
