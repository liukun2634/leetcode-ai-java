# 04 · Map & Set

> **结论**：
> - 哈希表 → `HashMap` / `HashSet`，O(1) 平均
> - **要按 key 排序、要找前驱后继** → `TreeMap` / `TreeSet`，O(log n)
> - **要保持插入顺序、做 LRU** → `LinkedHashMap`

---

## 一、`HashMap<K, V>` —— 平均 O(1) 增删改查

### 1. 基本 API

| 操作 | 写法 | 备注 |
|---|---|---|
| 创建 | `Map<K,V> m = new HashMap<>();` | |
| 预分配容量 | `new HashMap<>(expectedSize * 2)` | 减少 rehash，大数据必加 |
| 不可变字面量 | `Map.of("a", 1, "b", 2)` / `Map.entry(k,v)` | Java 9+，最多 10 对 |
| 插入/更新 | `m.put(k, v)` | 返回旧值（无则 `null`） |
| 读 | `m.get(k)` | 不存在返回 `null` |
| 读 + 默认值 | `m.getOrDefault(k, def)` | **强烈推荐** |
| 是否存在 | `m.containsKey(k)` / `containsValue(v)` | `containsValue` O(n) |
| 删 | `m.remove(k)` | 返回旧值 |
| 大小 | `m.size()` | |
| 清空 | `m.clear()` | |

### 2. 三大"懒人"方法（背熟）

```java
// 频次统计：一行搞定 cnt[x]++
cnt.merge(x, 1, Integer::sum);
// 等价于
cnt.put(x, cnt.getOrDefault(x, 0) + 1);

// 分组：m.get(k) 是 List，没有就新建
m.computeIfAbsent(k, key -> new ArrayList<>()).add(v);
// 等价于
if (!m.containsKey(k)) m.put(k, new ArrayList<>());
m.get(k).add(v);

// 条件更新
m.computeIfPresent(k, (key, oldV) -> oldV + 1);
```

> `merge` 和 `computeIfAbsent` 是 LeetCode **最高频**的两个 Map 方法。

### 3. 遍历

```java
for (Map.Entry<K, V> e : m.entrySet()) {
    K k = e.getKey();
    V v = e.getValue();
}
for (K k : m.keySet()) { ... }
for (V v : m.values()) { ... }
```

> **不要在遍历中 `m.remove`**，会 `ConcurrentModificationException`。要删用 `Iterator.remove()` 或先收集 key。

### 4. 自定义 key 的坑

```java
class Point { int x, y; }
Map<Point, Integer> m = new HashMap<>();
m.put(new Point(1,2), 100);
m.get(new Point(1,2));   // ❌ null，因为没重写 hashCode/equals
```

> 自定义 key 必须**同时**重写 `hashCode()` 和 `equals()`。LeetCode 上能避就避，**用 `int[]` 当 key 也是错的**（数组比较看引用）。
> 替代方案：把 (x, y) 编码成 `x * 10001 + y` 或 `"x,y"` 字符串。

```java
m.put(x * 10001 + y, v);          // 简单坐标
m.put(x + "," + y, v);            // 通用
m.put(Arrays.asList(x, y), v);    // List 有正确的 hashCode/equals
```

---

## 二、`HashSet<T>` —— 去重 / 存在性判断

```java
Set<Integer> set = new HashSet<>();
set.add(1);                              // O(1)
set.contains(1);                         // O(1)
set.remove(1);
set.size();
Set<Integer> s2 = new HashSet<>(list);   // 从集合初始化
Set<Integer> s3 = Set.of(1, 2, 3);       // 不可变字面量（Java 9+）

// 集合运算
set.retainAll(other);   // 交集：只保留两边都有的
set.removeAll(other);   // 差集：去掉 other 里有的
set.addAll(other);      // 并集
```

> 同样：**自定义对象需重写 `hashCode/equals`**。

---

## 三、`LinkedHashMap` —— 保持插入顺序 / LRU

```java
// 普通：按插入顺序遍历
Map<String, Integer> m = new LinkedHashMap<>();
```

### LRU Cache 经典实现（LC 146）

```java
class LRUCache extends LinkedHashMap<Integer, Integer> {
    private final int capacity;
    public LRUCache(int capacity) {
        // initialCapacity, loadFactor, accessOrder=true
        super(capacity, 0.75f, true);
        this.capacity = capacity;
    }
    public int get(int key) {
        return super.getOrDefault(key, -1);
    }
    public void put(int key, int value) {
        super.put(key, value);
    }
    @Override
    protected boolean removeEldestEntry(Map.Entry<Integer, Integer> eldest) {
        return size() > capacity;
    }
}
```

