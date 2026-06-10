# LeetCode 23. 合并 K 个升序链表 (Merge K Sorted Lists)

> 难度：Hard　|　标签：链表、堆、分治　|　**K 路合并模板 ⭐⭐⭐⭐**

---

## 一、题目

给你一个链表数组，每个链表都已经按升序排列。请你将所有链表合并到一个升序链表中，返回合并后的链表。

**约束**

- `k == lists.length`，`0 <= k <= 10^4`
- `0 <= lists[i].length <= 500`，节点值 `[-10^4, 10^4]`，节点总数 `<= 10^4`

**示例**

```
输入：[[1,4,5], [1,3,4], [2,6]]
输出：[1,1,2,3,4,4,5,6]
```

题目链接：<https://leetcode.cn/problems/merge-k-sorted-lists/>

---

## 二、解题思路（学习重点）

### 1. 三档常见解法对比

| 解法 | 时间 | 空间 | 何时选 |
|---|---|---|---|
| 暴力（全装数组 → 排序） | O(N log N) | O(N) | 简单粗暴 |
| **小顶堆（推荐）** | **O(N log k)** | O(k) | 最自然，工程常用 |
| **分治两两合并** | O(N log k) | O(log k) 栈 | 不需 PQ 时备选 |

> N 是节点总数，k 是链表个数。

### 2. 小顶堆模板（推荐）

把 k 个链表头放入小顶堆，每次弹堆顶最小节点接入结果链表，再把它的 next（若有）放入堆。

