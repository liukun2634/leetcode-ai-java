# 09 · 前缀树 · Trie

> **用途**：高效存一组字符串，支持"前缀匹配 / 完整匹配 / 前缀计数"。
> **典型场景**：自动补全、敏感词过滤、单词搜索（LC 208 / 211 / 212）、最长公共前缀、IP 路由、异或最大值（01-Trie，LC 421）。
> 时间：插入 / 查询都是 **O(单词长度)**，与字典大小无关。

---

## 一、数组版（小写字母专用，最快）

> **推荐用于 LeetCode**：固定 26 个孩子用数组，比 `Map` 快好几倍。

```java
class Trie {
    Trie[] children = new Trie[26];
    boolean isEnd;

    public void insert(String word) {
        Trie node = this;
        for (char c : word.toCharArray()) {
            int i = c - 'a';
            if (node.children[i] == null) node.children[i] = new Trie();
            node = node.children[i];
        }
        node.isEnd = true;
    }

    public boolean search(String word) {
        Trie node = find(word);
        return node != null && node.isEnd;
    }

    public boolean startsWith(String prefix) {
        return find(prefix) != null;
    }

    private Trie find(String s) {
        Trie node = this;
        for (char c : s.toCharArray()) {
            int i = c - 'a';
            if (node.children[i] == null) return null;
            node = node.children[i];
        }
        return node;
    }
}
```

---

## 二、`Map` 版（任意字符 / Unicode）

```java
class Trie {
    Map<Character, Trie> children = new HashMap<>();
    boolean isEnd;

    public void insert(String word) {
        Trie node = this;
        for (char c : word.toCharArray()) {
            node = node.children.computeIfAbsent(c, k -> new Trie());
        }
        node.isEnd = true;
    }

    public boolean search(String word) {
        Trie node = find(word);
        return node != null && node.isEnd;
    }

    public boolean startsWith(String prefix) {
        return find(prefix) != null;
    }

    private Trie find(String s) {
        Trie node = this;
        for (char c : s.toCharArray()) {
            node = node.children.get(c);
            if (node == null) return null;
        }
        return node;
    }
}
```

> 用于：含大小写 / 数字 / 中文等非 26 字母的输入。

---

## 三、扩展功能

### 1. 通配符匹配（LC 211 `WordDictionary`）

`.` 匹配任意单个字符，遇到 `.` 就遍历所有非空孩子做 DFS：

```java
public boolean search(String word) {
    return dfs(this, word, 0);
}
private boolean dfs(Trie node, String w, int i) {
    if (i == w.length()) return node.isEnd;
    char c = w.charAt(i);
    if (c == '.') {
        for (Trie child : node.children) {
            if (child != null && dfs(child, w, i + 1)) return true;
        }
        return false;
    }
    Trie nxt = node.children[c - 'a'];
    return nxt != null && dfs(nxt, w, i + 1);
}
```

### 2. 前缀计数（每个节点存"经过多少次"）

```java
class Trie {
    Trie[] children = new Trie[26];
    int pass;       // 多少个单词经过此节点
    int end;        // 多少个单词在此结束

    public void insert(String w) {
        Trie node = this;
        for (char c : w.toCharArray()) {
            int i = c - 'a';
            if (node.children[i] == null) node.children[i] = new Trie();
            node = node.children[i];
            node.pass++;
        }
        node.end++;
    }
    public int countPrefix(String p) {
        Trie node = this;
        for (char c : p.toCharArray()) {
            int i = c - 'a';
            if (node.children[i] == null) return 0;
            node = node.children[i];
        }
        return node.pass;
    }
}
```

### 3. Trie + DFS（LC 212 单词搜索 II）

```java
// 把所有单词建 Trie，然后在网格里 DFS，每步顺着 Trie 走，走不到就剪枝
// 找到 isEnd 的节点就 res.add；为防止重复，把命中的单词清空 isEnd
```

> 模板核心：**Trie 让"同时搜多个目标单词"从 O(W × 网格搜索) 降到 O(网格搜索)**，是字典搜索的标配剪枝。

