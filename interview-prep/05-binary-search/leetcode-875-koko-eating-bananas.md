# LeetCode 875. 爱吃香蕉的珂珂 (Koko Eating Bananas)

> 难度：Medium　|　标签：数组、二分查找、答案二分　|　**答案二分模板 ⭐⭐⭐**

---

## 一、题目

珂珂喜欢吃香蕉。这里有 `n` 堆香蕉，第 `i` 堆中有 `piles[i]` 根香蕉。警卫 `h` 小时后回来。

珂珂可以决定每小时吃香蕉的速度 `k`（根/小时）。每个小时她选择一堆香蕉，吃 `k` 根。如果这堆少于 `k` 根，她就吃完这堆，**不能再吃别的**（这一小时浪费剩余时间）。

返回她可以在 `h` 小时内吃完所有香蕉的 **最小速度 `k`**。

**约束**

- `1 <= piles.length <= 10^4`
- `piles.length <= h <= 10^9`
- `1 <= piles[i] <= 10^9`

**示例**

| 输入 | 输出 |
|---|---|
| `piles=[3,6,7,11], h=8` | `4` |
| `piles=[30,11,23,4,20], h=5` | `30` |
| `piles=[30,11,23,4,20], h=6` | `23` |

题目链接：<https://leetcode.cn/problems/koko-eating-bananas/>

---

## 二、解题思路（学习重点）

### 1. 关键洞察：答案具有 **单调性**

设吃速 `k`：
- `k` 越大，吃完所需小时数 **越少（单调不增）**
- `k` 越小，吃完所需小时数越多

→ 存在一个分界点 `k*`：`k ≥ k*` 都能在 h 内吃完，`k < k*` 都不行。

**找最小满足条件的 k** = 经典 **答案二分**（也叫"二分答案"、"二分一个量"）。

> **学习点 ①**：题目要求"最小/最大满足条件的整数"，且 **结果有单调性** → **二分答案**。判断函数 `check(k)` 是否成立，分界点即答案。

### 2. 二分骨架

```text
l = 1, r = max(piles)               // 答案范围
while l < r:
    mid = (l + r) / 2
    if 能在 h 内吃完(mid): r = mid    // mid 可行，尝试更小
    else                  : l = mid + 1
return l
```

### 3. `check(k)`：计算速度 k 时所需小时数

每堆 `p` 需要 `ceil(p / k)` 小时。

`ceil(p / k)` 写法：`(p + k - 1) / k`（整数除法上取整）。

判断 `sum(ceil(p / k)) <= h`。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| `l = 0` 导致除零 | `l = 1` 起 |
| `r = sum(piles)` 太大可能溢出 | `r = max(piles)`（每小时最多吃一堆，速度 ≥ max 时正好 piles.length 小时） |
| `(p + k - 1)` 溢出 | 用 long |
| 求和也可能溢出 | `long hours` |
| 用 `l <= r` 配 `r = mid` 死循环 | 用 `l < r` |

---

## 三、详细解题步骤

**步骤 1**：初始化范围
```java
int l = 1, r = 0;
for (int p : piles) r = Math.max(r, p);
```

**步骤 2**：二分
```java
while (l < r) {
    int mid = (l + r) >>> 1;
    if (canFinish(piles, mid, h)) r = mid;
    else                          l = mid + 1;
}
return l;
```

**步骤 3**：`canFinish(piles, k, h)`
```java
long hours = 0;
for (int p : piles) hours += (p + k - 1) / k;
return hours <= h;
```

---

## 四、Java 题解

```java
class Solution {
    public int minEatingSpeed(int[] piles, int h) {
        int l = 1, r = 0;
        for (int p : piles) r = Math.max(r, p);

        while (l < r) {
            int mid = (l + r) >>> 1;
            if (canFinish(piles, mid, h)) r = mid;
            else                          l = mid + 1;
        }
        return l;
    }
    private boolean canFinish(int[] piles, int k, int h) {
        long hours = 0;
        for (int p : piles) {
            hours += (p + k - 1) / k;       // ceil(p / k)
            if (hours > h) return false;     // 早停优化
        }
        return true;
    }
}
```

