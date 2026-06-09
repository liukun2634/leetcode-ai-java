# [LeetCode 347. 前 K 个高频元素 (Top K Frequent Elements)](https://leetcode.com/problems/top-k-frequent-elements/)

> 难度：Medium　|　标签：哈希、堆、桶排序、快速选择　|　**TopK 频次模板 ⭐⭐⭐**

---

## 一、题目

给你一个整数数组 `nums` 和一个整数 `k`，请你返回其中出现频率前 `k` 高的元素。你可以按 **任意顺序** 返回答案。

进阶：算法时间复杂度 **必须优于 `O(n log n)`**。

**约束**

- `1 <= nums.length <= 10^5`
- `k 是有效的，1 <= k <= 数组中不同的元素的个数`
- 题目数据保证答案唯一

**示例**

| 输入 | 输出 |
|---|---|
| `nums=[1,1,1,2,2,3], k=2` | `[1, 2]` |
| `nums=[1], k=1` | `[1]` |

---

## 二、解题思路（学习重点）

### 1. 三档解法对比

| 解法 | 时间 | 空间 |
|---|---|---|
| 排序所有不同元素按频次 | O(n log n) | O(n) |
| **小顶堆维护 K 个高频（推荐）** | **O(n log k)** | O(n) |
| **桶排序 O(n)** | O(n) | O(n) |
| 快速选择 | 期望 O(n) | O(n) |

### 2. 小顶堆模板

第一步：哈希表统计频次 `freq[num]`。
第二步：小顶堆按频次排序，维护大小为 k 的堆：
- 堆满后只有"频次 > 堆顶频次"的元素才能进
- 进的同时弹出堆顶

最终堆里就是 Top K，依次弹出。

> **学习点 ①**：**"TopK + 频次"** 第一反应 = **小顶堆维护 K 大**（按比较键）。同模板：LC 215（K 大）、LC 692（前 K 高频单词）、LC 973（K 个最近原点）。

### 3. 桶排序 O(n)

频次范围 `[1, n]`，开 `n + 1` 个桶：`buckets[freq] = List<num>`。

从高频桶向低频桶遍历，取 k 个元素即可。**真正 O(n)**。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 堆 Comparator 写反 | 小顶堆按频次升序：`(a, b) -> freq.get(a) - freq.get(b)` |
| 堆大小忘了限制 | 必须 `if (heap.size() > k) heap.poll()` |
| 桶排序桶大小用 `n` 而非 `n + 1` | 频次最大为 n，下标 n 需要存在 |
| 用 `int[k]` 数组返回时类型错 | Java 8 `stream.mapToInt(Integer::intValue).toArray()` |

---

## 三、详细解题步骤（小顶堆版）

**步骤 1**：统计频次
```java
Map<Integer, Integer> freq = new HashMap<>();
for (int x : nums) freq.merge(x, 1, Integer::sum);
```

**步骤 2**：小顶堆按频次
```java
PriorityQueue<Integer> heap = new PriorityQueue<>((a, b) -> freq.get(a) - freq.get(b));
for (int key : freq.keySet()) {
    heap.offer(key);
    if (heap.size() > k) heap.poll();
}
```

**步骤 3**：弹出
```java
int[] ans = new int[k];
for (int i = 0; i < k; i++) ans[i] = heap.poll();
return ans;
```

---

## 四、Java 题解

### 解法 A：小顶堆（推荐）

```java
class Solution {
    public int[] topKFrequent(int[] nums, int k) {
        Map<Integer, Integer> freq = new HashMap<>();
        for (int x : nums) freq.merge(x, 1, Integer::sum);

        PriorityQueue<Integer> heap = new PriorityQueue<>((a, b) -> freq.get(a) - freq.get(b));
        for (int key : freq.keySet()) {
            heap.offer(key);
            if (heap.size() > k) heap.poll();
        }
        int[] ans = new int[k];
        for (int i = 0; i < k; i++) ans[i] = heap.poll();
        return ans;
    }
}
```

**记忆口诀**：
> **"频次哈希；小顶堆按频排；超 k 就弹。"**

### 解法 B：桶排序（O(n)）

```java
class Solution {
    public int[] topKFrequent(int[] nums, int k) {
        Map<Integer, Integer> freq = new HashMap<>();
        for (int x : nums) freq.merge(x, 1, Integer::sum);

        List<Integer>[] buckets = new List[nums.length + 1];
        for (Map.Entry<Integer, Integer> e : freq.entrySet()) {
            int f = e.getValue();
            if (buckets[f] == null) buckets[f] = new ArrayList<>();
            buckets[f].add(e.getKey());
        }

        int[] ans = new int[k];
        int idx = 0;
        for (int f = buckets.length - 1; f >= 0 && idx < k; f--) {
            if (buckets[f] == null) continue;
            for (int num : buckets[f]) {
                ans[idx++] = num;
                if (idx == k) break;
            }
        }
        return ans;
    }
}
```

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 小顶堆 | **O(n log k)** | O(n) |
| 桶排序 | **O(n)** | O(n) |
| 快速选择 | 期望 O(n) | O(n) |

---

## 六、示例验证

`nums = [1,1,1,2,2,3], k = 2`

**频次**：`{1: 3, 2: 2, 3: 1}`

**小顶堆**：
| 操作 | 堆（顶在左） |
|---|---|
| offer 1 | [1(3)] |
| offer 2 → size > 2? no | [2(2), 1(3)] |
| offer 3 → size 3 > 2 → 弹顶 3(1) | [2(2), 1(3)] |

最终 `[2, 1]` 或 `[1, 2]`（顺序不限）✅

---

## 七、复盘与延伸

### 一句话总结
> **频次哈希 + 小顶堆维护 K 大；或桶排序 O(n)。**

### 新手常见疑问（FAQ）

**Q1：为什么用小顶堆？**
A：小顶堆顶是 k 个里最小的。新元素 > 堆顶才有资格挤掉它，最终留下 k 个最大。如果用大顶堆，得装全部 n 个元素才能拿 top k。

**Q2：桶排序为什么是 O(n)？**
A：桶数 ≤ n+1，遍历桶 O(n)；每个 num 放一个桶 O(n)；总 O(n)。

**Q3：堆 Comparator 升序还是降序？**
A：小顶堆按比较键升序（`a < b` 时 a 在堆顶）。这里按频次升序：`freq[a] - freq[b]`。

**Q4：如果 k 等于不同元素数？**
A：答案就是所有不同元素。算法仍正确。

**Q5：题目说答案唯一，意味着什么？**
A：频次第 k 高的元素只有一个候选，不会出现 "并列第 k" 的歧义。否则需要二级排序（如按值升序）。

### 面试官常见 follow-up
1. **"前 K 高频单词（LC 692，并列时按字典序）？"** → 堆 Comparator 加二级排序。
2. **"前 K 个最近原点（LC 973）？"** → 大顶堆按距离平方排序。
3. **"流式数据，每来一个数报告 Top K？"** → 堆维护 K 大，O(log k)/次。
4. **"K 很大（接近 n）怎么办？"** → 改用大顶堆或排序。
5. **"低频前 K 个？"** → 大顶堆，逻辑对称。
6. **"分布式：每台机器有部分数据，合并求全局 Top K？"** → 每台先算 local TopK，主节点合并堆。

### 同类型推荐（**TopK 家族**）
- LC 215. 数组中第 K 个最大元素
- LC 692. 前 K 个高频单词
- LC 973. 最接近原点的 K 个点
- LC 1046. 最后一块石头的重量（大顶堆模拟）
- LC 295. 数据流的中位数（双堆）
- LC 703. 数据流中的第 K 大元素
