# LeetCode 994. 腐烂的橘子 (Rotting Oranges)

> 难度：Medium　|　标签：图、BFS、多源 BFS、网格　|　**多源 BFS 模板 ⭐⭐⭐**

---

## 一、题目

在给定的 `m x n` 网格 `grid` 中，每个单元格可以有以下三个值之一：
- `0` 代表空单元格
- `1` 代表新鲜橘子
- `2` 代表腐烂的橘子

每分钟，任何与腐烂橘子（在 **四个正方向上**）相邻的新鲜橘子都会腐烂。

返回直到单元格中没有新鲜橘子为止所必须经过的 **最小分钟数**。如果不可能，返回 `-1`。

**约束**

- `1 <= m, n <= 10`
- `grid[i][j] in {0, 1, 2}`

**示例**

| 输入 | 输出 |
|---|---|
| `[[2,1,1],[1,1,0],[0,1,1]]` | `4` |
| `[[2,1,1],[0,1,1],[1,0,1]]` | `-1`（左下角的 1 隔绝） |
| `[[0,2]]` | `0`（没有新鲜橘子） |

题目链接：<https://leetcode.cn/problems/rotting-oranges/>

---

## 二、解题思路（学习重点）

### 1. 多源 BFS：所有腐烂橘子 **同时出发**

单源 BFS 每次只能从一个起点扩展；如果有 k 个腐烂橘子，单源 BFS 跑 k 次会重复计算。

**多源 BFS**：把所有腐烂橘子 **同时入队**，第 0 层是所有起点。这样自然得到 "**每个新鲜橘子到最近腐烂橘子的距离**"。

> **学习点 ①**：**"多源最短路 / 多源到点的最短距离"** → 第一反应是 **多源 BFS**。同模板：LC 542（01 矩阵）、LC 1162（地图分析）、LC 286（墙与门）。

### 2. 算法步骤

1. 扫描网格：把所有腐烂橘子入队；同时统计新鲜橘子数 `fresh`。
2. 若 fresh == 0 → 0 分钟。
3. BFS 按层扩展，每层 minutes++；每次把新腐烂的橘子加入队列，同时 fresh--。
4. BFS 结束后若 fresh > 0 → 有隔绝的新鲜橘子，返回 -1；否则返回 minutes。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 没快照 size → 分钟数不对 | 必须 `int size = queue.size();` |
| BFS 完忘了减 fresh | 算法逻辑错 |
| 最后一层扩展时多算 1 分钟 | 用 `if (有新腐烂) minutes++` 而不是无脑 ++ |
| 没有新鲜橘子时返回 0 | 题目要求 |

---

## 三、详细解题步骤

**步骤 1**：扫描网格
```java
int m = grid.length, n = grid[0].length;
Deque<int[]> queue = new ArrayDeque<>();
int fresh = 0;
for (int i = 0; i < m; i++)
    for (int j = 0; j < n; j++) {
        if (grid[i][j] == 2) queue.offer(new int[]{i, j});
        else if (grid[i][j] == 1) fresh++;
    }
if (fresh == 0) return 0;
```

**步骤 2**：BFS 按层扩展
```java
int[][] DIR = {{1,0},{-1,0},{0,1},{0,-1}};
int minutes = 0;
while (!queue.isEmpty() && fresh > 0) {
    int size = queue.size();
    for (int k = 0; k < size; k++) {
        int[] cur = queue.poll();
        for (int[] d : DIR) {
            int ni = cur[0] + d[0], nj = cur[1] + d[1];
            if (ni < 0 || ni >= m || nj < 0 || nj >= n) continue;
            if (grid[ni][nj] != 1) continue;
            grid[ni][nj] = 2;
            fresh--;
            queue.offer(new int[]{ni, nj});
        }
    }
    minutes++;
}
```

**步骤 3**：返回
```java
return fresh == 0 ? minutes : -1;
```

---

## 四、Java 题解

