# LeetCode 215. 数组中的第 K 个最大元素 (Kth Largest Element in an Array)

> 难度：Medium　|　标签：堆、快速选择、分治　|　**TopK 模板 ⭐⭐⭐**

---

## 一、题目

给定整数数组 `nums` 和整数 `k`，请返回数组中 **第 `k` 个最大** 的元素（不是去重后的第 k 大，是排序后的第 k 个）。

请你设计并实现 **时间复杂度为 O(n)** 的算法解决此问题。

**约束**

- `1 <= k <= nums.length <= 10^5`
- `-10^4 <= nums[i] <= 10^4`

**示例**

| 输入 | 输出 |
|---|---|
| `nums=[3,2,1,5,6,4], k=2` | `5` |
| `nums=[3,2,3,1,2,4,5,5,6], k=4` | `4` |

题目链接：<https://leetcode.cn/problems/kth-largest-element-in-an-array/>

---

## 二、解题思路（学习重点）

### 1. 三档常见解法对比

| 解法 | 时间 | 空间 | 何时选 |
|---|---|---|---|
| **排序** | O(n log n) | O(1) | 简单暴力，写得最快 |
| **小顶堆** | O(n log k) | O(k) | 适合 k << n，或数据流 |
| **快速选择** | 期望 O(n)，最坏 O(n²) | O(1)~O(log n) | 题目要 O(n) 时唯一选择 |

> **学习点 ①**：**"第 k 大 / 第 k 小 / TopK"** 默认两套模板：**小顶堆**（在线/流式） 与 **快速选择**（离线一次性）。

### 2. 小顶堆模板

维护一个 **大小为 k 的小顶堆**，遍历数组：
- 堆 size < k → push
- 堆顶 < x → 弹堆顶，push x

最终堆顶就是第 k 大（堆里是最大的 k 个，最小那个就是第 k 大）。

### 3. 快速选择（QuickSelect）

借用快排的 partition 思路：
- 随机选一个 pivot，把数组分为 `< pivot | == pivot | > pivot` 三段。
- 第 k 大 = 升序第 `n-k` 小，等价问题。
- 根据 pivot 所在区间和目标位置，**只递归一边**（这是 O(n) 的关键）。

> **学习点 ②**：快排是 O(n log n) 因为两边都要递归；快速选择 **只走一边**，期望 T(n) = T(n/2) + O(n) = **O(n)**。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 用大顶堆排全数组 → O(n log n) 浪费 | 用小顶堆只保留 k 个 |
| 快速选择不随机 → 有序数据 O(n²) | **必须随机选 pivot** |
| 第 k 大 vs 第 k 小搞反 | 升序里 **第 k 大 = 第 (n-k) 小**（0-indexed）|

---

## 三、Java 题解

### 解法 A：小顶堆（推荐先掌握）

```java
class Solution {
    public int findKthLargest(int[] nums, int k) {
        PriorityQueue<Integer> heap = new PriorityQueue<>(k);
        for (int x : nums) {
            if (heap.size() < k) heap.offer(x);
            else if (heap.peek() < x) {
                heap.poll();
                heap.offer(x);
            }
        }
        return heap.peek();
    }
}
```

**记忆口诀**：
> **"小顶堆保 K 大，堆顶就是答。"**

### 解法 B：快速选择（满足 O(n) 要求）

```java
class Solution {
    private final Random rng = new Random();
    public int findKthLargest(int[] nums, int k) {
        // 第 k 大 等价于 升序第 (n-k) 小（0-indexed 即下标 n-k）
        return quickSelect(nums, 0, nums.length - 1, nums.length - k);
    }
    private int quickSelect(int[] a, int l, int r, int idx) {
        if (l == r) return a[l];
        int pivot = a[l + rng.nextInt(r - l + 1)];
        int i = l, j = r, p = l;
        // 三向切分：< pivot | == pivot | > pivot
        while (p <= j) {
            if      (a[p] < pivot) swap(a, i++, p++);
            else if (a[p] > pivot) swap(a, p, j--);
            else p++;
        }
        if      (idx < i) return quickSelect(a, l, i - 1, idx);
        else if (idx > j) return quickSelect(a, j + 1, r, idx);
        else              return pivot;
    }
    private void swap(int[] a, int x, int y) { int t = a[x]; a[x] = a[y]; a[y] = t; }
}
```