> **学习点 ①**：**"K 路合并 / 多路归并"** 永远先想小顶堆。同模板：LC 264 丑数 II、LC 373、LC 632 最小区间、[LC 378](https://leetcode.cn/problems/kth-smallest-element-in-a-sorted-matrix/) 矩阵第 K 小。

### 3. 分治合并

类似归并排序：
- 把 k 个链表两两合并
- 每轮链表数减半，共 log k 轮
- 每轮总工作量 O(N)
- 合计 O(N log k)

每次"两路合并"复用 LC 21 模板。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 优先队列 `Comparator` 写错（升序 vs 降序）| `(a, b) -> a.val - b.val` （小顶堆）|
| 链表数组里有 null（空链表）| 入堆前判 null |
| 不用 dummy 头 | 结果链表头处理麻烦 |
| 分治写成"逐个合并到结果上"O(NK) | 必须**两两合并**才是 O(N log k) |

---

## 三、详细解题步骤（小顶堆版）

**步骤 1**：建小顶堆
```java
PriorityQueue<ListNode> pq = new PriorityQueue<>((a, b) -> a.val - b.val);
```

**步骤 2**：把所有链表头入堆（跳过 null）
```java
for (ListNode head : lists) if (head != null) pq.offer(head);
```

**步骤 3**：dummy + tail，不断弹堆顶接入
```java
ListNode dummy = new ListNode(0), tail = dummy;
while (!pq.isEmpty()) {
    ListNode node = pq.poll();
    tail.next = node;
    tail = node;
    if (node.next != null) pq.offer(node.next);
}
return dummy.next;
```

---

## 四、Java 题解

### 解法 A：小顶堆（推荐）

```java
class Solution {
    public ListNode mergeKLists(ListNode[] lists) {
        PriorityQueue<ListNode> pq = new PriorityQueue<>((a, b) -> a.val - b.val);
        for (ListNode head : lists) if (head != null) pq.offer(head);

        ListNode dummy = new ListNode(0), tail = dummy;
        while (!pq.isEmpty()) {
            ListNode node = pq.poll();
            tail.next = node;
            tail = node;
            if (node.next != null) pq.offer(node.next);
        }
        return dummy.next;
    }
}
```

**记忆口诀**：
> **"头入堆，弹顶接，弹谁推谁的 next。"**

### 解法 B：分治两两合并

```java
class Solution {
    public ListNode mergeKLists(ListNode[] lists) {
        if (lists.length == 0) return null;
        return divide(lists, 0, lists.length - 1);
    }
    private ListNode divide(ListNode[] lists, int l, int r) {
        if (l == r) return lists[l];
        int m = (l + r) >>> 1;
        ListNode left  = divide(lists, l, m);
        ListNode right = divide(lists, m + 1, r);
        return merge(left, right);
    }
    private ListNode merge(ListNode a, ListNode b) {
        ListNode dummy = new ListNode(0), tail = dummy;
        while (a != null && b != null) {
            if (a.val <= b.val) { tail.next = a; a = a.next; }
            else                { tail.next = b; b = b.next; }
            tail = tail.next;
        }
        tail.next = (a != null) ? a : b;
        return dummy.next;
    }
}
```

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 小顶堆 | **O(N log k)** | O(k) |
| 分治 | O(N log k) | O(log k) |
| 暴力 | O(N log N) | O(N) |

---

## 六、示例验证

`[[1,4,5], [1,3,4], [2,6]]`

| 步 | 堆 | 弹 | 推入 | 结果链表 |
|---|---|---|---|---|
| init | [1,1,2] | — | — | dummy |
| 1 | [1,2,4] | 1 (来自 L1) | 4 | →1 |
| 2 | [2,3,4] | 1 (来自 L2) | 3 | →1→1 |
| 3 | [3,4,6] | 2 | 6 | →1→1→2 |
| 4 | [4,4,6] | 3 | 4 | →1→1→2→3 |
| 5 | [4,5,6] | 4 (L2) | — | →1→1→2→3→4 |
| 6 | [5,6] | 4 (L1) | 5 | →1→1→2→3→4→4 |
| 7 | [5,6] | 5 | — | →...→5 |
| 8 | [6] | 6 | — | →...→6 |

输出 `[1,1,2,3,4,4,5,6]` ✅

---

## 七、复盘与延伸

### 一句话总结
> **K 路合并 = 小顶堆装头节点；弹堆顶接链表，把它的 next 推入堆。**

### 新手常见疑问（FAQ）

**Q1：为什么是 O(N log k) 而不是 O(N log N)？**
A：堆大小始终 ≤ k（只装链表头），每个节点入堆 1 次出堆 1 次，单次操作 O(log k)。总 N 个节点 → O(N log k)。

**Q2：分治为什么也是 O(N log k)？**
A：第一轮 k 个合并为 k/2，每对合并的总节点数和约 N → O(N)；共 log k 轮 → O(N log k)。**逐个合并到一个结果链表**是 O(NK)，慢得多。

**Q3：能否用大顶堆？**
A：能但反着来，最后要 reverse 结果。代码更长。

**Q4：堆 Comparator 用 `a.val - b.val` 安全吗？**
A：`val` 范围 `[-10⁴, 10⁴]`，差不溢出。安全做法：`Integer.compare(a.val, b.val)`。

**Q5：链表全为空怎么办？**
A：循环里 `if (head != null)` 跳过，堆空直接 break，返回 `dummy.next = null`。

### 面试官常见 follow-up
1. **"如果不让用堆呢？"** → 分治两两合并。代码更长但思路一样。
2. **"K 个有序数组求最小元素？"** → 同模板，堆元素改成 `(value, arrIdx, elemIdx)`。
3. **"K 个数组的最小区间（LC 632）？"** → 堆 + 维护当前 max；窗口长度 = max - min。
4. **"流式：链表不断到来，求实时合并？"** → 来一个就 offer，符合本题模型。
5. **"线程池 + 分治并行？"** → 分治版可分到不同线程；堆版难并行。
6. **"如果 k 很大（10⁵）但每条只 1 个节点呢？"** → 退化为对 N 个数排序，O(N log N)。考虑直接 sort。

### 同类型推荐（**K 路合并 / 堆家族**）
- [LC 21. 合并两个有序链表](https://leetcode.cn/problems/merge-two-sorted-lists/)（两路合并，本题子问题）
- LC 264. 丑数 II（堆 + 去重）
- LC 373. 查找和最小的 K 对数字
- [LC 378. 有序矩阵中第 K 小的元素](https://leetcode.cn/problems/kth-smallest-element-in-a-sorted-matrix/)
- LC 632. 最小区间
- [LC 295. 数据流的中位数](https://leetcode.cn/problems/find-median-from-data-stream/)（双堆）
