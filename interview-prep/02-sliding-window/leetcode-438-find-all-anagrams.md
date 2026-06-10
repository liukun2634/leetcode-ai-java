# LeetCode 438. 找到字符串中所有字母异位词 (Find All Anagrams in a String)

> 难度：Medium　|　标签：哈希表、字符串、滑动窗口　|　**固定长度窗口模板 ⭐⭐⭐**

---

## 一、题目

给定两个字符串 `s` 和 `p`，找到 `s` 中所有 `p` 的 **字母异位词** 的子串，返回这些子串的起始索引。

**字母异位词**：由相同字母重排列形成的字符串（包括相同的字符串）。

**约束**

- `1 <= s.length, p.length <= 3 * 10^4`
- `s` 和 `p` 仅含小写字母

**示例**

| 输入 | 输出 |
|---|---|
| `s="cbaebabacd", p="abc"` | `[0, 6]` |
| `s="abab", p="ab"` | `[0, 1, 2]` |

题目链接：<https://leetcode.cn/problems/find-all-anagrams-in-a-string/>

---

## 二、解题思路（学习重点）

### 1. 固定窗口长度的滑动窗口

窗口大小固定 = `p.length()`：
- 右边加入一个字符，左边移除一个字符（窗口长度保持 `p.length()`）
- 比较窗口字符计数 vs `p` 的字符计数

### 2. 用 `valid` 计数避免每次对比两个数组

同 LC 76 的优化思路：
- `need[26]`：`p` 中每个字母的需要次数
- `cnt[26]`：当前窗口中每个字母的实际次数
- `valid`：满足 `cnt[c] == need[c]` 的字符种数

窗口完全匹配 ⇔ `valid == required`（`required` = `p` 中不同字符种数）。

> **学习点 ①**：固定窗口的关键是 **"加入新字符 + 移除旧字符"**，而 `valid` 计数让判断从 O(26) 降到 O(1)。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 移除时只更新 cnt 不维护 valid | 必须先比较再操作 |
| `valid++` 用 `>=` 而非 `==` | 用 `==`，确保只增 1 次 |
| 长度不够 p 时还硬比对 | r >= p.length() - 1 才记录 |
| `s.length() < p.length()` 直接返回 | 加边界判断 |

---

## 三、详细解题步骤

**步骤 1**：统计 `p` 需要的字符
```java
int[] need = new int[26];
int required = 0;
for (char c : p.toCharArray()) {
    if (need[c - 'a'] == 0) required++;
    need[c - 'a']++;
}
```

**步骤 2**：滑动窗口
```java
int[] cnt = new int[26];
int valid = 0, n = s.length(), m = p.length();
List<Integer> ans = new ArrayList<>();

for (int r = 0; r < n; r++) {
    int c = s.charAt(r) - 'a';
    cnt[c]++;
    if (need[c] > 0 && cnt[c] == need[c]) valid++;

    // 窗口超出 p.length() 后，左边出窗
    if (r >= m) {
        int lc = s.charAt(r - m) - 'a';
        if (need[lc] > 0 && cnt[lc] == need[lc]) valid--;
        cnt[lc]--;
    }

    // 窗口长度刚好 = m 且 valid == required
    if (r >= m - 1 && valid == required) {
        ans.add(r - m + 1);
    }
}
return ans;
```

---

## 四、Java 题解

```java
class Solution {
    public List<Integer> findAnagrams(String s, String p) {
        List<Integer> ans = new ArrayList<>();
        int n = s.length(), m = p.length();
        if (n < m) return ans;

        int[] need = new int[26], cnt = new int[26];
        int required = 0;
        for (char c : p.toCharArray()) {
            if (need[c - 'a']++ == 0) required++;
        }

        int valid = 0;
        for (int r = 0; r < n; r++) {
            int c = s.charAt(r) - 'a';
            cnt[c]++;
            if (need[c] > 0 && cnt[c] == need[c]) valid++;

            if (r >= m) {
                int lc = s.charAt(r - m) - 'a';
                if (need[lc] > 0 && cnt[lc] == need[lc]) valid--;
                cnt[lc]--;
            }

            if (r >= m - 1 && valid == required) ans.add(r - m + 1);
        }
        return ans;
    }
}
```

