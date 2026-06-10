# LeetCode 84. 柱状图中最大的矩形 (Largest Rectangle in Histogram)

> 难度：Hard　|　标签：栈、单调栈、数组　|	|	**单调栈天花板 ⭐⭐⭐⭐**

---

## 一、题目

给定 `n` 个非负整数，用来表示柱状图中各个柱子的高度。每个柱子彼此相邻，且宽度为 `1`。

求在该柱状图中，能够勾勒出来的矩形的 **最大面积**。

**约束**

- `1 <= heights.length <= 10^5`
- `0 <= heights[i] <= 10^4`

**示例**

| 输入 | 输出 |
|---|---|
| `[2,1,5,6,2,3]` | `10`（高度 5 和 6 组成宽 2 高 5） |
| `[2,4]` | `4` |

题目链接：<https://leetcode.cn/problems/largest-rectangle-in-histogram/>

---

## 二、解题思路（学习重点）

### 1. 暴力 O(n²) 思路

对每根柱子 `i`，向左找第一根比它矮的下标 `L`，向右找第一根比它矮的下标 `R`，则以 `heights[i]` 为高的最大矩形宽度 = `R - L - 1`，面积 = `heights[i] * (R - L - 1)`。

朴素找 L、R 是 O(n²)；**单调栈把它降到 O(n)**。

### 2. 为什么是单调栈？

我们要找的是 **"每根柱子的左/右第一个更矮的柱子"**。
- 这正是 **单调递增栈** 的核心用途。
- 维护一个 **栈内元素严格递增** 的栈（存的是下标）。当新元素 `heights[i]` 比栈顶矮时，栈顶元素的"右边第一个更矮"就找到了（就是 i），它的"左边第一个更矮"就是 **它在栈里的前一个元素**。

> **学习点 ①**：**"找下一个更小/更大"** 永远用单调栈；找更小用递增栈，找更大用递减栈。

### 3. 哨兵 0 简化代码（**强烈推荐**）

为了避免循环结束后栈里还有元素需要单独处理，在 `heights` 末尾**虚拟追加一个高度 0**：
- 它比任何柱子都矮 → 强制把栈里所有柱子全部弹空 → 统一处理。

实现上可以新建一个 `int[n+1]` 数组，也可以在循环结束后追加一次"虚拟 i = n, h = 0"的处理。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 弹栈后忘了 "左边第一个更矮" = 栈顶 | 弹出后 `left = stack.peek()`，**`width = i - left - 1`** |
| 栈为空时 `left = -1`（虚拟左哨兵） | 写 `int left = stack.isEmpty() ? -1 : stack.peek();` |
| 没有右哨兵 → 循环结束后栈里仍有元素未处理 | 加哨兵 0 / 最后再来一次"i = n, h = 0" 处理 |

---

## 三、详细解题步骤

**步骤 1**：开栈（存下标，递增）
```java
Deque<Integer> stack = new ArrayDeque<>();
int n = heights.length, max = 0;
```

**步骤 2**：遍历 `i = 0..n`（最后一次 `i == n` 当作哨兵）：
```java
for (int i = 0; i <= n; i++) {
    int curH = (i == n) ? 0 : heights[i];     // 哨兵高度 0
    while (!stack.isEmpty() && heights[stack.peek()] > curH) {
        int topIdx = stack.pop();             // 即将被结算的柱子
        int leftIdx = stack.isEmpty() ? -1 : stack.peek();
        int width = i - leftIdx - 1;
        max = Math.max(max, heights[topIdx] * width);
    }
    stack.push(i);
}
```

**步骤 3**：返回 `max`。

### 关键思维（必须能讲清楚）

- 弹出 `topIdx` 时：`i` 就是它"右边第一个更矮"的位置；`stack.peek()`（弹后栈顶）就是它"左边第一个更矮"的位置。
- 中间所有柱子都 ≥ `heights[topIdx]`（栈递增 + 我们正在弹），所以以 `heights[topIdx]` 为高的最大矩形宽度 = `i - leftIdx - 1`。

---

## 四、Java 题解

```java
class Solution {
    public int largestRectangleArea(int[] heights) {
        Deque<Integer> stack = new ArrayDeque<>();
        int n = heights.length, max = 0;
        for (int i = 0; i <= n; i++) {
            int curH = (i == n) ? 0 : heights[i];
            while (!stack.isEmpty() && heights[stack.peek()] > curH) {
                int topIdx = stack.pop();
                int leftIdx = stack.isEmpty() ? -1 : stack.peek();
                int width = i - leftIdx - 1;
                max = Math.max(max, heights[topIdx] * width);
            }
            stack.push(i);
        }
        return max;
    }
}
```

