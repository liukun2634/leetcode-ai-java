# LeetCode 49. 字母异位词分组 (Group Anagrams)

> 难度：Medium　|　标签：哈希表、字符串、排序　|　**哈希分组模板 ⭐⭐**

---

## 一、题目

给你一个字符串数组，请你将 **字母异位词**（字母组成相同、顺序可不同的字符串）组合在一起。可以按任意顺序返回结果列表。

**约束**

- `1 <= strs.length <= 10^4`
- `0 <= strs[i].length <= 100`
- `strs[i]` 仅含小写字母

**示例**

| 输入 | 输出 |
|---|---|
| `["eat","tea","tan","ate","nat","bat"]` | `[["bat"],["nat","tan"],["ate","eat","tea"]]` |
| `[""]` | `[[""]]` |
| `["a"]` | `[["a"]]` |

题目链接：<https://leetcode.cn/problems/group-anagrams/>

---

## 二、解题思路（学习重点）

### 1. 核心：找一个"异位词共同身份证"

两个字符串是异位词 ⇔ 它们排序后相等 ⇔ 它们的字母计数相等。

只要把同一身份证下的字符串放到同一个桶里 → **HashMap<身份证, List<原串>>**。

**为什么这个思路简单**：暴力会两两比较 O(N²K)，需要拿每个串与其他串一一比。“身份证”的本质是把 O(K) 的“两个串是否同类”判断转为“一个串的哈希 key”，令哈希表在 O(1) 内完成分类。

**两种身份证可选**：
- **排序串**：`sorted(s)`，如 `"eat"→"aet"`，简单但 `O(L log L)`
- **计数串**：`int[26]` → 拼成形如 `"#1#0#1#0..."` 的字符串，`O(L)` 更快

> **学习点 ①**："分组问题"几乎都用 HashMap，**关键是设计一个让同类拥有同一 key 的函数**。

### 2. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 直接用 `int[26]` 当 key | 数组没重写 `hashCode/equals`，会按引用比较，**永远不相等** |
| 计数拼接时不加分隔符 | `"a"`：[1,0,...] 与 `"aaaa..."`：[12,0,...] 可能拼成同样字符串，**必须加分隔符** |
| Java 中 `char[]` 转 `String` | 用 `new String(arr)` 或 `String.valueOf(arr)` |

---

## 三、详细解题步骤

> **目标**：把所有字符串扫一遍，每个串算出它的"身份证"，按身份证分桶。

**步骤 1**：声明 `Map<String, List<String>> map = new HashMap<>();`

**步骤 2**：遍历输入 `for (String s : strs)`：
  1. 取出 `s` 的字符数组：`char[] arr = s.toCharArray();`
  2. 排序：`Arrays.sort(arr);`
  3. 转回字符串作为 key：`String key = new String(arr);`
  4. 把 `s` 放入对应桶：`map.computeIfAbsent(key, k -> new ArrayList<>()).add(s);`

**步骤 3**：返回 `new ArrayList<>(map.values());`

> 用计数串当 key 时，**步骤 2** 替换为：开 `int[26] cnt`，统计 `cnt[c - 'a']++`，然后用 `StringBuilder` 拼成 `"#1#0#1..."`。

---

## 四、Java 题解

### 解法 A：排序当 key（最短代码）

```java
class Solution {
    public List<List<String>> groupAnagrams(String[] strs) {
        Map<String, List<String>> map = new HashMap<>();
        for (String s : strs) {
            char[] arr = s.toCharArray();
            Arrays.sort(arr);
            String key = new String(arr);
            map.computeIfAbsent(key, k -> new ArrayList<>()).add(s);
        }
        return new ArrayList<>(map.values());
    }
}
```

### 解法 B：计数串当 key（更快，O(NK)）

```java
class Solution {
    public List<List<String>> groupAnagrams(String[] strs) {
        Map<String, List<String>> map = new HashMap<>();
        for (String s : strs) {
            int[] cnt = new int[26];
            for (char c : s.toCharArray()) cnt[c - 'a']++;
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 26; i++) sb.append('#').append(cnt[i]);
            map.computeIfAbsent(sb.toString(), k -> new ArrayList<>()).add(s);
        }
        return new ArrayList<>(map.values());
    }
}
```

