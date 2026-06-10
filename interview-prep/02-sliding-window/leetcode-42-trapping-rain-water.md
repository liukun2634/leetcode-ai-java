# LeetCode 42. 接雨水 (Trapping Rain Water)

> 难度：Hard　|　标签：数组、双指针、单调栈、动态规划　|	|	**经典中的经典 ⭐⭐⭐⭐**

---

## 一、题目

给定 `n` 个非负整数表示每个宽度为 `1` 的柱子的高度图，计算按此排列的柱子下雨之后能接多少雨水。

**约束**

- `n == height.length`
- `1 <= n <= 2 * 10^4`
- `0 <= height[i] <= 10^5`

**示例**

| 输入 | 输出 |
|---|---|
| `[0,1,0,2,1,0,1,3,2,1,2,1]` | `6` |
| `[4,2,0,3,2,5]` | `9` |

题目链接：<https://leetcode.cn/problems/trapping-rain-water/>

---

## 二、解题思路（学习重点）

### 1. 关键观察：每根柱子上方能存的水 = `min(左边最高, 右边最高) − 自己高度`

> 任何位置 `i` 的水位被两侧最高柱中较矮的那根决定（短板效应）。

**为什么是两侧最高的 min，而不是两侧任意柱**：水要被“围住”才不会流走，如果只看两侧任意柱，那柱可能太矮藏不住水。两侧“最高”才是真正的“墔子边”。上门则是较矮的那个墔子边。

### 2. 三种 O(n) 解法

| 解法 | 思路 | 复杂度 |
|---|---|---|
| **前后缀最大值数组** | 预算 `leftMax[i]`、`rightMax[i]` | 时 O(n) / 空 O(n) |
| **双指针** | 用两个变量替代前后缀数组 | **时 O(n) / 空 O(1)** ⭐ |
| **单调栈** | 横向"按层"计算积水 | 时 O(n) / 空 O(n) |

### 3. 双指针的关键洞察（必须理解）

设 `l`、`r` 两个指针从两端向中间走，同时维护 `leftMax`、`rightMax`：
- 如果 `height[l] < height[r]`：说明 `l` 位置 **右边一定存在 ≥ height[l] 的柱子**（就是 r）→ `l` 的水位完全由 `leftMax` 决定 → 安全计算 `leftMax - height[l]`，然后 `l++`。
- 反之同理处理 `r`。

> **学习点 ①**：双指针法的精髓 = **"较矮的那一侧可以先结算"**，因为另一侧已经给出了"足够高的封顶"保证。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 直接两层循环找两侧最大 → O(n²) | 用双指针 / 前后缀数组 |
| `leftMax` 在比较前更新 → 把当前柱算进去导致水量为负 | **先更新 max 再算差** |
| 边界 `l == r` 处理：当两指针相遇可以结束 | `while (l < r)` 即可 |

---

## 三、详细解题步骤（双指针法）

**步骤 1**：初始化
```java
int l = 0, r = height.length - 1;
int leftMax = 0, rightMax = 0;
int ans = 0;
```

**步骤 2**：循环 `while (l < r)`：

  1. **比较两端高度**：
     - 若 `height[l] < height[r]`：处理左指针
       - 更新 `leftMax = max(leftMax, height[l])`
       - 累加积水：`ans += leftMax - height[l]`
       - `l++`
     - 否则：处理右指针
       - 更新 `rightMax = max(rightMax, height[r])`
       - 累加积水：`ans += rightMax - height[r]`
       - `r--`

**步骤 3**：返回 `ans`。

> **为什么是 `leftMax - height[l]` 而不需要 `rightMax`？**
> 因为进入这个分支时 `height[l] < height[r] ≤ rightMax`（rightMax 不可能比 height[r] 小），所以右侧封顶足够高，水位由 leftMax 决定。

---

## 四、Java 题解

### 解法 A：双指针（推荐，O(1) 空间）

