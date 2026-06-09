# [LeetCode 460. LFU 缓存 (LFU Cache)](https://leetcode.com/problems/lfu-cache/)

> 难度：Hard　|　标签：设计、哈希、双向链表　|　**LRU 升级版 ⭐⭐⭐⭐⭐**

---

## 一、题目

请你为 **最不经常使用（LFU）** 缓存算法设计并实现数据结构。

实现 `LFUCache` 类：
- `LFUCache(int capacity)` 用容量初始化对象
- `int get(int key)` 若 key 存在则返回值，否则返回 `-1`
- `void put(int key, int value)` 若 key 已存在则更新值；否则插入。如果插入导致容量超出，**逐出"使用频次最少"** 的 key；若有多个频次相同的，**逐出"最久未使用"** 的 key。

为了确定最不常使用的键，**使用计数器（频次）** 来标识键。每次 get 或 put 后，频次 +1。**所有操作都要 O(1) 时间复杂度。**

**约束**

- `1 <= capacity <= 10^4`
- `0 <= key, value <= 10^9`
- 调用次数 `≤ 2 * 10^5`

---

## 二、解题思路（学习重点）

### 1. 比 LRU 多一个维度：频次

LRU（LC 146）只按"最久未用"逐出；LFU 多一个 **频次** 维度：
- 先按 **频次最小** 逐出
- 频次相同时按 **最久未用** 逐出

→ 需要 **"频次桶 → 双向链表（按访问顺序）"** 的两层结构。

### 2. 数据结构设计

| 结构 | 作用 |
|---|---|
| `Map<Integer, Node> keyToNode` | O(1) 按 key 拿到节点 |
| `Map<Integer, DoublyLinkedList> freqToList` | O(1) 按频次拿到桶 |
| `int minFreq` | 当前所有节点中最小的频次 |

**Node**：`{key, val, freq, prev, next}`。

每个桶是双向链表：**头部最新、尾部最旧**。

### 3. get 操作

```text
get(key):
    若 key 不存在 → 返回 -1
    取出 node
    把 node 从 freqToList[node.freq] 移除
    若该桶为空且 node.freq == minFreq → minFreq++
    node.freq++
    把 node 加入 freqToList[node.freq] 的头部
    返回 node.val
```

### 4. put 操作

```text
put(key, value):
    若 capacity == 0 → return
    若 key 已存在 → 更新 val + 等同 get 操作
    否则：
        若 size == capacity → 从 freqToList[minFreq] 的尾部逐出
        新建 node (freq=1)
        加入 freqToList[1] 头部
        minFreq = 1
```

### 5. 关键洞察：minFreq 怎么维护

- put 新节点：minFreq = 1（新节点频次为 1）
- get/put 更新：把节点移到 freq+1 桶；若原桶空且原 freq == minFreq → `minFreq++`

> **学习点 ①**：**LFU 的灵魂 = "频次桶 + 桶内 LRU"**。两个维度叠加，关键是 `minFreq` O(1) 维护。

### 6. 容易踩的坑

| 坑 | 处理 |
|---|---|
| capacity == 0 没处理 | 直接 return |
| 删除桶后没更新 minFreq | 必须判 `freqToList[minFreq].isEmpty()` |
| 用 Java `LinkedList` 删任意节点 O(n) | 必须手写双向链表 |
| key 已存在时频次更新和值更新都要 | 调 `get` 逻辑（增频次）+ 更新 val |

---

## 三、详细解题步骤（精简版）

**步骤 1**：节点类
```java
private static class Node {
    int key, val, freq;
    Node prev, next;
    Node(int k, int v) { key = k; val = v; freq = 1; }
}
```

**步骤 2**：双向链表类（含 head/tail 哨兵 + size）
```java
private static class DLL {
    Node head = new Node(0, 0), tail = new Node(0, 0);
    int size = 0;
    DLL() { head.next = tail; tail.prev = head; }
    void addFirst(Node n) {
        n.prev = head; n.next = head.next;
        head.next.prev = n; head.next = n;
        size++;
    }
    void remove(Node n) {
        n.prev.next = n.next; n.next.prev = n.prev;
        size--;
    }
    Node removeLast() { Node n = tail.prev; remove(n); return n; }
    boolean isEmpty() { return size == 0; }
}
```

**步骤 3**：成员
```java
private final int capacity;
private int size = 0;
private int minFreq = 0;
private final Map<Integer, Node> keyToNode = new HashMap<>();
private final Map<Integer, DLL> freqToList = new HashMap<>();
```

**步骤 4**：get/put 见下方完整代码。

---

## 四、Java 题解