> 关键：构造函数第 3 个参数 `accessOrder=true` → 每次 `get`/`put` 把节点移到末尾。
> `removeEldestEntry` 是钩子，超容量时删最久未访问的（即头节点）。

---

## 四、`TreeMap<K, V>` —— 按 key 排序 + 二分查找

> 底层红黑树，所有 O(log n)。当你需要"找小于某值的最大 key"时**唯一选择**。

### 1. 标志性方法

| 操作 | 含义 |
|---|---|
| `firstKey()` / `lastKey()` | 最小 / 最大 key |
| `floorKey(k)` | **小于等于** k 的最大 key（找不到返 `null`） |
| `ceilingKey(k)` | **大于等于** k 的最小 key |
| `lowerKey(k)` | 严格 **小于** k 的最大 |
| `higherKey(k)` | 严格 **大于** k 的最小 |
| `headMap(k)` | key < k 的子映射（视图） |
| `tailMap(k)` | key ≥ k 的子映射 |
| `subMap(l, r)` | `[l, r)` 区间子映射 |
| `pollFirstEntry()` | 取出并删除最小 entry |
| `pollLastEntry()` | 取出并删除最大 entry |
| `descendingMap()` | 反序视图（按 key 降序遍历） |
| `navigableKeySet()` / `descendingKeySet()` | 可按顺 / 逆序遍历 key |

```java
TreeMap<Integer, Integer> tm = new TreeMap<>();
tm.put(10, 1); tm.put(20, 2); tm.put(30, 3);
tm.floorKey(25);     // 20
tm.ceilingKey(25);   // 30
tm.floorKey(5);      // null
```

### 2. 经典应用：日历 / 区间合并 / 在线扫描

```java
// 给定一组区间，查询某点落在哪些区间？
TreeMap<Integer, Integer> tm = new TreeMap<>();  // key 起点, value 终点
// ... put 进所有区间
Map.Entry<Integer, Integer> e = tm.floorEntry(x);
boolean inside = e != null && e.getValue() >= x;
```

---

## 五、`TreeSet<T>` —— 同 TreeMap 的 key 视图

```java
TreeSet<Integer> ts = new TreeSet<>();
ts.add(1); ts.add(5); ts.add(3);
ts.first(); ts.last();
ts.floor(4);    // 3
ts.ceiling(4);  // 5
ts.lower(3);    // 1（严格小于）
ts.higher(3);   // 5
```

> 用途：**滑动窗口的"最接近值"问题**（LC 220）、**会议室**等。

---

## 六、Map / Set 速选表

| 需求 | 选 | 关键方法 |
|---|---|---|
| 计数、查表 | `HashMap` | `merge` / `getOrDefault` |
| 去重、存在性 | `HashSet` | `add` / `contains` |
| LRU / 保序遍历 | `LinkedHashMap` | `accessOrder=true` + `removeEldestEntry` |
| 找前驱/后继、有序遍历 | `TreeMap` / `TreeSet` | `floorKey` / `ceilingKey` |
| 多重集 / 频次有序 | `TreeMap<K, Integer>` + merge | 当 multiset 用 |

---

## 七、`HashMap` vs `TreeMap` 复杂度对照

| 操作 | HashMap | TreeMap |
|---|---|---|
| put / get / remove | O(1) 平均 | O(log n) |
| 找最小 / 最大 key | O(n) 扫 keySet | O(log n) |
| 找前驱 / 后继 | ❌ 不支持 | O(log n) |
| 遍历顺序 | 无序 | 按 key 升序 |

> 题目要求"查找最接近的 key"时，**用 `HashMap` 一定 TLE**。

---

## 八、回顾自测

1. `merge(x, 1, Integer::sum)` 等价于哪段代码？
2. 自定义类 `Point` 当 HashMap key 要做什么？
3. `floorKey(5)` 当所有 key 都 > 5 时返回什么？
4. LRU 实现中 `LinkedHashMap` 构造的 `accessOrder` 参数干啥的？
5. 想找"≥ 某值的最小元素"用什么数据结构？

<details>
<summary>答案</summary>

1. `m.put(x, m.getOrDefault(x, 0) + 1)`。
2. 重写 `hashCode()` 和 `equals()`。
3. `null`。所有 floor/ceiling/lower/higher 找不到都返 `null`。
4. 每次 `get`/`put` 把节点挪到末尾，让最早访问的留在头。配 `removeEldestEntry` 实现 LRU。
5. `TreeMap.ceilingKey(x)` / `TreeSet.ceiling(x)`，O(log n)。

</details>