**记忆口诀**：
> **"异位词 → 统一身份证（排序或计数），HashMap 一桶捞。"**

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 排序 key | O(N · K log K)，K = 最长串长度 | O(NK) |
| 计数 key | **O(N · K)** | O(NK) |

---

## 六、示例验证

`["eat","tea","tan","ate","nat","bat"]`，排序 key：

| 输入 | sorted | map |
|---|---|---|
| eat | "aet" | {aet:[eat]} |
| tea | "aet" | {aet:[eat,tea]} |
| tan | "ant" | {aet:[...], ant:[tan]} |
| ate | "aet" | {aet:[eat,tea,ate], ant:[tan]} |
| nat | "ant" | {..., ant:[tan,nat]} |
| bat | "abt" | {..., abt:[bat]} |

输出 `[[eat,tea,ate], [tan,nat], [bat]]` ✅

---

## 七、复盘与延伸

### 一句话总结
> **设计"同类同 key"的身份证函数，HashMap 自动分桶。**

### 新手常见疑问（FAQ）

**Q1：为什么 `int[26]` 不能直接当 key？**
A：Java 数组没有重写 `equals/hashCode`，默认按引用比较。两个内容相同的 `int[26]` 是不同对象，HashMap 会认为它们不相等。必须转为 `String` 或包装成 `List<Integer>`。

**Q2：拼计数串为什么要加分隔符 `#`？**
A：不加会冲突。如 `[1,12,0,...]` 和 `[11,2,0,...]` 不加分隔都是 `"1120..."`；加分隔后是 `#1#12#0...` vs `#11#2#0...`，唯一。

**Q3：排序版和计数版谁快？怎么选？**
A：单串长 K 时，排序 O(K log K)，计数 O(K)。K 越大计数越快。但排序版代码更短，面试遇到 K 很小（如 ≤ 100）可以直接写排序版；K 很大时主动提计数版。

**Q4：含大写字母 / Unicode 字符怎么办？**
A：计数数组改 `int[128]` （ASCII）或 `Map<Character, Integer>`（Unicode）；或直接用排序版，不受字符范围限制。

**Q5：HashMap 的初始容量要不要手工设？**
A：面试能说出“预估桶数避免 rehash”满分。如 `new HashMap<>(strs.length * 2)` 避免多次扩容；但不设也能 AC。

### 面试官常见 follow-up
1. **"判断两个串是否为异位词（不是分组）？"** → 直接比较计数数组是否相等，不需 HashMap。即 [**LC 242**](https://leetcode.cn/problems/valid-anagram/)。
2. **"在字符串 s 中找 p 的所有异位词子串？"** → 滑动窗口 + 计数数组。即 [**LC 438**](https://leetcode.cn/problems/find-all-anagrams-in-a-string/)。
3. **"多词共同字符（如查多串公共出现的字母）？"** → 多串计数数组取最小值。即 [**LC 1002**](https://leetcode.cn/problems/find-common-characters/)。
4. **"按字符出现频次排序输出字符串？"** → 计数后按 count 排序输出字符。即 [**LC 451**](https://leetcode.cn/problems/sort-characters-by-frequency/)。
5. **"如果输入是流，需要随时返回当前分组结果？"** → HashMap 天然支持，每来一个串算出 key 加入对应桶。
6. **"字串极长（K=10^5）但总量少（N=10）呢？"** → 仍然计数版更优；K 越大越别用排序版。

### 自我提问
1. 为什么 `int[26]` 不能直接当 key？→ 数组没有重写 `equals/hashCode`，HashMap 按引用比较，等价数组也不相等。
2. 排序版和计数版谁更快？→ 单串长 K 时，排序 O(K log K)，计数 O(K)；K 越大计数越快。
3. 大小写敏感 + 含其他字符怎么办？→ 计数数组改 `int[128]`；或直接用排序 key。

### 同类型推荐
- [LC 242. 有效的字母异位词](https://leetcode.cn/problems/valid-anagram/)
- [LC 438. 找到字符串中所有字母异位词](https://leetcode.cn/problems/find-all-anagrams-in-a-string/)（滑动窗口 + 计数）
- [LC 1002. 查找共用字符](https://leetcode.cn/problems/find-common-characters/)
- [LC 451. 根据字符出现频率排序](https://leetcode.cn/problems/sort-characters-by-frequency/)（计数 + 排序）
- [LC 1640. 能否连接形成数组](https://leetcode.cn/problems/check-array-formation-through-concatenation/)（哈希分组）