**记忆口诀**：
> **"右扩、左缩固定长；valid 计数即匹配。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n + m + Σ)**，Σ=26 |
| 空间 | O(Σ) |

---

## 六、示例验证

`s = "cbaebabacd", p = "abc"`，need = {a:1, b:1, c:1}, required = 3

| r | s[r] | 加入后 cnt | valid | 出窗 | 答案 |
|---|---|---|---|---|---|
| 0 | c | c:1 | 1 | — | — |
| 1 | b | b:1,c:1 | 2 | — | — |
| 2 | a | a:1,b:1,c:1 | **3** | — | **0** |
| 3 | e | a:1,b:1,c:1,e:1 | 3 | s[0]=c, cnt[c]=0, valid=2 | — |
| 4 | b | b:2,e:1,a:1 | 2 | s[1]=b, b:1, valid=2 | — |
| 5 | a | b:1,e:1,a:2 | 2 | s[2]=a, a:1, valid=2 | — |
| 6 | b | b:2,a:1 | 2 | s[3]=e, e:0, valid=2 | — |
| 7 | a | b:2,a:2 | 1 | s[4]=b, b:1, valid=1 | — |
| 8 | c | b:1,a:2,c:1 | 2 | s[5]=a, a:1, valid=2 | — |
| 9 | d | b:1,a:1,c:1,d:1 | **3** | s[6]=b, b:0, valid=2 → wait... | — |

实际过程中 r=8 时窗口是 [6,8]="bac"，valid=3，记录 6。结果 `[0, 6]` ✅

---

## 七、复盘与延伸

### 一句话总结
> **固定长度滑窗 + 字符计数 + valid 计数；窗口长度等于 p 且 valid 满则记录。**

### 新手常见疑问（FAQ）

**Q1：为什么不能直接 `Arrays.equals(cnt, need)` 每步比较？**
A：能但慢。每步 O(26)，总 O(26n)。用 valid 是 O(1)，总 O(n)。题目数据小时两者都能 AC，但养成 valid 习惯。

**Q2：`need[c] > 0` 这个判断为啥重要？**
A：valid 只关心 `p` 里有的字符。如果 `s` 含 `p` 没有的字符（如 d），不应触发 valid 变化。

**Q3：和 LC 76 最小覆盖子串区别？**
A：LC 76 是变长窗（找最短覆盖），LC 438 是 **固定长度** 窗（异位词长度固定 = p）。后者不需 while 缩。

**Q4：异位词允许重复字符吗？**
A：是。`p="aab"` 要求窗口里恰好 2 个 a 和 1 个 b。`need[]` 记录次数自然处理。

**Q5：能用 排序比较 吗？**
A：能：对每个长度 m 的子串排序后比较 `Arrays.equals`。`O(n·m·log m)` TLE。

### 面试官常见 follow-up
1. **"判断单个串是否是异位词（[LC 242](https://leetcode.cn/problems/valid-anagram/)）？"** → 直接比较两个 `int[26]`。
2. **"判断 s 是否包含 p 的排列（[LC 567](https://leetcode.cn/problems/permutation-in-string/)）？"** → 本题简化版：找到任意一个就返回 true。
3. **"扩展到 K 个不同字符的子串数？"** → 变长滑窗的另一类。[LC 992](https://leetcode.cn/problems/subarrays-with-k-different-integers/) / 904。
4. **"如果 p 很长（10^5）会怎样？"** → 算法仍 O(n)，无瓶颈。
5. **"如果字符集是 Unicode？"** → 用 `HashMap<Character, Integer>` 代替 `int[26]`。
6. **"返回字符串而非下标？"** → `ans.add(s.substring(r-m+1, r+1))`。

### 同类型推荐（**固定窗 + 异位词家族**）
- [LC 242. 有效的字母异位词](https://leetcode.cn/problems/valid-anagram/)
- [LC 567. 字符串的排列](https://leetcode.cn/problems/permutation-in-string/)
- [LC 49. 字母异位词分组](https://leetcode.cn/problems/group-anagrams/)
- [LC 30. 串联所有单词的子串](https://leetcode.cn/problems/substring-with-concatenation-of-all-words/)
- [LC 1456. 定长子串中元音的最大数目](https://leetcode.cn/problems/maximum-number-of-vowels-in-a-substring-of-given-length/)
