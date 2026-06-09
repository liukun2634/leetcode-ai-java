# LeetCode 208. 实现 Trie (前缀树) (Implement Trie / Prefix Tree)

> 难度：Medium　|　标签：字典树、设计　|　**Trie 模板 ⭐⭐⭐**

---

## 一、题目

实现 `Trie` 类：
- `Trie()` 初始化前缀树对象
- `void insert(String word)` 向前缀树中插入字符串 `word`
- `boolean search(String word)` 如果字符串 `word` 在前缀树中，返回 `true`；否则 `false`
- `boolean startsWith(String prefix)` 如果之前已经插入的字符串 `word` 的 **前缀** 之一为 `prefix`，返回 `true`；否则 `false`

**约束**

- `1 <= word.length, prefix.length <= 2000`
- 仅含小写字母
- 调用次数 `≤ 3 * 10^4`

**示例**

```
Trie trie = new Trie();
trie.insert("apple");
trie.search("apple");    // true
trie.search("app");      // false
trie.startsWith("app");  // true
trie.insert("app");
trie.search("app");      // true
```

题目链接：<https://leetcode.cn/problems/implement-trie-prefix-tree/>

---

## 二、解题思路（学习重点）

### 1. Trie 节点结构

```java
class TrieNode {
    TrieNode[] children = new TrieNode[26];  // 26 个字母
    boolean isEnd;                            // 标记是否为某个单词的结尾
}
```

每个节点代表一个字符位置，孩子数组用下标 `c - 'a'` 索引。

> **学习点 ①**：Trie 适用 **"按字符前缀检索"** 的场景 —— 通讯录、自动补全、单词搜索（LC 212）、IP 路由前缀匹配等。

### 2. 三个操作

**insert(word)**：从根开始，逐字符下沉；缺孩子则 new，最后标 `isEnd = true`。

**search(word)**：逐字符下沉；缺孩子返回 false；走完后看 `isEnd`。

**startsWith(prefix)**：逐字符下沉；缺孩子返回 false；**走完直接返回 true**（不看 isEnd）。

### 3. search vs startsWith 区别

- `search` 要求"恰好是一个完整单词" → 必须 `isEnd`
- `startsWith` 只要求"是某个单词的前缀" → 路径存在即可

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 用 `HashMap<Character, TrieNode>` | 数组 `TrieNode[26]` 更快（字符集小） |
| 忘记 `isEnd` → search "app" 返回 true | 必须区分前缀和完整词 |
| 用 `c - 'a'` 时含其他字符越界 | 题目保证小写，否则用 HashMap |
| 删除时只设 `isEnd = false` 留下孤儿节点 | 严格删除要递归回溯 |

---

## 三、详细解题步骤

**步骤 1**：定义节点
```java
class TrieNode {
    TrieNode[] children = new TrieNode[26];
    boolean isEnd = false;
}
```

**步骤 2**：根节点
```java
private final TrieNode root = new TrieNode();
```

**步骤 3**：insert
```java
public void insert(String word) {
    TrieNode cur = root;
    for (char c : word.toCharArray()) {
        int idx = c - 'a';
        if (cur.children[idx] == null) cur.children[idx] = new TrieNode();
        cur = cur.children[idx];
    }
    cur.isEnd = true;
}
```

**步骤 4**：search / startsWith 共享下沉逻辑
```java
private TrieNode findNode(String s) {
    TrieNode cur = root;
    for (char c : s.toCharArray()) {
        int idx = c - 'a';
        if (cur.children[idx] == null) return null;
        cur = cur.children[idx];
    }
    return cur;
}
public boolean search(String word)        { TrieNode n = findNode(word);   return n != null && n.isEnd; }
public boolean startsWith(String prefix)  { return findNode(prefix) != null; }
```

---

## 四、Java 题解

```java
class Trie {
    private static class TrieNode {
        TrieNode[] children = new TrieNode[26];
        boolean isEnd = false;
    }

    private final TrieNode root = new TrieNode();

    public void insert(String word) {
        TrieNode cur = root;
        for (char c : word.toCharArray()) {
            int idx = c - 'a';
            if (cur.children[idx] == null) cur.children[idx] = new TrieNode();
            cur = cur.children[idx];
        }
        cur.isEnd = true;
    }

    public boolean search(String word) {
        TrieNode n = findNode(word);
        return n != null && n.isEnd;
    }

    public boolean startsWith(String prefix) {
        return findNode(prefix) != null;
    }

    private TrieNode findNode(String s) {
        TrieNode cur = root;
        for (char c : s.toCharArray()) {
            int idx = c - 'a';
            if (cur.children[idx] == null) return null;
            cur = cur.children[idx];
        }
        return cur;
    }
}
```

**记忆口诀**：
> **"insert 下沉建节点；search 看 isEnd；startsWith 只看路径在。"**

---

## 五、复杂度

| 操作 | 时间 | 空间 |
|---|---|---|
| insert / search / startsWith | **O(L)**，L 为字符串长度 | O(Σ · 总字符数) |

---

## 六、示例验证

```
insert("apple")     → root - a - p - p - l - e(end)
search("apple")     → 走 a-p-p-l-e, isEnd=true → true ✅
search("app")       → 走 a-p-p, isEnd=false → false ✅
startsWith("app")   → 走 a-p-p, 路径存在 → true ✅
insert("app")       → 走 a-p-p, 标 isEnd=true
search("app")       → true ✅
```

---

## 七、复盘与延伸

### 一句话总结
> **Trie = 字符位 + 孩子数组 + isEnd 标记；insert/search/startsWith 都是 O(L) 下沉。**

### 新手常见疑问（FAQ）

**Q1：为什么需要 Trie 而不是 HashSet？**
A：HashSet 能 O(1) 查整词存在，但 **无法 O(prefix.length) 查前缀**。Trie 天然支持前缀查询。

**Q2：用数组还是 HashMap 存孩子？**
A：字符集小（26 字母）用 `TrieNode[26]`，常数小；字符集大或 Unicode 用 `HashMap<Character, TrieNode>`。

**Q3：空间复杂度怎么算？**
A：最坏 `O(Σ × 总字符数)`。如果单词共享前缀多，空间更省。

**Q4：怎么实现删除？**
A：递归向下找到对应节点，把 isEnd = false；如果该节点没有孩子且不是其他词的中间，可以反向删除整条链。

**Q5：Trie vs 哈希表性能？**
A：插入/查询都是 O(L)。哈希表插入/查询期望 O(L)（计算 hash）但常数小；Trie 在前缀场景碾压哈希。

### 面试官常见 follow-up
1. **"支持通配符 . 的 search（LC 211）？"** → 遇到 . 时递归尝试所有 26 个孩子。
2. **"单词搜索 II（LC 212）？"** → Trie + DFS 在棋盘上回溯。
3. **"最长公共前缀（LC 14）？"** → 建 Trie 后从根走到第一个分叉。
4. **"自动补全/搜索建议（LC 642/1268）？"** → Trie + DFS 收集所有以前缀开头的词。
5. **"按字典序最长的子串（LC 720）？"** → Trie + DFS，所有节点路径必须 isEnd。
6. **"Trie 节点过多内存爆炸？"** → 压缩前缀树（Radix tree），合并独子链。

### 同类型推荐（**Trie 家族**）
- LC 211. 添加与搜索单词（含 . 通配符）
- LC 212. 单词搜索 II（Trie + DFS）
- LC 14. 最长公共前缀
- LC 720. 词典中最长的单词
- LC 648. 单词替换
- LC 421. 数组中两个数的最大异或值（**Trie 位树**）
- LC 1268. 搜索推荐系统
