# LeetCode 210. 课程表 II (Course Schedule II)

> 难度：Medium　|　标签：图、拓扑排序、BFS、DFS　|　**拓扑排序返回顺序 ⭐⭐⭐**

---

## 一、题目

现在你总共有 `numCourses` 门课需要选，记为 `0` 到 `numCourses - 1`。给你一个数组 `prerequisites`，其中 `prerequisites[i] = [ai, bi]`，表示在选修课程 `ai` 前 **必须** 先选修 `bi`。

返回你为了完成所有课程所安排的 **学习顺序**。可能会有多个正确的顺序，你只要返回 **任意一种** 就可以了。如果不可能完成所有课程，返回一个 **空数组**。

**约束**

- `1 <= numCourses <= 2000`
- `0 <= prerequisites.length <= numCourses * (numCourses - 1)`

**示例**

| 输入 | 输出 |
|---|---|
| `numCourses=2, prerequisites=[[1,0]]` | `[0,1]` |
| `numCourses=4, prerequisites=[[1,0],[2,0],[3,1],[3,2]]` | `[0,1,2,3]` 或 `[0,2,1,3]` |
| `numCourses=1` | `[0]` |

题目链接：<https://leetcode.cn/problems/course-schedule-ii/>

---

## 二、解题思路（学习重点）

### 1. 在 LC 207 基础上多记一个顺序

LC 207 用 Kahn 拓扑排序判环；本题除判环外，**出队顺序就是合法学习顺序**。

修改：
- LC 207 用 `finished` 计数判完成
- LC 210 改用 `int[] order` 数组依次填入出队节点

如果最终填满 numCourses → 返回 order；否则有环 → 返回空数组。

> **学习点 ①**：**拓扑排序天然给出一种合法序**。Kahn 出队顺序就是答案。

### 2. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 用 List + toArray 转 int[] 麻烦 | 直接开 `int[numCourses]` + 索引 |
| 边方向 `[a,b]` → `b → a` | 与 LC 207 一致 |
| 有环时返回空数组（不是 null） | `return new int[0]` |

---

## 三、详细解题步骤

**步骤 1**：建邻接表 + 入度
```java
List<List<Integer>> g = new ArrayList<>();
for (int i = 0; i < numCourses; i++) g.add(new ArrayList<>());
int[] indeg = new int[numCourses];
for (int[] p : prerequisites) {
    g.get(p[1]).add(p[0]);
    indeg[p[0]]++;
}
```

**步骤 2**：所有入度 0 节点入队
```java
Deque<Integer> queue = new ArrayDeque<>();
for (int i = 0; i < numCourses; i++) if (indeg[i] == 0) queue.offer(i);
```

**步骤 3**：BFS 弹出，记录顺序，更新后继
```java
int[] order = new int[numCourses];
int idx = 0;
while (!queue.isEmpty()) {
    int u = queue.poll();
    order[idx++] = u;
    for (int v : g.get(u)) {
        if (--indeg[v] == 0) queue.offer(v);
    }
}
```

**步骤 4**：判断是否完成
```java
return idx == numCourses ? order : new int[0];
```

---

## 四、Java 题解

```java
class Solution {
    public int[] findOrder(int numCourses, int[][] prerequisites) {
        List<List<Integer>> g = new ArrayList<>();
        for (int i = 0; i < numCourses; i++) g.add(new ArrayList<>());
        int[] indeg = new int[numCourses];
        for (int[] p : prerequisites) {
            g.get(p[1]).add(p[0]);
            indeg[p[0]]++;
        }
        Deque<Integer> queue = new ArrayDeque<>();
        for (int i = 0; i < numCourses; i++) if (indeg[i] == 0) queue.offer(i);

        int[] order = new int[numCourses];
        int idx = 0;
        while (!queue.isEmpty()) {
            int u = queue.poll();
            order[idx++] = u;
            for (int v : g.get(u)) {
                if (--indeg[v] == 0) queue.offer(v);
            }
        }
        return idx == numCourses ? order : new int[0];
    }
}
```

**记忆口诀**：
> **"Kahn 出队即顺序；填满 numCourses 返回，否则空。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(V + E)** |
| 空间 | O(V + E) |

---

## 六、示例验证

`numCourses=4, prerequisites=[[1,0],[2,0],[3,1],[3,2]]`

入度：`[0,1,1,2]`，初始队列 `[0]`

| 出队 | order | indeg 更新 | 队列 |
|---|---|---|---|
| 0 | [0] | indeg[1]→0, indeg[2]→0 | [1, 2] |
| 1 | [0,1] | indeg[3]→1 | [2] |
| 2 | [0,1,2] | indeg[3]→0 | [3] |
| 3 | [0,1,2,3] | — | [] |

返回 `[0,1,2,3]` ✅

---

## 七、复盘与延伸

### 一句话总结
> **Kahn 拓扑排序：出队顺序即学习顺序；完不成（有环）返回空。**

### 新手常见疑问（FAQ）

**Q1：DFS 三色版能不能输出顺序？**
A：能。DFS 时记录 **后序完成顺序**（节点完成时入栈），最后栈逆序就是拓扑顺序。

**Q2：如果有多种合法顺序，怎么稳定输出？**
A：把队列换成 PriorityQueue 按编号升序，每次出最小编号节点。LC 269 求字典序最小拓扑序就是这思路。

**Q3：拓扑顺序唯一吗？**
A：唯一 ⇔ 每一轮队列里只有 1 个节点（即拓扑序是链）。LC 444 验证唯一性。

**Q4：边数 E 上限多大？**
A：`numCourses * (numCourses - 1)`，最坏 2000²=4*10^6，开邻接表足够。

**Q5：自环 [a,a] 怎么办？**
A：a 的入度始终 ≥ 1，永远不入队，最终 idx < numCourses 返回空。

### 面试官常见 follow-up
1. **"只判断能否完成（[LC 207](https://leetcode.cn/problems/course-schedule/)）？"** → 用 finished 计数。
2. **"返回字典序最小的拓扑序？"** → 队列换 PriorityQueue。
3. **"火星词典（[LC 269](https://leetcode.cn/problems/alien-dictionary/)）？"** → 两两比较单词建边，拓扑排序。
4. **"序列重建唯一性（LC 444）？"** → 每轮队列必须恰好 1 节点。
5. **"按学期分层（[LC 1136](https://leetcode.cn/problems/parallel-courses/) 平行课程）？"** → BFS 分层处理，最大层数 = 学期数。
6. **"边带权重，求关键路径？"** → 拓扑序 + DP；项目管理 PERT 图。

### 同类型推荐（**拓扑排序家族**）
- [LC 207. 课程表](https://leetcode.cn/problems/course-schedule/)（判环）
- [LC 269. 火星词典](https://leetcode.cn/problems/alien-dictionary/)
- [LC 310. 最小高度树](https://leetcode.cn/problems/minimum-height-trees/)（拓扑剥叶）
- LC 444. 序列重建
- [LC 802. 找到最终的安全状态](https://leetcode.cn/problems/find-eventual-safe-states/)（反向图拓扑）
- [LC 1136. 平行课程](https://leetcode.cn/problems/parallel-courses/)
- LC 1857. 有向图中最大颜色值
