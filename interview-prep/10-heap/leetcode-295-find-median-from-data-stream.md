# [LeetCode 295. 数据流的中位数 (Find Median from Data Stream)](https://leetcode.com/problems/find-median-from-data-stream/)

> 难度：Hard　|　标签：堆、设计、数据流　|	|	**双堆模板天花板 ⭐⭐⭐⭐**

---

## 一、题目

**中位数** 是有序整数列表中的中间值。如果列表的大小是偶数，则没有中间值，中位数是两个中间值的平均值。

设计一个支持以下两种操作的数据结构：

- `void addNum(int num)`：从数据流中添加一个整数到数据结构中。
- `double findMedian()`：返回目前所有元素的中位数。

**约束**

- 调用 `addNum` 和 `findMedian` 的次数不超过 `5 * 10^4`

**进阶**：
1. 如果数据流中所有整数都在 `[0, 100]` 范围内，你将如何优化算法？
2. 如果数据流中 `99%` 的整数都在 `[0, 100]` 范围内，你将如何优化算法？

---

## 二、解题思路（学习重点）

### 1. 关键洞察：**用两个堆维护"中间"**

把数据流分成两半：
- **左半（较小的一半）** → **大顶堆 `lo`**（堆顶是这半中的最大值）
- **右半（较大的一半）** → **小顶堆 `hi`**（堆顶是这半中的最小值）

满足两个不变量：
1. `lo` 中所有元素 ≤ `hi` 中所有元素
2. **大小关系**：`lo.size()` 等于 `hi.size()`，或恰好多 1

那么：
- **总数偶数** → 中位数 = `(lo.top + hi.top) / 2`
- **总数奇数** → 中位数 = `lo.top`（因为 lo 多 1 个）

> **学习点 ①**：**"动态求第 k 大 / 中位数"** 的通用模板就是 **双堆**。同模板：LC 480（滑动窗口中位数）、LC 1825（流的 MK 平均）。

### 2. `addNum` 怎么维持不变量？

**两步法**（推荐，简洁）：
1. **先无脑加到大顶堆 `lo`**
2. **把 `lo` 的最大值移到 `hi`**（保证 lo 的所有值都 ≤ hi 的所有值）
3. **如果 `hi` 比 `lo` 多 → 把 `hi` 最小值移回 `lo`**（维持 lo 多或相等）

这样不论新 `num` 多大多小，最终都满足两个不变量。

### 3. 进阶问题简答

- **范围 [0, 100]**：用 **桶计数**（101 个桶），`findMedian` 累加桶找中位。
- **99% 在 [0, 100]**：主用桶 + 用两个数组兜底极端值。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| Java 默认 `PriorityQueue` 是小顶堆 | 大顶堆要传 `(a, b) -> b - a` 或 `Collections.reverseOrder()` |
| 偶数求平均时整数溢出 | 用 `(lo.peek() + hi.peek()) / 2.0` 而非 `(int + int) / 2` |
| 直接 if 判断大小放堆 → 不变量难维护 | **统一两步法**最简洁 |

---

## 三、详细解题步骤

**步骤 1**：定义两个堆
```java
private PriorityQueue<Integer> lo = new PriorityQueue<>(Collections.reverseOrder()); // 大顶
private PriorityQueue<Integer> hi = new PriorityQueue<>();                            // 小顶
```

**步骤 2**：`addNum(num)`：
```java
lo.offer(num);              // 1. 先加到大顶堆
hi.offer(lo.poll());        // 2. 把 lo 的 max 移到 hi
if (hi.size() > lo.size()) {
    lo.offer(hi.poll());    // 3. 平衡：让 lo 多 0 或 1
}
```

**步骤 3**：`findMedian()`：
```java
if (lo.size() > hi.size()) return lo.peek();          // 奇数
return (lo.peek() + hi.peek()) / 2.0;                 // 偶数
```

---

## 四、Java 题解