---

## 四、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 排序 | O(n log n) | O(1) |
| 小顶堆 | O(n log k) | O(k) |
| 快速选择 | **期望 O(n)**，最坏 O(n²) | O(log n) 递归 |

---

## 五、示例验证

`nums = [3,2,1,5,6,4], k = 2`

**小顶堆解法**：

| x | 堆操作 | 堆内容 (顶在左) |
|---|---|---|
| 3 | push (<k) | [3] |
| 2 | push (<k) | [2,3] |
| 1 | 堆顶 2 ≥ 1 跳过 | [2,3] |
| 5 | 顶 2 < 5：弹 push | [3,5] |
| 6 | 顶 3 < 6：弹 push | [5,6] |
| 4 | 顶 5 ≥ 4 跳过 | [5,6] |

堆顶 = **5** ✅

---

## 六、复盘与延伸

### 一句话总结
> **TopK 问题：小顶堆维护 K 大；要 O(n) 就用快速选择，pivot 随机化避免最坏。**

### 新手常见疑问（FAQ）

**Q1：为什么不能用大顶堆保留 K 大？**
A：大顶堆要拿到第 K 大需要依次弹 K-1 次堆顶，且必须装下所有 n 个元素。小顶堆只需装 K 个，堆顶天然是第 K 大。

**Q2：快速选择为什么是期望 O(n) 而不是 O(n log n)？**
A：快排 T(n) = 2T(n/2) + O(n) = O(n log n)。快选只递归一边 T(n) = T(n/2) + O(n) = O(n)（期望上，随机 pivot）。

**Q3：为什么快选要随机化？**
A：有序数组 + 始终选首元素作 pivot 会退化为 O(n²)。随机 pivot 让护退概率极低。加上三向切分（处理重复值）进一步护护联。

**Q4：“第 k 大”与“升序第 (n-k) 小”下标怎么转？**
A：设 0-indexed：升序后下标 0 是最小，下标 n-1 是最大。第 k 大 = 下标 `n - k` 的元素。快选中传 `idx = n - k`。

**Q5：能不能直接 `Arrays.sort` 然后取下标？**
A：能 AC，但是 O(n log n)，不满足题目“请设计 O(n) 算法”要求。面试需主动领会这个限制。

### 面试官常见 follow-up
1. **"数据流中求第 K 大？"** → 小顶堆保持大小 K，addNum O(log K)。即 **LC 703**。
2. **"前 K 高频元素？"** → 哈希计数 + 小顶堆按频次；或桶排序 O(n)。即 **LC 347**。
3. **"最接近原点的 K 个点？"** → 大顶堆按距离平方，堆大于 K 则弹顶。即 **LC 973**。
4. **"多个数组合并后求第 K 小？"** → 小顶堆装 (值, 数组编号, 下标)，类 LC 23 合并。
5. **"有序矩阵中第 K 小？"** → 小顶堆 BFS；或二分答案。即 **LC 378**。
6. **"如果允许修改数组，要返回前 K 大下标集合？"** → 快选后取右半部分；不要求顺序。

### 同类型推荐（**TopK / 堆家族**）
- LC 703. 数据流中的第 K 大元素（小顶堆经典）
- LC 692. 前 K 个高频单词
- LC 347. 前 K 个高频元素（桶排序 / 堆）
- LC 295. 数据流的中位数（**双堆** 必刷）
- LC 23. 合并 K 个升序链表（堆）
- LC 378. 有序矩阵中第 K 小的元素（堆 / 二分）
- LC 973. 最接近原点的 K 个点
- LC 1046. 最后一块石头的重量（大顶堆模拟）