```java
class Solution {
    static final int[][] DIR = {{1,0},{-1,0},{0,1},{0,-1}};

    public int orangesRotting(int[][] grid) {
        int m = grid.length, n = grid[0].length;
        Deque<int[]> queue = new ArrayDeque<>();
        int fresh = 0;
        for (int i = 0; i < m; i++)
            for (int j = 0; j < n; j++) {
                if (grid[i][j] == 2) queue.offer(new int[]{i, j});
                else if (grid[i][j] == 1) fresh++;
            }
        if (fresh == 0) return 0;

        int minutes = 0;
        while (!queue.isEmpty() && fresh > 0) {
            int size = queue.size();
            for (int k = 0; k < size; k++) {
                int[] cur = queue.poll();
                for (int[] d : DIR) {
                    int ni = cur[0] + d[0], nj = cur[1] + d[1];
                    if (ni < 0 || ni >= m || nj < 0 || nj >= n) continue;
                    if (grid[ni][nj] != 1) continue;
                    grid[ni][nj] = 2;
                    fresh--;
                    queue.offer(new int[]{ni, nj});
                }
            }
            minutes++;
        }
        return fresh == 0 ? minutes : -1;
    }
}
```

**记忆口诀**：
> **"所有腐烂入队、按层 BFS、新鲜归零即解。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(m·n)** —— 每个格子最多入队 1 次 |
| 空间 | O(m·n) 队列 |

---

## 六、示例验证

`[[2,1,1],[1,1,0],[0,1,1]]`，fresh = 6

| 分钟 | 队列 (开始) | 腐烂 | fresh | 队列 (结束) |
|---|---|---|---|---|
| 0 | [(0,0)] | — | 6 | [(0,0)] |
| 1 | [(0,0)] | (1,0), (0,1) | 4 | [(1,0),(0,1)] |
| 2 | [(1,0),(0,1)] | (1,1), (0,2) | 2 | [(1,1),(0,2)] |
| 3 | [(1,1),(0,2)] | (2,1) | 1 | [(2,1)] |
| 4 | [(2,1)] | (2,2) | 0 | [(2,2)] |

返回 `4` ✅

---

## 七、复盘与延伸

### 一句话总结
> **多源 BFS：所有起点同入队，按层扩展，得到每个目标的最短距离。**

### 新手常见疑问（FAQ）

**Q1：和单源 BFS 区别？**
A：单源 BFS 初始队列只有 1 个起点；多源 BFS 把所有起点一起入队作为第 0 层。结果是 "**每个点到最近某起点的距离**"。

**Q2：能否 DFS？**
A：能但慢。BFS 天然给最短距离；DFS 需 min(所有路径)，时间高。

**Q3：为什么 `if (!queue.isEmpty() && fresh > 0)` 加 `fresh > 0` 条件？**
A：避免多扩一轮空层（最后一分钟橘子已全腐烂但队列里还有新腐烂的橘子等着扩散）。`fresh = 0` 直接停。

**Q4：如果一个橘子离两个腐烂橘子距离相同？**
A：BFS 自动取较早达到的（第一次被访问），符合"最近"语义。

**Q5：能否就地修改 grid？**
A：可以也应该。本算法把腐烂的格子标为 2，避免重复处理。

### 面试官常见 follow-up
1. **"01 矩阵：每个 1 到最近 0 的距离（[LC 542](https://leetcode.cn/problems/01-matrix/)）？"** → 把所有 0 入队多源 BFS。
2. **"墙与门：每个空房间到最近门的距离（LC 286）？"** → 把所有门入队 BFS。
3. **"地图分析：海洋距陆地的最远距离（LC 1162）？"** → 多源 BFS 求最大距离。
4. **"如果有边权（不是统一 1 分钟）？"** → 不是 BFS 了，需要 Dijkstra。
5. **"如果橘子可以八方向腐烂？"** → DIR 改 8 项。
6. **"如果橘子有抗性（隔几分钟才腐烂）？"** → 每个橘子带 health，BFS 时每次 -1，归 0 才被腐烂；可能要 PriorityQueue。

### 同类型推荐（**多源 BFS 家族**）
- [LC 542. 01 矩阵](https://leetcode.cn/problems/01-matrix/)
- LC 286. 墙与门
- LC 1162. 地图分析
- LC 1765. 地图中的最高点
- LC 317. 离建筑物最近的距离
- [LC 200. 岛屿数量](https://leetcode.cn/problems/number-of-islands/)（单源 BFS/DFS）