**记忆口诀**：
> **"递增栈存下标，遇到更矮就结算；宽 = i − 左 − 1，加哨兵收尾。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n)** —— 每个元素入栈一次、出栈一次 |
| 空间 | O(n) 栈 |

---

## 六、示例验证

`heights = [2, 1, 5, 6, 2, 3]`（追加哨兵 0）

| i | h | stack（顶在右） | 弹栈结算 | max |
|---|---|---|---|---|
| 0 | 2 | [0] | — | 0 |
| 1 | 1 | 弹 0：left=-1, w=1-(-1)-1=1, area=2 → push 1 → [1] | area=2 | 2 |
| 2 | 5 | [1, 2] | — | 2 |
| 3 | 6 | [1, 2, 3] | — | 2 |
| 4 | 2 | 弹 3：left=2, w=4-2-1=1, area=6 → 弹 2：left=1, w=4-1-1=2, area=10 → push 4 → [1, 4] | area=6, **10** | **10** |
| 5 | 3 | [1, 4, 5] | — | 10 |
| 6 | 0(哨兵) | 弹 5：left=4, w=6-4-1=1, area=3 → 弹 4：left=1, w=6-1-1=4, area=8 → 弹 1：left=-1, w=6-(-1)-1=6, area=6 → push 6 | 3, 8, 6 | 10 |

输出 `10` ✅

---

## 七、复盘与延伸

### 一句话总结
> **单调递增栈：栈顶被弹时，结算"以它为高、左右各到第一个更矮"的矩形面积。**

### 新手常见疑问（FAQ）

**Q1：为什么栈里存下标而不是高度？**
A：计宽度需要下标差。只存高度的话无法算 `i - leftIdx - 1` 这个宽度。

**Q2：哨兵 0 是贴在末尾还是两边都加？**
A：只加末尾一个就够（本代码的 `i == n` 判断），以强制弹空栈。头部哨兵 -1 隐式存在：弹后 `stack.isEmpty()` 时 `left=-1`。

**Q3：为什么是 `heights[stack.peek()] > curH` 而不是 `>=`？**
A：`>` 和 `>=` 都能 AC。重复高度时后来者会在后续结算中覆盖前面的计算。严格递增只是打扫者身份不同，不影响最终 max。

**Q4：为什么这题是 O(n) 而不是 O(n²)？**
A：每个下标最多入栈一次、出栈一次。总操作 ≤ 2n。这是单调栈“线性总量”的经典摄裴。

**Q5：二维版（LC 85 最大矩形）怎么转化？**
A：逐行看作 histogram：该行某列高度 = 该列从顶到该行连续 `1` 的个数（遇 `0` 则重置）。对每行调本题 → 总复杂度 O(mn)。

### 面试官常见 follow-up
1. **"二维最大矩形（全 0/1 矩阵）？"** → 逐行调 [LC 84](https://leetcode.cn/problems/largest-rectangle-in-histogram/)。即 [**LC 85**](https://leetcode.cn/problems/maximal-rectangle/)。
2. **"只需要某一个柱子能形成的最大矩形？"** → 本题实际就是对每根柱子都算一遍。中途某一个的答案也可取。
3. **"接雨水与本题都是单调栈，区别在哪？"** → 接雨水用递减栈（找下个更高），本题递增栈（找下个更矮）。体现“找更大/更小”的双生性。
4. **"柱高可重复，要不要去重？"** → 不需要，同高度的柱在后面的结算中会被后来者覆盖。
5. **"在调用中能否避免哨兵？"** → 可以，循环后多写一段 `while (!stack.isEmpty()) 结算`，代码更长。哨兵是代码上的优雅护护联。
6. **"n=10⁹ 量级还能跳么？"** → O(n) 时间 + O(n) 空间，内存是主要瓶颈；可能要考虑堆外存储。

### 同类型推荐（**单调栈家族**）
- [LC 85. 最大矩形](https://leetcode.cn/problems/maximal-rectangle/)（二维 + 本题）
- [LC 42. 接雨水](https://leetcode.cn/problems/trapping-rain-water/)（递减栈）
- [LC 496. 下一个更大元素 I](https://leetcode.cn/problems/next-greater-element-i/)
- [LC 503. 下一个更大元素 II](https://leetcode.cn/problems/next-greater-element-ii/)（循环数组）
- [LC 739. 每日温度](https://leetcode.cn/problems/daily-temperatures/)
- [LC 901. 股票价格跨度](https://leetcode.cn/problems/online-stock-span/)
- [LC 1019. 链表中的下一个更大节点](https://leetcode.cn/problems/next-greater-node-in-linked-list/)
- [LC 962. 最大宽度坡](https://leetcode.cn/problems/maximum-width-ramp/)（变种）
