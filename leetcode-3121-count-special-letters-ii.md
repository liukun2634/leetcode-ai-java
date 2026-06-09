# [LeetCode 3121. 统计特殊字母的数量 II (Count the Number of Special Characters II)](https://leetcode.com/problems/count-the-number-of-special-characters-ii/)

> 难度：Medium　|　标签：哈希表、字符串、计数、一次遍历

---

## 一、题目

给你一个字符串 `word`。如果 `word` 中同时出现某个字母 `c` 的小写形式和大写形式，并且 **每个** 小写形式的 `c` 都出现在 **第一个** 大写形式的 `c` 之前，则称字母 `c` 是一个 **特殊字母**。

返回 `word` 中 **特殊字母** 的数量。

**约束**

- `1 <= word.length <= 2 * 10^5`
- `word` 仅由小写和大写英文字母组成

**示例**

| 输入 | 输出 | 说明 |
|---|---|---|
| `word = "aaAbcBC"` | `3`  | `a`、`b`、`c` 三个字母的所有小写都在其第一个大写之前 |
| `word = "abc"` | `0` | 没有任何字母同时出现大小写 |
| `word = "abBCab"` | `0` | `'b'`：第二个小写 `b`（下标 5）在第一个大写 `B`（下标 2）之后，不满足条件 |

---

## 二、解题思路（学习重点）

### 1. 题意翻译：把条件拆成"三个事件"

对每个字母 `c`，关注三个位置：

- `firstLower[c]`：**第一次**出现小写 `c` 的下标
- `lastLower[c]`：**最后一次**出现小写 `c` 的下标
- `firstUpper[c]`：**第一次**出现大写 `C` 的下标

`c` 是特殊字母 ⇔ 同时满足：

1. 既出现小写，又出现大写（`firstLower[c]` 与 `firstUpper[c]` 都存在）
2. `lastLower[c] < firstUpper[c]`（**最后一个**小写在**第一个**大写之前 ⇔ 所有小写都在第一个大写之前）

> **学习点 ①**：把"**每个** 小写都在第一个大写之前"等价转换为"**最后一个**小写 < 第一个大写"，把对集合的全称量词变成两点比较。

### 2. 一次遍历 + 两个数组即可

只需要 `lastLower[26]` 和 `firstUpper[26]`：

- 遍历时若是小写：更新 `lastLower[c] = i`（不断覆盖即可，最后留下的就是最后一次出现）
- 遍历时若是大写：仅在第一次出现时记录 `firstUpper[c] = i`

初始化：`lastLower[i] = -1`（表示未出现），`firstUpper[i] = n`（表示未出现，比任何下标都大，便于比较）

最后统计：`lastLower[c] != -1 && firstUpper[c] != n && lastLower[c] < firstUpper[c]` 的字母数。

> **学习点 ②**：用"哨兵值"（`-1` / `n`）替代显式存在性判断，但仍需在最终条件里检查两个哨兵——否则"只有小写无大写"的字母会被误判（如 `"abc"` 中 `0 < n` 数值上成立）。

### 3. 容易踩的坑

| 坑 | 对应处理 |
|---|---|
| 误用"第一个小写 < 第一个大写"，会把 `"aAa"` 误判为特殊 | 必须用 **`lastLower`**（最后一个小写） |
| 误用"最后一个小写 < 最后一个大写" | 题目要求是 **第一个** 大写之前，必须用 `firstUpper` |
| 字母没出现的边界 | 用 `-1` / `n` 哨兵；或显式判断都出现 |

---

## 三、Java 题解

### 解法 A：两个数组 + 一次遍历（推荐）

```java
class Solution {
    public int numberOfSpecialChars(String word) {
        int n = word.length();
        int[] lastLower  = new int[26];
        int[] firstUpper = new int[26];
        Arrays.fill(lastLower, -1);
        Arrays.fill(firstUpper, n);

        for (int i = 0; i < n; i++) {
            char ch = word.charAt(i);
            if (ch >= 'a' && ch <= 'z') {
                lastLower[ch - 'a'] = i;          // 一直覆盖 → 最终是最后一次
            } else {
                int c = ch - 'A';
                if (firstUpper[c] == n) firstUpper[c] = i; // 只记第一次
            }
        }

        int ans = 0;
        for (int c = 0; c < 26; c++) {
            // 三个条件缺一不可：小写出现过、大写出现过、最后小写 < 第一个大写
            if (lastLower[c] != -1 && firstUpper[c] != n && lastLower[c] < firstUpper[c]) ans++;
        }
        return ans;
    }
}
```

