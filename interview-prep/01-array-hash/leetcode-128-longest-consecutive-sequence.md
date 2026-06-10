# LeetCode 128. 最长连续序列 (Longest Consecutive Sequence)

> 难度：Medium　|　标签：哈希表、并查集　|　**哈希优化经典 ⭐⭐⭐**

---

## 一、题目

给定一个未排序的整数数组 `nums`，找出数字 **连续** 的最长序列（不要求序列元素在原数组中连续）的长度。

请你设计并实现 **时间复杂度为 O(n)** 的算法解决此问题。

**约束**

- `0 <= nums.length <= 10^5`
- `-10^9 <= nums[i] <= 10^9`

**示例**

| 输入 | 输出 | 序列 |
|---|---|---|
| `[100,4,200,1,3,2]` | `4`  | `[1,2,3,4]` |
| `[0,3,7,2,5,8,4,6,0,1]` | `9` | `[0..8]` |

题目链接：<https://leetcode.cn/problems/longest-consecutive-sequence/>

---

## 二、解题思路（学习重点）

### 1. 排序解法 O(n log n) 不达标

题目要 O(n)。排序解法虽然能通过，但不符合"最优"要求。

### 2. O(n) 关键洞察：**只从"序列起点"出发计数**

**从暴力到 O(n) 的思路**：
- 天真做法：对每个元素 x，看 x+1, x+2, ... 是否都在 `HashSet`。最坏 O(n²)——如 `[1,2,3,...,n]` 从 1 的起点会走 n 步，从 2 又走 n-1 步…总共 O(n²)。
- 关键优化：一个序列 `[a, a+1, ..., a+k]`，只需要从起点 a 出发数一次就能拿到全长；从中间任何位置出发都是重复劳动。**只要能识别“起点”并仅从起点出发**，总工作量就是 O(n)。

把所有数装进 `HashSet`。对每个数 `x`，**判断它是否是连续序列的起点**：
- `x` 是起点 ⇔ `x - 1` 不在集合中
- 是起点 → 一直 `x+1, x+2, ...` 在集合里就计数

**为什么是 O(n) 不是 O(n²)？**
- 内层 while 累计跑过的元素总和 ≤ n（每个元素只会作为"被向上数"出现一次）。
- 外层 n 次 `contains` 都是 O(1)。
- 总操作 ≤ 2n → **O(n)**。

> **学习点 ①**：**"只从起点扩展"** 是哈希优化的精髓。同样思路出现在 "最大岛屿面积"、"环路 / 路径长度" 等题。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 没有"判起点"，对每个数都向上数 → O(n²) | **必须** 加 `if (!set.contains(x-1))` 这一行 |
| 用 `ArrayList` 当容器 → `contains` O(n) | 必须 `HashSet` |
| 重复元素未去重 | `HashSet` 天然去重，不用额外处理 |

---

## 三、详细解题步骤

**步骤 1**：边界
- `if (nums.length == 0) return 0;`

**步骤 2**：把所有元素放入 HashSet
```java
Set<Integer> set = new HashSet<>();
for (int x : nums) set.add(x);
```

**步骤 3**：遍历 set（**不是 nums，避免重复处理同一数**），对每个 `x` 判断是否起点：
  1. 若 `set.contains(x - 1)` → 跳过（不是起点）。
  2. 否则：
     - 初始化 `cur = x, len = 1`
     - **while** `set.contains(cur + 1)`：`cur++; len++;`
     - 更新 `best = max(best, len);`

**步骤 4**：返回 `best`。

---

## 四、Java 题解

```java
class Solution {
    public int longestConsecutive(int[] nums) {
        Set<Integer> set = new HashSet<>();
        for (int x : nums) set.add(x);

        int best = 0;
        for (int x : set) {                       // 注意遍历 set（自带去重）
            if (set.contains(x - 1)) continue;    // 只从起点出发
            int cur = x, len = 1;
            while (set.contains(cur + 1)) {
                cur++; len++;
            }
            best = Math.max(best, len);
        }
        return best;
    }
}
```

**记忆口诀**：
> **"装入 HashSet，只从起点向上数，长度取最大。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n)**（每个元素最多被"被起点向上数"一次） |
| 空间 | O(n) |

---

## 六、示例验证

`[100, 4, 200, 1, 3, 2]`，set = `{100, 4, 200, 1, 3, 2}`