```java
class Solution {
    public int trap(int[] height) {
        int l = 0, r = height.length - 1;
        int leftMax = 0, rightMax = 0, ans = 0;
        while (l < r) {
            if (height[l] < height[r]) {
                leftMax = Math.max(leftMax, height[l]);
                ans += leftMax - height[l];
                l++;
            } else {
                rightMax = Math.max(rightMax, height[r]);
                ans += rightMax - height[r];
                r--;
            }
        }
        return ans;
    }
}
```

**记忆口诀**：
> **"较矮的一侧先结算；更新自己的 max，加上 max 与自己的差。"**

### 解法 B：前后缀最大值数组（直观版）

```java
class Solution {
    public int trap(int[] h) {
        int n = h.length;
        int[] L = new int[n], R = new int[n];
        L[0] = h[0];
        for (int i = 1; i < n; i++) L[i] = Math.max(L[i-1], h[i]);
        R[n-1] = h[n-1];
        for (int i = n-2; i >= 0; i--) R[i] = Math.max(R[i+1], h[i]);
        int ans = 0;
        for (int i = 0; i < n; i++) ans += Math.min(L[i], R[i]) - h[i];
        return ans;
    }
}
```

### 解法 C：单调递减栈（横向"按层"算）

```java
class Solution {
    public int trap(int[] h) {
        Deque<Integer> st = new ArrayDeque<>();
        int ans = 0;
        for (int i = 0; i < h.length; i++) {
            while (!st.isEmpty() && h[i] > h[st.peek()]) {
                int bottom = st.pop();
                if (st.isEmpty()) break;
                int left = st.peek();
                int width = i - left - 1;
                int height = Math.min(h[left], h[i]) - h[bottom];
                ans += width * height;
            }
            st.push(i);
        }
        return ans;
    }
}
```

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 双指针 | **O(n)** | **O(1)** |
| 前后缀数组 | O(n) | O(n) |
| 单调栈 | O(n) | O(n) |

---

## 六、示例验证

`height = [0,1,0,2,1,0,1,3,2,1,2,1]`，双指针法：

| 步 | l | r | h[l] | h[r] | leftMax | rightMax | 加水 | ans |
|---|---|---|---|---|---|---|---|---|
| 1 | 0 | 11 | 0 | 1 | 0 | 0 | 0 (l→1) | 0 |
| 2 | 1 | 11 | 1 | 1 | 1 | 1 | 0 (r→10) | 0 |
| 3 | 1 | 10 | 1 | 2 | 1 | 1 | 0 (l→2) | 0 |
| 4 | 2 | 10 | 0 | 2 | 1 | 1 | 1 (l→3) | 1 |
| 5 | 3 | 10 | 2 | 2 | 2 | 2 | 0 (r→9) | 1 |
| 6 | 3 | 9 | 2 | 1 | 2 | 2 | 1 (r→8) | 2 |
| 7 | 3 | 8 | 2 | 2 | 2 | 2 | 0 (r→7) | 2 |
| 8 | 3 | 7 | 2 | 3 | 2 | 2 | 0 (l→4) | 2 |
| 9 | 4 | 7 | 1 | 3 | 2 | 2 | 1 (l→5) | 3 |
| 10 | 5 | 7 | 0 | 3 | 2 | 2 | 2 (l→6) | 5 |
| 11 | 6 | 7 | 1 | 3 | 2 | 2 | 1 (l→7) | 6 |

`l == r`，结束。`ans = 6` ✅

---

## 七、复盘与延伸

### 一句话总结
> **每根柱子上方水量 = min(左最高, 右最高) − 自身；双指针让"较矮一侧"先结算，O(1) 空间搞定。**

### 新手常见疑问（FAQ）

