# 08 · 并查集 · Union-Find (DSU)

> **用途**：动态维护"哪些元素属于同一组"，支持 `find(x)` 查代表元、`union(x, y)` 合并两组。
> **典型场景**：连通分量数（LC 200 / 547）、最小生成树 Kruskal、判环、动态等价类、字符串等价合并（LC 721 / 952）。
> 单次操作摊还 **接近 O(1)**（α(n) 反阿克曼函数）。

---

## 一、最常用模板（路径压缩 + 按大小合并）

```java
class UnionFind {
    int[] parent;
    int[] size;       // 每个根节点对应集合的大小
    int count;        // 当前连通分量数

    public UnionFind(int n) {
        parent = new int[n];
        size = new int[n];
        count = n;
        for (int i = 0; i < n; i++) {
            parent[i] = i;     // 初始每个节点自成一组
            size[i] = 1;
        }
    }

    // 查代表元 + 路径压缩
    public int find(int x) {
        if (parent[x] != x) parent[x] = find(parent[x]);
        return parent[x];
    }

    // 合并：返回是否真的合并了（false 表示原本就在同一组）
    public boolean union(int x, int y) {
        int rx = find(x), ry = find(y);
        if (rx == ry) return false;
        // 按大小合并：小的挂到大的下面，树更扁
        if (size[rx] < size[ry]) { int t = rx; rx = ry; ry = t; }
        parent[ry] = rx;
        size[rx] += size[ry];
        count--;
        return true;
    }

    public boolean connected(int x, int y) {
        return find(x) == find(y);
    }

    public int getCount() { return count; }
}
```

> **两个优化都要加**：路径压缩让"查"快，按大小（或按秩）合并让"树高"低。一起用才到 α(n)。

---

## 二、迭代版 `find`（避免递归栈溢出）

```java
public int find(int x) {
    int root = x;
    while (parent[root] != root) root = parent[root];
    // 第二趟：把路径上所有节点直接挂到 root
    while (parent[x] != root) {
        int next = parent[x];
        parent[x] = root;
        x = next;
    }
    return root;
}
```

> n 很大（≥ 10^5）时优先用迭代版，防 StackOverflow。

---

## 三、典型应用

### 应用 1：连通分量数（LC 547 省份数量）

```java
public int findCircleNum(int[][] isConnected) {
    int n = isConnected.length;
    UnionFind uf = new UnionFind(n);
    for (int i = 0; i < n; i++)
        for (int j = i + 1; j < n; j++)
            if (isConnected[i][j] == 1) uf.union(i, j);
    return uf.getCount();
}
```

### 应用 2：二维网格 → 一维下标（LC 200 岛屿数量 / LC 305）

```java
// (i, j) → i * cols + j
int idx(int i, int j, int cols) { return i * cols + j; }

// 遍历每个 '1' 格子，向右/下合并即可
for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
        if (grid[i][j] != '1') continue;
        if (i + 1 < rows && grid[i+1][j] == '1') uf.union(idx(i,j,cols), idx(i+1,j,cols));
        if (j + 1 < cols && grid[i][j+1] == '1') uf.union(idx(i,j,cols), idx(i,j+1,cols));
    }
}
```

### 应用 3：判环（无向图）

```java
for (int[] e : edges) {
    if (!uf.union(e[0], e[1])) return true;   // 已经在同一组 → 加这条边就成环
}
return false;
```

### 应用 4：Kruskal 最小生成树

```java
Arrays.sort(edges, (a, b) -> a[2] - b[2]);   // 按边权升序
UnionFind uf = new UnionFind(n);
int total = 0, used = 0;
for (int[] e : edges) {
    if (uf.union(e[0], e[1])) {
        total += e[2];
        if (++used == n - 1) break;
    }
}
```

---

## 四、字符串 / 非整数节点 → 编号映射

```java
Map<String, Integer> id = new HashMap<>();
int nextId = 0;
// 遍历输入，给每个字符串分配 id
for (String s : nodes) {
    if (!id.containsKey(s)) id.put(s, nextId++);
}
UnionFind uf = new UnionFind(nextId);
// 再用 id.get(s) 去 union
```

---

## 五、带权并查集（进阶，LC 399 除法求值）

> 每个节点保存"到父节点的权值"，`find` 时一路累乘（或累加）。

```java
class WeightedUF {
    int[] parent;
    double[] weight;   // weight[x] = value(x) / value(parent[x])

    public WeightedUF(int n) {
        parent = new int[n];
        weight = new double[n];
        for (int i = 0; i < n; i++) { parent[i] = i; weight[i] = 1.0; }
    }

    public int find(int x) {
        if (parent[x] != x) {
            int root = find(parent[x]);
            weight[x] *= weight[parent[x]];   // 路径压缩同时累乘
            parent[x] = root;
        }
        return parent[x];
    }

    public void union(int x, int y, double value) {
        int rx = find(x), ry = find(y);
        if (rx == ry) return;
        parent[rx] = ry;
        weight[rx] = value * weight[y] / weight[x];
    }
}
```

---

## 六、常见坑

| 坑 | 现象 | 解决 |
|---|---|---|
| 只压缩不按大小合并 | 退化成链表，find 变 O(n) | 两个优化都加 |
| `parent[x] = x` 忘了初始化 | find 死循环或返回 0 | 构造函数 for 循环 |
| 在循环里用 `parent[x]` 而不是 `find(x)` | 拿到的不是最新代表元 | 比较两点是否同组永远用 `find(x) == find(y)` |
| 节点不是 0..n-1 | 数组越界 | 用 `Map<T, Integer>` 编号 |
| 递归 find 爆栈 | n ≥ 10^5 | 改迭代版 |

---

## 七、回顾自测

1. `find` 为什么要路径压缩？只压缩不按秩合并，最坏复杂度是？
2. `union` 返回 `boolean` 有什么用？
3. 二维网格 `(i, j)` 在并查集里通常用什么 id？
4. 判一张无向图是否有环，怎么用并查集做？
5. `count` 这个字段是干嘛的？

<details>
<summary>答案</summary>

1. 路径压缩让后续 `find` 变 O(1)。只压缩不按秩合并，最坏 O(log n) 摊还；两个都加才到 α(n)。
2. 返回 `false` 表示两点本来就在一组，可用来**判环 / 计算 MST 实际选了多少条边**。
3. `i * cols + j`。
4. 遍历每条边 `union(u, v)`，一旦返回 `false` 说明成环。
5. 当前连通分量数。初始 = n，每次成功 `union` 减 1。

</details>
