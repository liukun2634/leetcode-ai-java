# [LeetCode 547. 省份数量 (Number of Provinces)](https://leetcode.com/problems/number-of-provinces/)

> 难度：Medium　|　标签：图、DFS、BFS、并查集　|　**连通分量基础 ⭐⭐⭐**

---

## 一、题目

有 `n` 个城市，其中一些彼此相连，另一些没有相连。如果城市 `a` 与城市 `b` 直接相连，且城市 `b` 与城市 `c` 直接相连，那么城市 `a` 与城市 `c` 间接相连。

**省份** 是一组直接或间接相连的城市，组内不含其他没有相连的城市。

给你一个 `n x n` 的矩阵 `isConnected`，其中 `isConnected[i][j] = 1` 表示第 `i` 个城市和第 `j` 个城市直接相连，而 `isConnected[i][j] = 0` 表示二者不直接相连。

返回矩阵中 **省份** 的数量。

**约束**

- `1 <= n <= 200`
- `isConnected` 是对称矩阵，对角线全为 1

**示例**

| 输入 | 输出 |
|---|---|
| `[[1,1,0],[1,1,0],[0,0,1]]` | `2` |
| `[[1,0,0],[0,1,0],[0,0,1]]` | `3` |

---

## 二、解题思路（学习重点）

### 1. 等价问题：**邻接矩阵图中的连通分量数**

三种通用做法：
| 解法 | 时间 | 空间 |
|---|---|---|
| DFS | O(n²) | O(n) |
| BFS | O(n²) | O(n) |
| 并查集 | O(n² · α(n)) | O(n) |

> **学习点 ①**：连通分量问题三选一。DFS 最短，**并查集最适合动态加边场景**。

### 2. DFS 模板

对每个未访问的城市 i：
- ans++
- 从 i 出发 DFS，把同一个分量的所有城市标 visited

### 3. 并查集模板

- 初始化每个城市为独立集合
- 遍历上三角（j > i），若 `isConnected[i][j] == 1` → `union(i, j)`
- 最后统计 `find(i) == i` 的个数（即根节点数）

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 不用 visited → DFS 死循环 | 标记或就地改为 0 |
| 并查集忘了路径压缩 | 加 `parent[x] = find(parent[x])` |
| 双重循环遍历整个矩阵 → O(n²) 但常数大 | 用上三角 `j > i` 减半 |

---

## 三、详细解题步骤

### 解法 A：DFS

**步骤 1**：开 visited
```java
int n = isConnected.length, ans = 0;
boolean[] visited = new boolean[n];
```

**步骤 2**：遍历每个城市，未访问则 ans++ 并 DFS
```java
for (int i = 0; i < n; i++) {
    if (!visited[i]) {
        ans++;
        dfs(isConnected, visited, i, n);
    }
}
```

**步骤 3**：DFS 染色
```java
private void dfs(int[][] g, boolean[] visited, int i, int n) {
    visited[i] = true;
    for (int j = 0; j < n; j++) {
        if (g[i][j] == 1 && !visited[j]) dfs(g, visited, j, n);
    }
}
```

---

## 四、Java 题解

### 解法 A：DFS（推荐先掌握）

```java
class Solution {
    public int findCircleNum(int[][] isConnected) {
        int n = isConnected.length, ans = 0;
        boolean[] visited = new boolean[n];
        for (int i = 0; i < n; i++) {
            if (!visited[i]) {
                ans++;
                dfs(isConnected, visited, i, n);
            }
        }
        return ans;
    }
    private void dfs(int[][] g, boolean[] visited, int i, int n) {
        visited[i] = true;
        for (int j = 0; j < n; j++) {
            if (g[i][j] == 1 && !visited[j]) dfs(g, visited, j, n);
        }
    }
}
```

### 解法 B：并查集

```java
class Solution {
    public int findCircleNum(int[][] isConnected) {
        int n = isConnected.length;
        int[] parent = new int[n];
        for (int i = 0; i < n; i++) parent[i] = i;

        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                if (isConnected[i][j] == 1) union(parent, i, j);
            }
        }
        int count = 0;
        for (int i = 0; i < n; i++) if (parent[i] == i) count++;
        return count;
    }
    private int find(int[] p, int x) {
        while (p[x] != x) { p[x] = p[p[x]]; x = p[x]; }
        return x;
    }
    private void union(int[] p, int a, int b) {
        int ra = find(p, a), rb = find(p, b);
        if (ra != rb) p[ra] = rb;
    }
}
```

**记忆口诀**：
> **"未访问就 ans++ 染整片；或并查集 union 后数根。"**

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| DFS | O(n²) | O(n) |
| BFS | O(n²) | O(n) |
| 并查集 | O(n² · α(n)) ≈ O(n²) | O(n) |

---

## 六、示例验证

`[[1,1,0],[1,1,0],[0,0,1]]`

- i=0, 未访问 → ans=1，DFS：0→1（因 g[0][1]=1），1 已访问后跳过
- i=1, 已访问，跳过
- i=2, 未访问 → ans=2，DFS：2 自己

输出 `2` ✅

---

## 七、复盘与延伸

### 一句话总结
> **图的连通分量计数：DFS 染色或并查集；本题用邻接矩阵 O(n²)。**

### 新手常见疑问（FAQ）

**Q1：DFS 和并查集选哪个？**
A：静态查询用 DFS（代码短）；**动态加边/在线查询** 用并查集（按需 union）。

**Q2：并查集的时间复杂度 α(n) 是什么？**
A：阿克曼函数反函数，几乎是常数（n=10^80 时 α≈4）。实践中可视为 O(1)。

**Q3：为什么遍历上三角（j>i）就够？**
A：邻接矩阵对称，`g[i][j] == g[j][i]`。union 是对称操作，处理一次即可。

**Q4：邻接矩阵 vs 邻接表？**
A：本题 n ≤ 200，矩阵 O(n²)=40000 空间和时间都很小；n 大时改邻接表。

**Q5：如果 isConnected 是对角线全 0（自己不和自己相连）？**
A：算法仍正确。每个孤立节点也是一个连通分量。

### 面试官常见 follow-up
1. **"动态加边，每次查询连通分量数？"** → 并查集 + count 变量，union 成功就 count--。
2. **"求最大的连通分量大小？"** → 并查集 + size 数组，union 时合并 size。
3. **"无向图中节点是否在同一分量？"** → 并查集查询 `find(a) == find(b)`。
4. **"求所有连通分量的节点列表？"** → DFS 时收集每个分量。
5. **"边带权重，求最小生成树连通所有节点？"** → Kruskal（按边排序 + 并查集）。
6. **"流式数据：边一个个到来，每次报告分量数？"** → 并查集天然支持。

### 同类型推荐（**连通分量 / 并查集家族**）
- LC 200. 岛屿数量
- LC 305. 岛屿数量 II（动态加岛 → 并查集）
- LC 684. 冗余连接（并查集判环）
- LC 685. 冗余连接 II（有向图判环）
- LC 721. 账户合并
- LC 1319. 连通网络的操作次数
- LC 990. 等式方程的可满足性