**Q1：双指针中为什么“较矮一侧可以直接结算”？**
A：进入 `height[l] < height[r]` 分支时，右侧还有一根 `height[r]` 起码为 `height[r] ≥ height[l]` 的柱（就是 r），这保证 l 右侧的 rightMax 肯定 ≥ height[l]，水位完全由 leftMax 决定。右侧究竟多高不重要，反正够高。

**Q2：为什么 leftMax 要“先更新再算差”？**
A：若先算差后更新，当 `height[l] > 原 leftMax` 时，`leftMax - height[l]` 是负数 → `ans` 错。先更新后 `leftMax ≥ height[l]`，差值总是 ≥ 0。

**Q3：单调栈解法在“横向按层”是什么意思？**
A：双指针是“竖向按列”累加每个位置的水柱；单调栈是“横向按层”，每次出栈得到一个左高-底-右高 的渝槽，算出该层的面积。两者总和相等。

**Q4：二维版（LC 407）怎么变？**
A：二维不能简单双指针。用最小堆从外圈向内扩展（BFS）：水位被“当前边界最低点”决定，每次弹最低边界点、更新邻居。

**Q5：总水量会不会溢出 int？**
A：最坏 n=2×10^4、高 10^5 → 面积 ≤ 2×10^9，超过 `int` 范围。面试能提一句“极端场景该用 long”是加分项。

### 面试官常见 follow-up
1. **"盛最多水的容器（[LC 11](https://leetcode.cn/problems/container-with-most-water/)）和本题区别在哪？"** → [LC 11](https://leetcode.cn/problems/container-with-most-water/) 只需选两根柱形成水桶，双指针总是移动较矮者；本题考虑每个位置都会藏水。
2. **"二维接雨水怎么做？"** → 最小堆 + BFS，从外圈向内扩。即 [**LC 407**](https://leetcode.cn/problems/trapping-rain-water-ii/)。
3. **"允许修改某柱高度一次，求最大接水量？"** → 枚举修改位置 + 预算前后缀最大，多个 O(n) 扫描。
4. **"能用单调栈、双指针、前后缀三种都写一遍吗？"** → 面试高频考题。三种思路体现“同一问题不同视角”，讲出双指针为何 O(1) 空间是加分项。
5. **"柱子高度可为负（比如凹陷）？"** → 柱子本身不可为负（不然水会从侧面漏）。理论上负值只意味“间隔中部开口”，需重新定义问题。
6. **"数据流场景（柱子一根根动态加入）？"** → 难：双指针需要两端，不能在线。只能用前后缀动态维护 + 重算，或跟踪变化的局部区间。

### 自我提问
1. 为什么"较矮一侧"可以直接结算？→ 因为另一侧已存在更高柱，封顶有保障，水位完全由自己一侧 max 决定。
2. 单调栈法在算什么？→ "横向按层"计算积水：每次弹出栈底，左右两根柱形成一个"凹槽"。
3. 二维版（LC 407 接雨水 II）？→ 用堆从外圈向内扩展（最小堆维护边界），是 BFS + 优先队列。
4. 为什么前后缀数组法叫"动态规划"？→ `L[i]` = `max(L[i-1], h[i])` 是经典最优子结构。

### 同类型推荐
- [LC 11. 盛最多水的容器](https://leetcode.cn/problems/container-with-most-water/)（双指针的"姊妹"题，更易上手）
- [LC 84. 柱状图中最大的矩形](https://leetcode.cn/problems/largest-rectangle-in-histogram/)（单调栈天花板）
- [LC 407. 接雨水 II](https://leetcode.cn/problems/trapping-rain-water-ii/)（二维 + 堆）
- [LC 238. 除自身以外数组的乘积](https://leetcode.cn/problems/product-of-array-except-self/)（前后缀思想）
- [LC 845. 数组中的最长山脉](https://leetcode.cn/problems/longest-mountain-in-array/)
- [LC 1793. 好子数组的最大分数](https://leetcode.cn/problems/maximum-score-of-a-good-subarray/)