| x | 是起点？（`x-1` 不在 set）| 向上扩展 | len | best |
|---|---|---|---|---|
| 100 | ✅（99 不在）| 101 不在，停 | 1 | 1 |
| 4 | ❌（3 在），跳过 | — | — | 1 |
| 200 | ✅ | 201 不在，停 | 1 | 1 |
| 1 | ✅（0 不在）| 2→3→4，5 不在停 | 4 | **4** |
| 3 | ❌跳过 | — | — | 4 |
| 2 | ❌跳过 | — | — | 4 |

输出 `4` ✅

---

## 七、复盘与延伸

### 一句话总结
> **HashSet 装下所有数，只从"序列起点"向上扩展，复杂度摊销 O(n)。**

### 新手常见疑问（FAQ）

**Q1：不加 `if (!set.contains(x-1))` 判起点会怎样？**
A：退化为 O(n²)。反例 `[1,2,...,n]`：从 1 走 n 步，从 2 走 n-1 步…总共 n(n+1)/2 次 contains，辏跳 TLE。这一行是从 O(n²) 变 O(n) 的关键。

**Q2：为什么是遍历 `set` 而不是 `nums`？**
A：两者都可以，但遍历 set 能避免重复数重复处理。如 `nums=[1,1,1,1]`，遍历 nums 会试 4 次“1 是不是起点”；遍历 set 只试 1 次。轻微优化。

**Q3：为什么不能用 `ArrayList.contains`？**
A：`ArrayList.contains` 是 O(n) 线性扫描，总复杂度变 O(n²)。必须用 `HashSet`/`HashMap` 才能 O(1) 查询。

**Q4：重复元素需要特别处理吗？**
A：不需要。`HashSet` 天然去重，`[1,1,2,3]` 与 `[1,2,3]` 产生同样的 set，结果一样。

**Q5：能不能用排序做？哪里不达标？**
A：排序后扫一遍 O(n log n)，简单且能 AC。不达标是题目“请设计 O(n) 算法”的明示要求。面试要主动领会这个限制。

### 面试官常见 follow-up
1. **"怎么返回最长序列本身而不只是长度？"** → 记录 `best` 同时记起点 x，返回时 `[x, x+1, ..., x+best-1]`。
2. **"用并查集怎么做？"** → 把 `x` 与 `x+1` union，最后统计最大连通分量大小。复杂度同阶但常数大，代码长。
3. **"是二叉树上的最长连续序列呢？"** → DFS，比较父子节点值是否差 1。即 [**LC 298**](https://leetcode.cn/problems/binary-tree-longest-consecutive-sequence/)。
4. **"数组中缺失的第一个正整数（同是连续性考题）？"** → 原地哈希：把 `nums[i]` 换到位置 `nums[i]-1`，扫一遍看哪个位置不匹配。即 [**LC 41**](https://leetcode.cn/problems/first-missing-positive/)。
5. **"数据流场景（随时添加、查询最长连续长度）？"** → `TreeMap<起点, 长度>` 维护不重叠序列区间，插入时合并附近序列。
6. **"数范围很小（如 [0,n)），能不能用位图代替 HashSet？"** → 可以，用 `BitSet`。空间 n/8 字节，缓存友好。

### 自我提问
1. 为什么不直接对每个数向上数？→ O(n²) 最坏（如 `1..n` 都从 1 开始数）。
2. 复杂度怎么严格证明是 O(n)？→ 内层 while 跑过的所有元素总数 ≤ n（每个元素至多出现在一次"起点向上"扩展中）。
3. 能否用并查集？→ 可以：把 `x` 和 `x+1` union；最后统计最大连通分量大小。代码更长，复杂度同阶但常数更大。
4. 怎么返回最长序列本身？→ 记录 best 时同步记录起点。

### 同类型推荐
- [LC 1. Two Sum](https://leetcode.cn/problems/two-sum/)（哈希 O(1) 查询基础）
- [LC 41. 缺失的第一个正数](https://leetcode.cn/problems/first-missing-positive/)（原地哈希，O(1) 空间）
- [LC 1218. 最长定差子序列](https://leetcode.cn/problems/longest-subarray-with-bounded-difference/)（哈希 + DP）
- [LC 298. 二叉树最长连续序列](https://leetcode.cn/problems/binary-tree-longest-consecutive-sequence/)（树版）
- [LC 685. 冗余连接](https://leetcode.cn/problems/redundant-connection-ii/)（并查集）