```java
class LFUCache {
    private static class Node {
        int key, val, freq;
        Node prev, next;
        Node(int k, int v) { key = k; val = v; freq = 1; }
    }
    private static class DLL {
        Node head = new Node(0, 0), tail = new Node(0, 0);
        int size = 0;
        DLL() { head.next = tail; tail.prev = head; }
        void addFirst(Node n) {
            n.prev = head; n.next = head.next;
            head.next.prev = n; head.next = n;
            size++;
        }
        void remove(Node n) {
            n.prev.next = n.next; n.next.prev = n.prev;
            size--;
        }
        Node removeLast() { Node n = tail.prev; remove(n); return n; }
        boolean isEmpty() { return size == 0; }
    }

    private final int capacity;
    private int size = 0;
    private int minFreq = 0;
    private final Map<Integer, Node> keyToNode = new HashMap<>();
    private final Map<Integer, DLL> freqToList = new HashMap<>();

    public LFUCache(int capacity) { this.capacity = capacity; }

    public int get(int key) {
        Node n = keyToNode.get(key);
        if (n == null) return -1;
        touch(n);
        return n.val;
    }

    public void put(int key, int value) {
        if (capacity == 0) return;
        Node n = keyToNode.get(key);
        if (n != null) {
            n.val = value;
            touch(n);
            return;
        }
        if (size == capacity) {
            DLL minList = freqToList.get(minFreq);
            Node removed = minList.removeLast();
            keyToNode.remove(removed.key);
            size--;
        }
        Node node = new Node(key, value);
        keyToNode.put(key, node);
        freqToList.computeIfAbsent(1, k -> new DLL()).addFirst(node);
        minFreq = 1;
        size++;
    }

    private void touch(Node n) {
        DLL oldList = freqToList.get(n.freq);
        oldList.remove(n);
        if (oldList.isEmpty() && n.freq == minFreq) minFreq++;
        n.freq++;
        freqToList.computeIfAbsent(n.freq, k -> new DLL()).addFirst(n);
    }
}
```

**记忆口诀**：
> **"频次桶 + 桶内 LRU；touch 升频次、桶空则 minFreq++；逐出时从 minFreq 桶尾部。"**

---

## 五、复杂度

| 操作 | 时间 | 空间 |
|---|---|---|
| get / put | **O(1)** 摊销 | O(capacity) |

---

## 六、示例验证

```
LFUCache cache = new LFUCache(2);
cache.put(1, 1);   // freqToList: {1: [1]}, minFreq=1
cache.put(2, 2);   // freqToList: {1: [2, 1]}, minFreq=1
cache.get(1);      // 返回 1; 节点 1 升频次 → {1: [2], 2: [1]}, minFreq=1
cache.put(3, 3);   // 容量满 → 逐 freqToList[1] 尾部 = node 2 → {1: [3], 2: [1]}, minFreq=1
cache.get(2);      // 返回 -1
cache.get(3);      // 返回 3; node 3 升频次 → {1: [], 2: [3, 1]}, minFreq=2
cache.get(4);      // -1
```

✅

---

## 七、复盘与延伸

### 一句话总结
> **HashMap 定位 + 频次桶 + 桶内双向链表（LRU）；touch 升桶、minFreq O(1) 维护。**

### 新手常见疑问（FAQ）

**Q1：minFreq 怎么 O(1) 维护？**
A：只有两个时刻更新：
- put 新节点 → `minFreq = 1`（新节点频次必为 1）
- touch 后原桶为空且 `n.freq == minFreq` → `minFreq++`

不需要遍历找最小，永远 O(1)。

**Q2：桶为空就删掉会怎样？**
A：可以，但 `freqToList.get(freq)` 时要重新创建。简化：保留空桶（map 项），用 `isEmpty()` 判断。

**Q3：为什么频次相同时按 LRU 逐出？**
A：题目要求。同频次桶用双向链表维护"插入/访问顺序"，尾部最旧。

**Q4：节点为什么要存 key？**
A：逐出时需要从 `keyToNode.remove(key)`，必须知道 key。同 LRU。

**Q5：能否用 TreeMap？**
A：能但 O(log n)，不达 O(1)。

### 面试官常见 follow-up
1. **"LRU 与 LFU 对比？"** → LRU 一个维度（时间）；LFU 两个维度（频次 + 时间）。
2. **"LFU 的实际应用？"** → 数据库缓存（高频查询页面）、CDN 边缘节点。
3. **"分布式 LFU？"** → 一致性哈希分片 + 本地 LFU；频次跨节点聚合困难。
4. **"含过期时间？"** → 节点加 `expireAt`，get 时检查；或后台线程清理。
5. **"线程安全？"** → 加 `ReentrantLock`；细粒度难（多个桶交互）。
6. **"能否动态调整 capacity？"** → 提供 resize 方法，缩容时循环逐出。

### 同类型推荐（**缓存设计家族**）
- LC 146. LRU 缓存
- LC 432. 全 O(1) 数据结构
- LC 380. 常数时间插入、删除和获取随机元素
- LC 295. 数据流的中位数（双堆）
- LC 1146. 快照数组
- LC 588. 设计内存文件系统
