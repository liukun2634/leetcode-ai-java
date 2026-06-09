# [LeetCode 72. 编辑距离 (Edit Distance)](https://leetcode.com/problems/edit-distance/)

> 难度：Medium（其实是 🔴 难度的中等题）　|　标签：字符串、动态规划　|	|	**二维 DP 天花板 ⭐⭐⭐⭐**

---

## 一、题目

给你两个单词 `word1` 和 `word2`，请返回将 `word1` 转换成 `word2` 所使用的最少操作数。

你可以对一个单词进行如下三种操作：
- **插入** 一个字符
- **删除** 一个字符
- **替换** 一个字符

**约束**

- `0 <= word1.length, word2.length <= 500`

**示例**

| 输入 | 输出 | 操作 |
|---|---|---|
| `horse, ros` | `3` | horse→rorse(替换)→rose(删除)→ros(删除) |
| `intention, execution` | `5` | 多步替换 |

---

## 二、解题思路（学习重点）

### 1. 状态定义

`dp[i][j]` = "把 `word1` 的前 `i` 个字符变成 `word2` 的前 `j` 个字符所需的最少操作数"。

### 2. 状态转移（**面试必能现场推导**）

考虑 `dp[i][j]`：
- 若 `word1[i-1] == word2[j-1]`（最后一个字符相同）：
  $$dp[i][j] = dp[i-1][j-1]$$
  无需操作，直接继承。

- 否则取三种操作的最小值 + 1：
  - **替换**：`dp[i-1][j-1] + 1`（把 `word1[i-1]` 换成 `word2[j-1]`）
  - **删除**：`dp[i-1][j] + 1`（删掉 `word1[i-1]`，问题缩为前 i-1 对 j）
  - **插入**：`dp[i][j-1] + 1`（在 `word1` 末尾插入 `word2[j-1]`，问题缩为前 i 对 j-1）

### 3. 初始化

- `dp[0][j] = j`：把空串变成长 j 的串，需要插入 j 次。
- `dp[i][0] = i`：把长 i 的串变成空串，需要删除 i 次。

> **学习点 ①**：**双字符串 DP 的状态总是 `dp[i][j]`**。LCS（LC 1143）、LIS 双串变种、删除得相等（LC 583）都是同模板。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 状态定义里 `i, j` 是长度还是下标？ | **本题用长度**：`dp[i][j]` 是前 i 个 / 前 j 个 |
| 比较字符时下标偏移 | 用 `word1.charAt(i-1)` 和 `word2.charAt(j-1)` |
| 初始化只写 `dp[0][0]=0`，忘了第一行和第一列 | 必须把 `dp[0][j]=j`、`dp[i][0]=i` 全填 |

---

## 三、详细解题步骤

**步骤 1**：初始化二维数组
```java
int m = word1.length(), n = word2.length();
int[][] dp = new int[m + 1][n + 1];
for (int i = 0; i <= m; i++) dp[i][0] = i;
for (int j = 0; j <= n; j++) dp[0][j] = j;
```

**步骤 2**：双重循环填表
```java
for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
        if (word1.charAt(i-1) == word2.charAt(j-1)) {
            dp[i][j] = dp[i-1][j-1];
        } else {
            dp[i][j] = 1 + Math.min(dp[i-1][j-1],            // 替换
                          Math.min(dp[i-1][j], dp[i][j-1])); // 删 / 插
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
    public int minDistance(String word1, String word2) {
        int m = word1.length(), n = word2.length();
        int[][] dp = new int[m + 1][n + 1];
        for (int i = 0; i <= m; i++) dp[i][0] = i;
        for (int j = 0; j <= n; j++) dp[0][j] = j;

        for (int i = 1; i <= m; i++) {
            for (int j = 1; j <= n; j++) {
                if (word1.charAt(i-1) == word2.charAt(j-1)) {
                    dp[i][j] = dp[i-1][j-1];
                } else {
                    dp[i][j] = 1 + Math.min(dp[i-1][j-1],
                                  Math.min(dp[i-1][j], dp[i][j-1]));
                }
            }
        }
        return dp[m][n];
    }
}
```

**记忆口诀**：
> **"相等抄左上；否则 1 + min(左上替, 上删, 左插)。"**

### 解法 B：滚动数组 O(n) 空间