**记忆口诀**：
> **"最后一个小写 < 第一个大写，才是特殊。"**

### 解法 B：三状态标记（不需要下标，只需先后关系）

只用 `int state[26]` 表示每个字母当前所处阶段：

- `0`：尚未出现
- `1`：只见过小写
- `2`：见过小写后又见过大写（候选特殊）
- `3`：已被破坏（大写之后又出现小写）

```java
class Solution {
    public int numberOfSpecialChars(String word) {
        int[] state = new int[26];
        for (char ch : word.toCharArray()) {
            if (ch >= 'a' && ch <= 'z') {
                int c = ch - 'a';
                if (state[c] == 0) state[c] = 1;        // 第一次见小写
                else if (state[c] == 2) state[c] = 3;   // 大写之后又见小写 → 破坏
            } else {
                int c = ch - 'A';
                if (state[c] == 1) state[c] = 2;        // 小写之后第一次见大写 → 候选
                // state[c] == 0 (只见大写) 或 3 不变；2 时再见大写也保持 2
            }
        }
        int ans = 0;
        for (int s : state) if (s == 2) ans++;
        return ans;
    }
}
```

> **学习点 ③**：当只关心"先后顺序"而不关心具体下标时，**有限状态机**是更内聚的写法。

---

## 四、复杂度

| 解法 | 时间复杂度 | 空间复杂度 |
|---|---|---|
| 两个数组 | **O(n + Σ)** | O(Σ)，`Σ = 26` |
| 状态机 | **O(n + Σ)** | O(Σ) |

---

## 五、示例验证（手工跑一遍）

### 示例 1：`word = "aaAbcBC"`

下标：`0:a 1:a 2:A 3:b 4:c 5:B 6:C`

| 字母 | lastLower | firstUpper | 满足 `last < first` ? |
|---|---|---|---|
| a | 1 | 2 | ✅ |
| b | 3 | 5 | ✅ |
| c | 4 | 6 | ✅ |

输出 `3` ✅

### 示例 2：`word = "abc"`

整串没有任何大写字母。

| 字母 | lastLower | firstUpper | 判定 |
|---|---|---|---|
| a | 0 | n=3 | 大写未出现（`firstUpper==n`） → ✗ |
| b | 1 | n=3 | 大写未出现 → ✗ |
| c | 2 | n=3 | 大写未出现 → ✗ |

> **重要踩坑**：仅判断 `lastLower < firstUpper` 数值会让 `0 < 3` 成立而误算！必须同时判 `firstUpper[c] != n`。状态机解法天然不会出错——`a/b/c` 都停在 `state=1`，不计入答案。

输出 `0` ✅

### 示例 3：`word = "abBCab"`

下标：`0:a 1:b 2:B 3:C 4:a 5:b`

| 字母 | lastLower | firstUpper | 判定 |
|---|---|---|---|
| a | 4 | n=6 | firstUpper 不存在 → ✗ |
| b | 5 | 2 | `5 < 2` 假 → ✗ |
| c | -1 | 3 | lastLower 不存在 → ✗ |

输出 `0` ✅

---

## 六、复盘与延伸（提升记忆）

### 一句话总结
> **"每个小写都在第一个大写之前" = "最后一个小写 < 第一个大写"，两个数组一次遍历即可。**

### 自我提问（合上代码默答）
1. 为什么是 `lastLower < firstUpper`，而不是 `firstLower < firstUpper`？
   → 题目要求 **每个** 小写都在第一个大写之前，等价于小写出现的最大下标也在大写最小下标之前。
2. 哨兵值为何选 `-1` 和 `n`？
   → 让"未出现"成为容易识别的特殊值，但**仍需同时判 `lastLower != -1` 与 `firstUpper != n`**，否则"只有小写无大写"会被误算（数值上 `0 < n` 成立）。
3. 与 LC 3120（I）的区别？
   → 3120 只要求"同时出现大小写"即可；3121 多了"所有小写在第一个大写之前"的顺序约束。
4. 状态机解法能否扩展到"必须所有大写在最后一个小写之后 **且** 中间没有其他字符插入"？
   → 不能直接扩展，状态机只编码先后，不编码"连续"；要加额外字段。

### 同类型题推荐（巩固模板）
- LC 3120. 统计特殊字母的数量 I（同系列，只需判存在）
- LC 2351. 第一个出现两次的字母（一次遍历 + 位图）
- LC 2103. 环和杆（按位记录大写/小写）
- LC 387. 字符串中的第一个唯一字符（first/last 思想的入门）
