# Java 集合 · LeetCode 速查手册

> **目的**：刷题时不再卡在「这个容器在 Java 里叫啥」「哪个方法名是 `peek` 哪个是 `poll`」。
> 全部以「**LeetCode 实战写法**」为优先，舍弃 Vector / Hashtable / Stack 等不推荐的旧 API。

---

## 📂 文档索引

| 主题 | 核心类 | 一句话用途 |
|---|---|---|
| [01 · 数组与字符串](./01-array-and-string.md) | `int[]` · `String` · `StringBuilder` · `char[]` | 最基础但坑最多：排序、拷贝、`int[]` ↔ `List<Integer>` 互转 |
| [02 · 列表 / 栈 / 队列 / 双端队列](./02-list-stack-queue.md) | `ArrayList` · `LinkedList` · `ArrayDeque` · `Deque` | 一份表搞清楚「**Java 里栈和队列都用 `ArrayDeque`**」 |
| [03 · 堆 · PriorityQueue](./03-heap-priorityqueue.md) | `PriorityQueue` | 大顶堆、自定义 comparator、TopK 模板 |
| [04 · 哈希 / 有序映射 · Map & Set](./04-map-set.md) | `HashMap` · `HashSet` · `TreeMap` · `TreeSet` · `LinkedHashMap` | `getOrDefault` / `merge` / `floorKey` / LRU 写法 |
| [05 · 自定义结构 · 链表 & 树节点](./05-linked-list-and-tree.md) | `ListNode` · `TreeNode` · `Pair`-style | 自己定义节点 + 常用辅助函数 |
| [06 · 常见转换与陷阱](./06-conversions-and-pitfalls.md) | `Arrays` · `Collections` · `Stream` | `int[]` ↔ `Integer[]` ↔ `List<Integer>`、自动装箱坑 |
| [07 · 常用 Java 函数速查](./07-common-functions.md) | `Math` · `Integer` · `Character` · `Comparator` · `Random` · `BigInteger` | 数学/位运算/字符判断/格式化/比较器组合 |
| [08 · 并查集 · Union-Find](./08-union-find.md) | `UnionFind` (DSU) | 连通分量、Kruskal、判环、动态等价类 |
| [09 · 前缀树 · Trie](./09-trie.md) | `Trie` / 01-Trie | 单词字典、前缀计数、最大异或 (LC 421) |

---

## ⚡ 一分钟选型

| 我需要…… | 选 | 关键 API |
|---|---|---|
| **数组**（固定长度，最快） | `int[]` | `Arrays.sort`、`Arrays.copyOfRange`、`Arrays.fill` |
| **可变长度列表** | `ArrayList<T>` | `add` `get` `set` `remove(int)` |
| **栈** | `Deque<T> st = new ArrayDeque<>();` | `push` / `pop` / `peek` |
| **队列（FIFO）** | `Deque<T> q = new ArrayDeque<>();` | `offer` / `poll` / `peek` |
| **双端队列 / 单调队列** | `Deque<T>` (= `ArrayDeque`) | `offerFirst/Last`、`pollFirst/Last`、`peekFirst/Last` |
| **小顶堆 / 大顶堆** | `PriorityQueue<T>` | `offer` / `poll` / `peek`，构造时传 comparator |
| **哈希表** | `HashMap<K,V>` | `getOrDefault` / `merge` / `computeIfAbsent` |
| **哈希集合** | `HashSet<T>` | `add` / `contains` / `remove` |
| **有序映射**（按 key 排序、二分） | `TreeMap<K,V>` | `floorKey` / `ceilingKey` / `firstKey` |
| **保持插入顺序的 Map**（LRU） | `LinkedHashMap` | 构造第三个参数 `accessOrder=true` |
| **字符串拼接** | `StringBuilder` | `append` / `reverse` / `toString` / `deleteCharAt` |
| **动态连通分量 / 并集** | `UnionFind` (DSU) | `find` / `union` / `count` |
| **字符串字典 / 前缀查询** | `Trie` | `insert` / `search` / `startsWith` |

> **记忆口诀**：**「栈和队列都用 `Deque`，声明面用 `Deque`，实例用 `ArrayDeque`。」**
> 别用 `java.util.Stack`（继承 `Vector`，方法 `synchronized` 慢且 push/pop 含义和 `Deque` 矛盾）。

---

## 🚫 不要再用的「旧 API」

| 旧 API | 替代 | 原因 |
|---|---|---|
| `Stack<T>` | `Deque<T> = new ArrayDeque<>()` | `Stack` 继承 `Vector`，方法 `synchronized`；遍历顺序反直觉 |
| `Vector<T>` | `ArrayList<T>` | 同上 |
| `Hashtable<K,V>` | `HashMap<K,V>` | 同上，且不允许 `null` |
| `new LinkedList<>()` 当队列 | `new ArrayDeque<>()` | `ArrayDeque` 没有节点对象开销，更快 |
| `Collections.synchronizedList(...)` | LeetCode 单线程不需要 | 同步开销纯浪费 |

---

## 🛠 模板代码框架（写题时直接复用）

```java
import java.util.*;

class Solution {
    public int example(int[] nums) {
        // —— 哈希
        Map<Integer, Integer> cnt = new HashMap<>();
        for (int x : nums) cnt.merge(x, 1, Integer::sum);

        // —— 栈
        Deque<Integer> stack = new ArrayDeque<>();
        stack.push(1); stack.pop(); stack.peek();

        // —— 队列 / 双端队列
        Deque<Integer> queue = new ArrayDeque<>();
        queue.offer(1); queue.poll(); queue.peek();

        // —— 堆（小顶堆默认）
        PriorityQueue<Integer> pq = new PriorityQueue<>();
        PriorityQueue<int[]> pq2 = new PriorityQueue<>((a, b) -> a[0] - b[0]);

        // —— 有序集合
        TreeMap<Integer, Integer> tm = new TreeMap<>();
        tm.floorKey(5); tm.ceilingKey(5);

        return 0;
    }
}
```

---

## 📎 相关

- 题解模板：[`../../interview-prep/README.md`](../../interview-prep/README.md)
- 本地跑题：[`../java-leetcode-io-template/README.md`](../java-leetcode-io-template/README.md)
- 通用 I/O：[`../java-io-template/README.md`](../java-io-template/README.md)
