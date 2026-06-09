# [LeetCode 207. 课程表 (Course Schedule)](https://leetcode.com/problems/course-schedule/)

> 难度：Medium　|　标签：图、拓扑排序、BFS、DFS　|　**拓扑排序模板 ⭐⭐⭐**

---

## 一、题目

你这个学期必须选修 `numCourses` 门课程，记为 `0` 到 `numCourses - 1`。在选修某些课程之前需要一些先修课程。先修课程按数组 `prerequisites` 给出，其中 `prerequisites[i] = [a, b]` 表示如果你想选课 `a`，那么你必须先选课 `b`。

判断是否可能完成所有课程的学习？

**约束**

- `1 <= numCourses <= 2000`
- `0 <= prerequisites.length <= 5000`

**示例**

| 输入 | 输出 |
|---|---|
| `numCourses=2, prerequisites=[[1,0]]` | `true`（先 0 后 1）|
| `numCourses=2, prerequisites=[[1,0],[0,1]]` | `false`（环）|

---

## 二、解题思路（学习重点）

### 1. 抽象成图

- 节点：每门课
- 有向边：`[a, b]` 看成 `b → a`（"想学 a 必须先学 b"）
- 问题等价：**这张有向图是否有环？** 无环 → 能完成；有环 → 不能。

> **学习点 ①**：判环的两种通用方法 —— **拓扑排序（Kahn / BFS）** 和 **DFS 三色标记**。前者更适合工程模板，后者代码短。

### 2. Kahn 算法（BFS 拓扑排序，强烈推荐）

1. 算出每个节点的 **入度**（被多少课依赖）。
2. 把所有 **入度为 0** 的节点入队（无前置课，可以立即学）。
3. 不断 `poll`，把它的 **后继节点入度减 1**；后继变为 0 入队；同时计数 `+1`。
4. 最终若计数 = `numCourses` → 无环 → `true`；否则有环。

> **学习点 ②**：拓扑排序天然给出了一种 **合法学习顺序**（LC 210 直接返回这个顺序）。

### 3. DFS 三色标记

每个节点三种状态：
- `0` 未访问
- `1` 正在访问（在当前 DFS 路径上）
- `2` 已完成访问

DFS 时如果遇到 `1` → 出现环 → `false`；遇到 `2` → 已确认无环跳过。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 边方向理解错（`[a,b]` 是 a 依赖 b） | 建图时是 `b → a` |
| 用邻接矩阵 → 空间 O(n²) | 用邻接表 `List<List<Integer>>` |
| Kahn 忘了计数，仅看队列是否空 | 必须用计数判完成数 |
| DFS 没区分"路径上"和"已完成"，把所有访问过都标 1 → 误判 | 三色不可省 |

---

## 三、Java 题解

### 解法 A：Kahn / BFS 拓扑排序（推荐）

```java
class Solution {
    public boolean canFinish(int numCourses, int[][] prerequisites) {
        List<List<Integer>> g = new ArrayList<>();
        for (int i = 0; i < numCourses; i++) g.add(new ArrayList<>());
        int[] indeg = new int[numCourses];
        for (int[] p : prerequisites) {
            g.get(p[1]).add(p[0]);  // b -> a
            indeg[p[0]]++;
        }
        Deque<Integer> queue = new ArrayDeque<>();
        for (int i = 0; i < numCourses; i++) if (indeg[i] == 0) queue.offer(i);

        int finished = 0;
        while (!queue.isEmpty()) {
            int u = queue.poll();
            finished++;
            for (int v : g.get(u)) {
                if (--indeg[v] == 0) queue.offer(v);
            }
        }
        return finished == numCourses;
    }
}
```

**记忆口诀**：
> **"入度归 0 入队、出队减后继、最后计数判完。"**

### 解法 B：DFS 三色标记