---

## 四、01-Trie：解决"最大异或对"（LC 421）

> 把每个数当成 32 位二进制串插入 Trie，查询时**贪心走相反位**让异或最大。

```java
class XorTrie {
    XorTrie[] children = new XorTrie[2];

    public void insert(int num) {
        XorTrie node = this;
        for (int i = 31; i >= 0; i--) {
            int b = (num >> i) & 1;
            if (node.children[b] == null) node.children[b] = new XorTrie();
            node = node.children[b];
        }
    }

    // 返回 num 与树中已有数的最大异或
    public int maxXor(int num) {
        XorTrie node = this;
        int res = 0;
        for (int i = 31; i >= 0; i--) {
            int b = (num >> i) & 1;
            int want = 1 - b;       // 想走相反位
            if (node.children[want] != null) {
                res |= (1 << i);
                node = node.children[want];
            } else {
                node = node.children[b];
            }
        }
        return res;
    }
}
```

主流程：

```java
public int findMaximumXOR(int[] nums) {
    XorTrie trie = new XorTrie();
    int ans = 0;
    for (int x : nums) {
        trie.insert(x);
        ans = Math.max(ans, trie.maxXor(x));
    }
    return ans;
}
```

---

## 五、复杂度对照

| 操作 | 数组版 | Map 版 |
|---|---|---|
| 插入 / 查询 / 前缀 | O(L)，L = 单词长度 | O(L)（含 hash 开销） |
| 空间 | 每节点 26 个指针 → 内存大但常数稳定 | 按需分配，省内存但 hash 开销大 |
| LeetCode 推荐 | ✅ 小写字母用这个 | 字符集大 / Unicode 用这个 |

---

## 六、常见坑

| 坑 | 现象 | 解决 |
|---|---|---|
| `isEnd` 忘标 / 忘判 | `search("ab")` 误返 true | 插入时末节点 `isEnd = true`；search 必判 |
| 用 `String.contains` 模拟 | TLE | 多目标匹配请用 Trie 或 AC 自动机 |
| 数组版用错下标 | NPE / 越界 | `c - 'a'` 仅限小写；大写要 `c - 'A'`；混合用 Map 版 |
| 大量短字符串 + 字符集大 | 数组版内存爆 | 换 Map 版 |
| 反复 `new Trie()` 慢 | 大数据集 TLE | 用**静态数组 Trie**（见下） |

### 静态数组 Trie（极限性能版）

```java
static int[][] trie = new int[MAX_NODES][26];
static boolean[] isEnd = new boolean[MAX_NODES];
static int cnt = 0;   // 已分配节点数，根节点为 0

static void insert(String w) {
    int p = 0;
    for (char c : w.toCharArray()) {
        int i = c - 'a';
        if (trie[p][i] == 0) trie[p][i] = ++cnt;
        p = trie[p][i];
    }
    isEnd[p] = true;
}
```

> 适合内存紧张 / TLE 时的优化版。`MAX_NODES` 估 = 字符串总长 + 1。

---

## 七、回顾自测

1. Trie 查询一个长度为 L 的字符串复杂度？
2. 26 字母用数组孩子比 `Map` 快多少？
3. `isEnd` 字段干嘛的，能不能省？
4. LC 421 最大异或对，为什么按 31 位高位到低位插入？
5. 实现"以某前缀开头的单词数"要在节点上加什么字段？

<details>
<summary>答案</summary>

1. **O(L)**，与字典里有多少个单词无关。
2. 通常 3–10 倍。数组访问是常数，`HashMap.get` 有 hash + 链表遍历开销。
3. 区分"作为完整单词存在"和"只是某单词的前缀"。**不能省**，否则 `search("ab")` 在只插入了 `"abc"` 时会误判 true。
4. 高位决定数值大小，贪心要从最高位开始尽量异或出 1。
5. 节点上加 `int pass`，插入时一路 `pass++`，查询前缀走到末节点取 `pass`。

</details>