```java
class Solution {
    public int minDistance(String word1, String word2) {
        int m = word1.length(), n = word2.length();
        int[] dp = new int[n + 1];
        for (int j = 0; j <= n; j++) dp[j] = j;

        for (int i = 1; i <= m; i++) {
            int prev = dp[0];                   // 保存"左上"对应的旧值
            dp[0] = i;
            for (int j = 1; j <= n; j++) {
                int temp = dp[j];               // 保存即将被覆盖的"上"
                if (word1.charAt(i-1) == word2.charAt(j-1)) {
                    dp[j] = prev;
                } else {
                    dp[j] = 1 + Math.min(prev, Math.min(dp[j], dp[j-1]));
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

`word1 = "horse", word2 = "ros"`，填表：

```
       ""  r  o  s
   "" [ 0  1  2  3]
   h  [ 1  1  2  3]
   o  [ 2  2  1  2]
   r  [ 3  2  2  2]
   s  [ 4  3  3  2]
   e  [ 5  4  4  3]
```

`dp[5][3] = 3` ✅

逐步推导关键格：
- `dp[1][1]` (h vs r)：不等 → `1 + min(dp[0][0]=0, dp[0][1]=1, dp[1][0]=1) = 1`
- `dp[2][2]` (o vs o)：相等 → `dp[1][1] = 1`
- `dp[5][3]` (e vs s)：不等 → `1 + min(dp[4][2]=3, dp[4][3]=2, dp[5][2]=3) = 3`

---

## 七、复盘与延伸

### 一句话总结
> **`dp[i][j]` = "前 i 变前 j"；相等抄左上，否则 1 + 三种操作的最小。**

### 新手常见疑问（FAQ）

**Q1：为什么三种操作分别对应 `dp[i-1][j-1] / dp[i-1][j] / dp[i][j-1]`？**
A：
- **替换**：把 `word1[i-1]` 改成 `word2[j-1]`，问题剩 `dp[i-1][j-1]`。
- **删除**：删 `word1[i-1]`，剩 `dp[i-1][j]`。
- **插入**：在 word1 末尾插 `word2[j-1]`，问题剩 `dp[i][j-1]`。

**Q2：`dp[i][j]` 里的 i、j 是长度还是下标？**
A：本题用长度（「前 i 个」「前 j 个」）。比较字符时用 `word1.charAt(i-1)`。初始化的第一行第一列 i, j 从 0 开始达成边界。

**Q3：滑动数组版本 `prev` 变量是干什么的？**
A：一维 dp 代替二维后，`dp[j]` 被覆盖后“左上角”信息丢失。用 `prev` 在覆盖前保存 `dp[j-1]` 的上一轮值（即当前 (i,j) 的左上角）。

**Q4：可以只考虑「插入 + 删除」不允许「替换」吗？**
A：LC 583：那时问题转为求 LCS，答案 = `m + n - 2 * LCS(word1, word2)`。

**Q5：怎么返回具体操作序列？**
A：从 `dp[m][n]` 反向回溯：比较 dp[i][j] 是从哪个相邻状态转移过来的，按来源反推“替/删/插/不动”。

### 面试官常见 follow-up
1. **"只能插入与删除（LC 583）？"** → 转化为 LCS：答 = `m + n - 2·LCS`。
2. **"不同操作代价不同？"** → `+1` 改成 `+c_replace / +c_delete / +c_insert`，其余不变。
3. **"求最小 ASCII 删除和（LC 712）？"** → `+1` 改成 `+字符 ASCII`。
4. **"判是子序列（LC 392）？"** → 双指针一遍扫；DP 也可，但双指针 O(n+m) 更优。
5. **"有多少种不同的子序列变成 word2（LC 115）？"** → 另一种双串 DP：`dp[i][j]` = `dp[i-1][j-1] + dp[i-1][j]`（匹配时） / `dp[i-1][j]`（不匹配）。
6. **"正则表达式匹配（LC 10） / 通配符匹配（LC 44）？"** → 同是双串 DP，但多一些状态划分（`*`、`?`、`.`）。

### 同类型推荐（**双串 DP 家族**）
- LC 1143. 最长公共子序列（LCS，模板姊妹题）
- LC 583. 两个字符串的删除操作
- LC 712. 两个字符串的最小 ASCII 删除和
- LC 392. 判断子序列（DP / 双指针）
- LC 115. 不同的子序列
- LC 97. 交错字符串
- LC 10. 正则表达式匹配（带通配符的 DP）
- LC 44. 通配符匹配