**记忆口诀**：
> **"答案二分：可行就缩右、不可行就涨左；分界点即解。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n · log(max(piles)))** |
| 空间 | O(1) |

---

## 六、示例验证

`piles=[3,6,7,11], h=8`，范围 `[1, 11]`

| 轮 | l | r | mid | hours | check | 收缩 |
|---|---|---|---|---|---|---|
| 1 | 1 | 11 | 6 | ⌈3/6⌉+⌈6/6⌉+⌈7/6⌉+⌈11/6⌉=1+1+2+2=6 ≤ 8 ✓ | OK | r=6 |
| 2 | 1 | 6 | 3 | 1+2+3+4=10 > 8 ✗ | fail | l=4 |
| 3 | 4 | 6 | 5 | 1+2+2+3=8 ≤ 8 ✓ | OK | r=5 |
| 4 | 4 | 5 | 4 | 1+2+2+3=8 ≤ 8 ✓ | OK | r=4 |
| 退出 | 4 | 4 | — | — | — | 答案 4 ✅ |

---

## 七、复盘与延伸

### 一句话总结
> **答案二分：吃速 k 与所需时间单调；用 check(k) 缩范围，l == r 即最小可行速度。**

### 新手常见疑问（FAQ）

**Q1：怎么识别"答案二分"？**
A：题目要求"最小/最大 X，使得某条件成立"，且 X 越大（或越小）条件越容易成立 → 二分答案。

**Q2：`r = max(piles)` 而不是 `sum(piles)`？**
A：速度 ≥ max 时每堆 1 小时吃完，共 piles.length 小时；由约束 `h ≥ piles.length`，max 是足够大的上界，比 sum 更紧。

**Q3：`(p + k - 1) / k` 为什么是上取整？**
A：整数除法是下取整。`p / k` 下取整后再加 1 等价于 `(p + k - 1) / k` 上取整。当 `p` 是 `k` 的倍数时两者相等。

**Q4：返回 `l` 还是 `r`？**
A：循环退出时 `l == r`，返回哪个都行。习惯写 `l`。

**Q5：早停 `if (hours > h) return false;` 必要吗？**
A：不必要但快。最坏情况下省略 50% 时间。

### 面试官常见 follow-up
1. **"在 D 天内运送货物的最低运力（[LC 1011](https://leetcode.cn/problems/capacity-to-ship-packages-within-d-days/)）？"** → 答案二分，check 算需要几天。
2. **"分割数组的最大值（[LC 410](https://leetcode.cn/problems/split-array-largest-sum/)）？"** → 答案二分，check 算分成几段。
3. **"制作 m 束花需要的最少天数（[LC 1482](https://leetcode.cn/problems/minimum-number-of-days-to-make-m-bouquets/)）？"** → 答案二分天数。
4. **"包裹运输容量？"** → 同类，本质都是"最小满足 X"。
5. **"为什么 check 是 O(n)？还能更快吗？"** → 累加 n 个 ceil，难再快。除非 piles 排序后用更巧的方法。
6. **"如果 h < piles.length 怎么办？"** → 题目保证 h ≥ piles.length；否则无解。

### 同类型推荐（**答案二分家族**）
- [LC 1011. 在 D 天内送达包裹的能力](https://leetcode.cn/problems/capacity-to-ship-packages-within-d-days/)
- [LC 410. 分割数组的最大值](https://leetcode.cn/problems/split-array-largest-sum/)
- [LC 1482. 制作 m 束花所需的最少天数](https://leetcode.cn/problems/minimum-number-of-days-to-make-m-bouquets/)
- [LC 2226. 每个小孩最多能分到多少糖果](https://leetcode.cn/problems/maximum-candies-allocated-to-k-children/)
- [LC 1283. 使结果不超过阈值的最小除数](https://leetcode.cn/problems/find-the-smallest-divisor-given-a-threshold/)
- [LC 2187. 完成旅途的最少时间](https://leetcode.cn/problems/minimum-time-to-complete-trips/)
