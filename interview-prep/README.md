# LeetCode 面试备考路线图

> 目标：通过 **15 道核心模板题 + 50 道高频扩展题**，覆盖大厂算法面试 95% 的考点。
> 风格：每题都包含 **题意 → 思路 → Java 模板 → 复杂度 → 示例 → 复盘问答 + 同类型推荐**。
> 本地测试 & Java 经验（见 [`../java-toolkit/`](../java-toolkit/README.md)）：
> - [`java-leetcode-io-template/`](../java-toolkit/java-leetcode-io-template/README.md) —— LeetCode 风格输入 `[1,2,3]`，自带链表/树解析
> - [`java-io-template/`](../java-toolkit/java-io-template/README.md) —— 通用人工/竞赛输入 `5\n1 2 3 4 5`，三档速度 Scanner / BufferedReader / StreamTokenizer
> - [`java-leetcode-collections/`](../java-toolkit/java-leetcode-collections/README.md) —— Java 集合在刷题中的常用类与方法速查（队列/栈/链表/数组/哈希/堆/树映射）

---

## 一、备考阶段规划（建议 4~6 周）

| 阶段 | 周数 | 任务 | 验收标准 |
|---|---|---|---|
| **Phase 0 - 热身** | 第 0 周 | 熟悉 Java 集合（`ArrayList` / `HashMap` / `Deque` / `PriorityQueue` / `TreeMap`）、Big-O、IDE | 能默写 `HashMap` 的 `getOrDefault`、`PriorityQueue` 自定义比较器 |
| **Phase 1 - 模板** | 第 1~2 周 | 刷完本仓库 [10 个分类](#二十大分类与核心模板)的 15 道核心模板题，**每题手写 3 遍** | 每题能在 20 分钟内 bug-free 写完 |
| **Phase 2 - 高频** | 第 3~4 周 | 扩展刷 [面试高频题清单](#三高频题清单top-50) | 每天 4~6 题，能口述思路 |
| **Phase 3 - 模拟** | 第 5 周 | LeetCode 每日一题 + 模拟面试（白板/Cursor 关闭提示）| 限时 25 分钟出解，能讲清复杂度 |
| **Phase 4 - 复盘** | 第 6 周 | 错题本回顾、按公司 tag 突击（OA + 真题）| 95% 通过率 |

---

## 二、十大分类与核心模板

> 顺序就是建议的学习顺序：从直觉简单到抽象复杂。

| # | 分类 | 核心模板题（必刷 ⭐） | 模板要点 |
|---|---|---|---|
| 1 | [数组与哈希](./01-array-hash/) | [Two Sum](./01-array-hash/leetcode-1-two-sum.md)、[3Sum](./01-array-hash/leetcode-15-3sum.md)、[Maximum Subarray](./01-array-hash/leetcode-53-maximum-subarray.md) | `HashMap` 一遍扫；排序后双指针；Kadane DP |
| 2 | [双指针与滑动窗口](./02-sliding-window/) | [Longest Substring Without Repeating](./02-sliding-window/leetcode-3-longest-substring-without-repeating.md) | `while (右扩)` `while (左缩)` 的固定骨架 |
| 3 | [链表](./03-linked-list/) | [Reverse Linked List](./03-linked-list/leetcode-206-reverse-linked-list.md) | dummy 头 + prev/curr/next 三指针 |
| 4 | [栈与队列](./04-stack-queue/) | [Valid Parentheses](./04-stack-queue/leetcode-20-valid-parentheses.md) | 配对栈、单调栈、单调队列 |
| 5 | [二分查找](./05-binary-search/) | [Search in Rotated Sorted Array](./05-binary-search/leetcode-33-search-rotated-sorted-array.md) | 闭区间模板 + 比较中点和右端 |
| 6 | [树](./06-tree/) | [Binary Tree Level Order](./06-tree/leetcode-102-binary-tree-level-order.md)、[LCA](./06-tree/leetcode-236-lowest-common-ancestor.md) | BFS 队列分层；递归"分治返回" |
| 7 | [图与搜索](./07-graph/) | [Number of Islands](./07-graph/leetcode-200-number-of-islands.md)、[Course Schedule](./07-graph/leetcode-207-course-schedule.md) | DFS 染色；Kahn 拓扑排序 |
| 8 | [回溯](./08-backtracking/) | [Permutations](./08-backtracking/leetcode-46-permutations.md) | 路径 + 选择列表 + 撤销 |
| 9 | [动态规划](./09-dp/) | [Coin Change](./09-dp/leetcode-322-coin-change.md)、[LIS](./09-dp/leetcode-300-longest-increasing-subsequence.md) | 完全背包；序列 DP + 二分优化 |
| 10 | [堆与 TopK](./10-heap/) | [Kth Largest Element](./10-heap/leetcode-215-kth-largest-element.md) | 小顶堆维护 K 大；快速选择 |

---

## 三、高频题清单（Top 50）

> 已在本仓库提供详细题解的标 ✅；其余按下表自刷。难度：🟢 Easy / 🟡 Medium / 🔴 Hard

### 1) 数组 & 哈希
- ✅ [1. Two Sum](./01-array-hash/leetcode-1-two-sum.md) 🟢
- ✅ [15. 3Sum](./01-array-hash/leetcode-15-3sum.md) 🟡
- ✅ [53. Maximum Subarray](./01-array-hash/leetcode-53-maximum-subarray.md) 🟡
- ✅ [49. Group Anagrams](./01-array-hash/leetcode-49-group-anagrams.md) 🟡
- ✅ [128. Longest Consecutive Sequence](./01-array-hash/leetcode-128-longest-consecutive-sequence.md) 🟡
- ✅ [56. Merge Intervals](./01-array-hash/leetcode-56-merge-intervals.md) 🟡
- ✅ [238. Product of Array Except Self](./01-array-hash/leetcode-238-product-of-array-except-self.md) 🟡
- ✅ [41. First Missing Positive](./01-array-hash/leetcode-41-first-missing-positive.md) 🔴

### 2) 双指针 & 滑动窗口
- ✅ [3. Longest Substring Without Repeating Characters](./02-sliding-window/leetcode-3-longest-substring-without-repeating.md) 🟡
- ✅ [11. Container With Most Water](./01-array-hash/leetcode-11-container-with-most-water.md) 🟡
- ✅ [42. Trapping Rain Water](./02-sliding-window/leetcode-42-trapping-rain-water.md) 🔴
- ✅ [76. Minimum Window Substring](./02-sliding-window/leetcode-76-minimum-window-substring.md) 🔴
- ✅ [438. Find All Anagrams in a String](./02-sliding-window/leetcode-438-find-all-anagrams.md) 🟡
- ✅ [209. Minimum Size Subarray Sum](./02-sliding-window/leetcode-209-minimum-size-subarray-sum.md) 🟡

### 3) 链表
- ✅ [206. Reverse Linked List](./03-linked-list/leetcode-206-reverse-linked-list.md) 🟢
- ✅ [21. Merge Two Sorted Lists](./03-linked-list/leetcode-21-merge-two-sorted-lists.md) 🟢
- 141. Linked List Cycle 🟢
- ✅ [142. Linked List Cycle II](./03-linked-list/leetcode-142-linked-list-cycle-ii.md) 🟡
- ✅ [25. Reverse Nodes in k-Group](./03-linked-list/leetcode-25-reverse-nodes-in-k-group.md) 🔴
- ✅ [146. LRU Cache](./03-linked-list/leetcode-146-lru-cache.md) 🟡（设计题，必考）

### 4) 栈 & 队列
- ✅ [20. Valid Parentheses](./04-stack-queue/leetcode-20-valid-parentheses.md) 🟢
- ✅ [155. Min Stack](./04-stack-queue/leetcode-155-min-stack.md) 🟡
- ✅ [84. Largest Rectangle in Histogram](./04-stack-queue/leetcode-84-largest-rectangle-in-histogram.md) 🔴（单调栈天花板）
- ✅ [739. Daily Temperatures](./04-stack-queue/leetcode-739-daily-temperatures.md) 🟡
- ✅ [239. Sliding Window Maximum](./04-stack-queue/leetcode-239-sliding-window-maximum.md) 🔴（单调队列）

### 5) 二分查找
- ✅ [33. Search in Rotated Sorted Array](./05-binary-search/leetcode-33-search-rotated-sorted-array.md) 🟡
- ✅ [153. Find Minimum in Rotated Sorted Array](./05-binary-search/leetcode-153-find-min-rotated.md) 🟡
- ✅ [4. Median of Two Sorted Arrays](./05-binary-search/leetcode-4-median-two-sorted-arrays.md) 🔴
- ✅ [875. Koko Eating Bananas](./05-binary-search/leetcode-875-koko-eating-bananas.md) 🟡（答案二分）

### 6) 树
- ✅ [102. Binary Tree Level Order Traversal](./06-tree/leetcode-102-binary-tree-level-order.md) 🟡
- ✅ [236. Lowest Common Ancestor](./06-tree/leetcode-236-lowest-common-ancestor.md) 🟡
- ✅ [98. Validate Binary Search Tree](./06-tree/leetcode-98-validate-bst.md) 🟡
- ✅ [124. Binary Tree Maximum Path Sum](./06-tree/leetcode-124-binary-tree-maximum-path-sum.md) 🔴
- ✅ [297. Serialize and Deserialize Binary Tree](./06-tree/leetcode-297-serialize-tree.md) 🔴
- ✅ [199. Binary Tree Right Side View](./06-tree/leetcode-199-right-side-view.md) 🟡

### 7) 图
- ✅ [200. Number of Islands](./07-graph/leetcode-200-number-of-islands.md) 🟡
- ✅ [207. Course Schedule](./07-graph/leetcode-207-course-schedule.md) 🟡
- ✅ [210. Course Schedule II](./07-graph/leetcode-210-course-schedule-ii.md) 🟡
- ✅ [994. Rotting Oranges](./07-graph/leetcode-994-rotting-oranges.md) 🟡
- ✅ [547. Number of Provinces](./07-graph/leetcode-547-number-of-provinces.md) 🟡（并查集模板）

### 8) 回溯
- ✅ [46. Permutations](./08-backtracking/leetcode-46-permutations.md) 🟡
- ✅ [78. Subsets](./08-backtracking/leetcode-78-subsets.md) 🟡
- ✅ [39. Combination Sum](./08-backtracking/leetcode-39-combination-sum.md) 🟡
- ✅ [22. Generate Parentheses](./08-backtracking/leetcode-22-generate-parentheses.md) 🟡
- ✅ [51. N-Queens](./08-backtracking/leetcode-51-n-queens.md) 🔴

### 9) 动态规划
- ✅ [322. Coin Change](./09-dp/leetcode-322-coin-change.md) 🟡
- ✅ [300. Longest Increasing Subsequence](./09-dp/leetcode-300-longest-increasing-subsequence.md) 🟡
- ✅ [70. Climbing Stairs](./09-dp/leetcode-70-climbing-stairs.md) 🟢
- ✅ [198. House Robber](./09-dp/leetcode-198-house-robber.md) 🟡
- ✅ [72. Edit Distance](./09-dp/leetcode-72-edit-distance.md) 🔴
- ✅ [1143. Longest Common Subsequence](./09-dp/leetcode-1143-longest-common-subsequence.md) 🟡
- ✅ [121](./09-dp/leetcode-121-best-time-to-buy-and-sell-stock.md)/[122](./09-dp/leetcode-122-best-time-stock-ii.md)/123/188. Best Time to Buy and Sell Stock 系列 🟡~🔴

### 10) 堆 / 贪心 / 其他
- ✅ [215. Kth Largest Element in an Array](./10-heap/leetcode-215-kth-largest-element.md) 🟡
- ✅ [23. Merge k Sorted Lists](./03-linked-list/leetcode-23-merge-k-sorted-lists.md) 🔴
- ✅ [295. Find Median from Data Stream](./10-heap/leetcode-295-find-median-from-data-stream.md) 🔴（双堆）
- ✅ [55. Jump Game](./09-dp/leetcode-55-jump-game.md) 🟡（贪心）
- 45. Jump Game II 🟡
- ✅ [208. Implement Trie](./10-heap/leetcode-208-implement-trie.md) 🟡
- ✅ [347. Top K Frequent Elements](./10-heap/leetcode-347-top-k-frequent.md) 🟡
- ✅ [460. LFU Cache](./10-heap/leetcode-460-lfu-cache.md) 🔴（设计题进阶）

---

## 四、刷题方法论（少走弯路）

### A. 三遍刷题法
1. **第一遍（理解）**：看不懂就直接看题解，搞懂为什么这么写，照抄一遍跑通。
2. **第二遍（默写）**：1~3 天后合上题解，独立写出来；写错了对照差异点记笔记。
3. **第三遍（讲解）**：1~2 周后白板讲给自己/他人听，能说清"为什么这个算法 / 复杂度 / 边界"。

### B. 错题本的正确写法
> 错题本不是抄题目，是抄 **"思维错点"**。模板：

```
- 题号 + 链接
- 我第一反应的解法（错的或慢的）
- 正确解法的核心 "一句话洞见"
- 我踩的具体 bug（如：边界 / 越界 / 类型 / 死循环）
- 同类型的迁移题：__
```

### C. 面试白板沟通模板（极其重要）

> 即使写出正确代码，沟通拉胯也会挂。固定 5 步：

1. **澄清题意**（2 分钟）：举一两个边界例子和面试官确认（空数组？负数？重复元素？）。
2. **暴力解 + 复杂度**（2 分钟）：先说一个 O(n²) 的笨办法，证明你不是死记硬背。
3. **优化思路**（5 分钟）：说出关键观察 → 选用的数据结构 → 复杂度。**写代码之前先达成共识**。
4. **写代码**（10 分钟）：边写边讲变量含义。
5. **跑测试 + 边界讨论**（5 分钟）：用自己举的例子 dry-run 一遍；讨论扩展（数据流？多线程？）。

### D. 时间分配建议（限时 30 分钟单题）
| 阶段 | 时间 | 红线 |
|---|---|---|
| 看懂 + 想思路 | 5 分钟 | 超时直接看 hint |
| 写代码 | 15 分钟 | 卡 5 分钟就看题解，别死磕 |
| 调试 | 5 分钟 | — |
| 复盘 & 记笔记 | 5 分钟 | **不能省**，否则白刷 |

---

## 五、Java 必备工具速查

```java
// 哈希
Map<Integer, Integer> map = new HashMap<>();
map.getOrDefault(k, 0);
map.computeIfAbsent(k, x -> new ArrayList<>()).add(v);

// 排序
Arrays.sort(arr);
Arrays.sort(arr, (a, b) -> a - b);              // 数组用比较器要 Integer[]
list.sort((a, b) -> b - a);

// 栈 / 队列 / 双端
Deque<Integer> stack = new ArrayDeque<>();      // 比 Stack 快
Deque<Integer> queue = new ArrayDeque<>();      // offer / poll
Deque<Integer> dq    = new ArrayDeque<>();      // 单调队列 offerLast/pollFirst/pollLast

// 堆
PriorityQueue<Integer> minHeap = new PriorityQueue<>();
PriorityQueue<Integer> maxHeap = new PriorityQueue<>((a, b) -> b - a);

// 树节点
class TreeNode { int val; TreeNode left, right; }
class ListNode { int val; ListNode next; }

// 常用集合操作
char[] chars = s.toCharArray();
String.valueOf(chars);
Arrays.asList(1, 2, 3);
Arrays.copyOfRange(arr, l, r);   // [l, r)
```

---

## 六、本仓库使用建议

1. 按上面 [二、十大分类](#二十大分类与核心模板)顺序，先把每个分类的 ⭐ 题目读懂。
2. 每读完一题，**合上文档**自己默写一遍，用 LeetCode 提交验证。
3. 卡住时打开对应 `.md` 的 **"复盘问答"** 一节自测，能默答说明掌握了。
4. 进入 Phase 2 后，按 [Top 50 清单](#三高频题清单top-50) 自刷，遇到模板不熟再回查本仓库。
5. 临近面试，只看每篇文档的 **"记忆口诀"** 和 **"复盘问答"** 做最后冲刺。

> 祝你 offer 拿到手软！