```java
class MedianFinder {
    private final PriorityQueue<Integer> lo = new PriorityQueue<>(Collections.reverseOrder());
    private final PriorityQueue<Integer> hi = new PriorityQueue<>();

    public void addNum(int num) {
        lo.offer(num);
        hi.offer(lo.poll());
        if (hi.size() > lo.size()) {
            lo.offer(hi.poll());
        }
    }

    public double findMedian() {
        return lo.size() > hi.size()
             ? (double) lo.peek()
             : (lo.peek() + hi.peek()) / 2.0;
    }
}
```

**记忆口诀**：
> **"加 lo → 转 hi → 回 lo 保平衡；奇看 lo 顶，偶取两顶均。"**

---

## 五、复杂度

| 操作 | 时间 | 空间 |
|---|---|---|
| `addNum` | **O(log n)** | O(n) |
| `findMedian` | **O(1)** | O(n) |

---

## 六、示例验证

```
addNum(1)  → lo=[1], hi=[]                    (步骤: lo+1, hi+1, lo回1)
                                              过程：lo.add(1)=[1]；hi.add(lo.poll())=[1]，lo=[]；hi.size>lo.size → lo.add(hi.poll()=1)，lo=[1] hi=[]
findMedian → 1.0

addNum(2)  → lo=[1], hi=[2]                   过程：lo.add(2)=[2,1]；hi.add(lo.poll()=2)，lo=[1] hi=[2]；size 相等不调
findMedian → (1+2)/2 = 1.5

addNum(3)  → lo=[2,1], hi=[3]
findMedian → 2.0
```

✅

---

## 七、复盘与延伸

### 一句话总结
> **大顶堆装较小一半、小顶堆装较大一半；加 lo→转 hi→回 lo 保平衡。**

### 新手常见疑问（FAQ）

**Q1：为什么不能 “if num < lo.peek() 则加 lo，否则加 hi”？**
A：能写，但加完后还需要平衡，还要处理初始为空的边界，代码烦。「两步法」（先 lo 后转 hi 再平衡）统一不需边界判断，更不易错。

**Q2：为什么 lo 多 1 而不是 hi 多 1？**
A：两者都可以，只是约定。选择 lo 多让「奇数个时返回 lo.peek()」类型转换更自然（`int` 直接 `double`）。

**Q3：Java 如何建立大顶堆？**
A：三种写法：`new PriorityQueue<>(Collections.reverseOrder())` / `new PriorityQueue<>((a, b) -> b - a)` / `new PriorityQueue<>((a, b) -> Integer.compare(b, a))`。三者避免溢出选第三种。

**Q4：偶数时为什么 `/ 2.0` 而不是 `/ 2`？**
A：`int / int` 是整除，1+2=3 整除 2 是 1（业入 0.5）。`2.0` 强迫转浮点；也可写 `(lo.peek() + (long) hi.peek()) / 2.0` 防溢出。

**Q5：滑动窗口中位数（LC 480）难在哪？**
A：需要删除滑出窗口的元素，但 PriorityQueue 不支持 O(log n) 删除任意元素。两种解法：① 延迟删除（标记到查询才弹）；② 用 `TreeMap<Integer, Integer>` 作多重集。

### 面试官常见 follow-up
1. **"滑动窗口中位数？"** → 双堆 + 延迟删除；或 TreeMap 多重集。即 **LC 480**。
2. **"只要求第 k 大项（k 固定）？"** → 单堆即可：小顶堆保持 size = k。即 **LC 703**。
3. **"求 MK 平均值（去掉头尾各 k 个后平均）？"** → 三堆 + 双端队列。即 **LC 1825**。
4. **"范围是 [0, 100]？"** → 101 个桶计数，addNum O(1)，findMedian O(101) 扫描。
5. **"99% 在 [0, 100]？"** → 主路用桶 + 另外两个有序结构决额外值。
6. **"多线程访问？"** → 外加 `ReentrantLock`；或为读多写少场景用 RWLock 提升读吞吐。

### 同类型推荐（**堆设计家族**）
- LC 480. 滑动窗口中位数（**双堆 + 延迟删除**，🔴）
- LC 703. 数据流中的第 K 大元素（单堆）
- LC 215. 数组中的第 K 个最大元素
- LC 23. 合并 K 个升序链表（小顶堆）
- LC 1825. 求出 MK 平均值（双堆 + 双端队列）
- LC 358. K 距离间隔重排字符串（堆 + 队列）