```java
class Solution {
    private List<List<Integer>> g;
    private int[] color;

    public boolean canFinish(int numCourses, int[][] prerequisites) {
        g = new ArrayList<>();
        for (int i = 0; i < numCourses; i++) g.add(new ArrayList<>());
        for (int[] p : prerequisites) g.get(p[1]).add(p[0]);
        color = new int[numCourses];

        for (int i = 0; i < numCourses; i++)
            if (color[i] == 0 && hasCycle(i)) return false;
        return true;
    }
    private boolean hasCycle(int u) {
        color[u] = 1; // 进入路径
        for (int v : g.get(u)) {
            if (color[v] == 1) return true;
            if (color[v] == 0 && hasCycle(v)) return true;
        }
        color[u] = 2; // 完成
        return false;
    }
}
```

---

## 四、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(V + E)** = O(numCourses + prerequisites.length) |
| 空间 | O(V + E)（邻接表 + 队列/递归栈） |

---

## 五、示例验证

`numCourses=4, prerequisites=[[1,0],[2,0],[3,1],[3,2]]`

构图：`0→1, 0→2, 1→3, 2→3`；入度：`[0,1,1,2]`。

| 队列变化 | finished | 操作 |
|---|---|---|
| `[0]` | 0 | poll 0；1,2 入度归 0 入队 |
| `[1,2]` | 1 | poll 1；3 入度 2→1 |
| `[2]` | 2 | poll 2；3 入度 1→0 入队 |
| `[3]` | 3 | poll 3 | 
| `[]` | 4 | finished == 4 → `true` ✅ |

---

## 六、复盘与延伸

### 一句话总结
> **有向图判环 / 求合法序：Kahn 算法（入度归 0 入队、出队减后继）即得拓扑顺序。**

### 新手常见疑问（FAQ）

**Q1：边的方向怎么记不误？**
A：`[a, b]` 表示“要学 a 必须先学 b”，是「b 是 a 的前提」，建边 `b → a`（学完 b 才能去学 a）。口诀：「后项依赖前项，边从前项指后项」。

**Q2：Kahn 与 DFS 三色选哪个？**
A：Kahn 更直观，且天然给出拓扑顺序（LC 210 直接用其结果）；DFS 代码短，但三色状态要熟。面试首选 Kahn。

**Q3：为什么要用 `finished` 计数而不是看队列是否空？**
A：队列空后可能还有节点未处理（环中节点永远入不了队）。必须用计数与 n 比较才能判断是否完成。

**Q4：重复边（如 `[1,0],[1,0]`）会不会出问题？**
A：重复边会让入度多加，但减也会多减，不影响正确性。若需去重可用 `Set` 存邻接表。

**Q5：自环 `[a,a]` 怎么处理？**
A：`a` 的入度始终 ≥ 1，永远不会入队，最后 finished < n 返回 false。算法天然正确。

### 面试官常见 follow-up
1. **"返回一个合法学习顺序？"** → 记录出队顺序即可。即 **LC 210**。
2. **"起点 / 终点给定，求从起点还能抵达哪些节点？"** → 从起点 DFS/BFS，收集可达集合。
3. **"有环时返回环上的节点？"** → DFS 三色时遇到灰色节点记录状态以重构环。
4. **"火星词典（从排序后的单词推出字母顺序）？"** → 两两比较单词建边，拓扑。即 **LC 269**。
5. **"拓扑顺序唯一性判定（是否只有一种）？"** → Kahn 每轮队列只有一个节点 → 唯一。即 **LC 444**。
6. **"边有周期限制、计算最少学期数（拓扑分层）？"** → Kahn 按层处理，层数 = 学期数。即 **LC 1136**。

### 同类型推荐（**拓扑排序家族**）
- LC 210. 课程表 II（返回学习顺序）
- LC 269. 火星词典（拓扑排序应用）
- LC 310. 最小高度树（拓扑剥叶）
- LC 802. 找到最终的安全状态（反向图拓扑）
- LC 444. 序列重建（拓扑唯一性判断）
- LC 1136. 平行课程
