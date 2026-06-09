# LeetCode 4. 寻找两个正序数组的中位数 (Median of Two Sorted Arrays)

> 难度：Hard　|　标签：数组、二分查找、分治　|　**双数组二分天花板 ⭐⭐⭐⭐⭐**

---

## 一、题目

给定两个大小分别为 `m` 和 `n` 的正序（从小到大）数组 `nums1` 和 `nums2`。请你找出并返回这两个正序数组的 **中位数**。

要求算法时间复杂度应为 `O(log(m+n))`。

**约束**

- `0 <= m, n <= 1000`，`1 <= m + n <= 2000`

**示例**

| 输入 | 输出 |
|---|---|
| `nums1=[1,3], nums2=[2]` | `2.0` |
| `nums1=[1,2], nums2=[3,4]` | `2.5` |

题目链接：<https://leetcode.cn/problems/median-of-two-sorted-arrays/>

---

## 二、解题思路（学习重点）

### 1. 关键洞察：找"分割线"

中位数 = 把所有数排序后，正中间那个/两个的位置。等价为：

**在 `nums1` 和 `nums2` 各画一条分割线，左边总共 `(m+n+1)/2` 个数**，使得：
- `nums1.left ≤ nums2.right`
- `nums2.left ≤ nums1.right`

满足这条件时：
- 总长偶数：中位数 = `(max(nums1.left, nums2.left) + min(nums1.right, nums2.right)) / 2.0`
- 总长奇数：中位数 = `max(nums1.left, nums2.left)`

> **学习点 ①**：本题的"分割"思想是 **双数组二分** 的核心。在短数组上二分分割位置 i，长数组的分割位置 j 由 `j = (m+n+1)/2 - i` 自动确定。**只需在短数组上二分，O(log min(m, n))**。

### 2. 二分细节

设 nums1 短（m ≤ n），在 nums1 上二分 `i ∈ [0, m]`：
- `j = (m + n + 1) / 2 - i`（自动满足"左边 (m+n+1)/2 个"）
- 取四个值：`L1 = nums1[i-1]` (或 -∞), `R1 = nums1[i]` (或 +∞), `L2 = nums2[j-1]`, `R2 = nums2[j]`
- 若 `L1 > R2` → i 太大，`r = i - 1`
- 若 `L2 > R1` → i 太小，`l = i + 1`
- 否则找到分割线，按奇偶返回结果

### 3. 边界用 ±∞ 兜底

- `i == 0`：nums1 全在右边 → `L1 = Integer.MIN_VALUE`
- `i == m`：nums1 全在左边 → `R1 = Integer.MAX_VALUE`
- 同理 nums2 的 j

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 没保证 nums1 短 → j 可能为负 | 必须 `m ≤ n`，否则交换 |
| 边界 i=0 或 i=m 没处理 | 用 ±∞ |
| 计算 `(m+n+1)/2` 写成 `(m+n)/2` | 偶数时分割不对 |

---

## 三、详细解题步骤

**步骤 1**：保证 nums1 是短的
```java
if (nums1.length > nums2.length) return findMedianSortedArrays(nums2, nums1);
int m = nums1.length, n = nums2.length;
int half = (m + n + 1) / 2;
```

**步骤 2**：在 nums1 上二分 i ∈ [0, m]
```java
int l = 0, r = m;
while (l <= r) {
    int i = (l + r) >>> 1;
    int j = half - i;
    int L1 = (i == 0) ? Integer.MIN_VALUE : nums1[i-1];
    int R1 = (i == m) ? Integer.MAX_VALUE : nums1[i];
    int L2 = (j == 0) ? Integer.MIN_VALUE : nums2[j-1];
    int R2 = (j == n) ? Integer.MAX_VALUE : nums2[j];

    if (L1 > R2) r = i - 1;
    else if (L2 > R1) l = i + 1;
    else {
        // 找到分割点
        int leftMax  = Math.max(L1, L2);
        if ((m + n) % 2 == 1) return leftMax;
        int rightMin = Math.min(R1, R2);
        return (leftMax + rightMin) / 2.0;
    }
}
return 0.0;   // unreachable
```

---

## 四、Java 题解

```java
class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        if (nums1.length > nums2.length) return findMedianSortedArrays(nums2, nums1);
        int m = nums1.length, n = nums2.length;
        int half = (m + n + 1) / 2;

        int l = 0, r = m;
        while (l <= r) {
            int i = (l + r) >>> 1;
            int j = half - i;
            int L1 = (i == 0) ? Integer.MIN_VALUE : nums1[i - 1];
            int R1 = (i == m) ? Integer.MAX_VALUE : nums1[i];
            int L2 = (j == 0) ? Integer.MIN_VALUE : nums2[j - 1];
            int R2 = (j == n) ? Integer.MAX_VALUE : nums2[j];

            if (L1 > R2)      r = i - 1;
            else if (L2 > R1) l = i + 1;
            else {
                int leftMax = Math.max(L1, L2);
                if ((m + n) % 2 == 1) return leftMax;
                int rightMin = Math.min(R1, R2);
                return (leftMax + rightMin) / 2.0;
            }
        }
        return 0.0;
    }
}
```

**记忆口诀**：
> **"短数组上二分 i，长数组 j 自动定；交叉满足即分割。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(log min(m, n))** |
| 空间 | O(1) |

---

## 六、示例验证

`nums1=[1,3], nums2=[2]`，m=1（短）n=2，half=(1+2+1)/2=2

| 轮 | i | j | L1 | R1 | L2 | R2 | 判断 |
|---|---|---|---|---|---|---|---|
| init | l=0, r=1 | — | — | — | — | — | — |
| 1 | 0 | 2 | -∞ | 1 | 2 | +∞ | L2(2) > R1(1) → l=1 |

wait, 这里 nums1=[1,3] m=1 不对。重新看：交换后 nums1 是 [2] (短), nums2 是 [1,3]。

`nums1=[2], nums2=[1,3]`，m=1, n=2, half=2

| 轮 | i | j | L1 | R1 | L2 | R2 | 判断 |
|---|---|---|---|---|---|---|---|
| 1 | 0 | 2 | -∞ | 2 | 3 | +∞ | L2(3) > R1(2) → l=1 |
| 2 | 1 | 1 | 2 | +∞ | 1 | 3 | 满足，leftMax=2, rightMin=3, 奇数 → return 2.0 ✅ |

---

## 七、复盘与延伸

### 一句话总结
> **在短数组上二分分割位置；长数组分割位置由总数推出；满足交叉不等即解。**

### 新手常见疑问（FAQ）

**Q1：为什么不直接合并两个数组排序？**
A：O(m+n) 时间，达不到 O(log(m+n)) 要求。本题要求二分。

**Q2：为什么 `half = (m+n+1)/2`？**
A：奇数总长 5：half=3，左 3 右 2，中位数在左；偶数总长 4：half=2，左右各 2，中位数 = (左 max + 右 min)/2。+1 保证奇数时中位数在左半，统一处理。

**Q3：为何只在短数组二分？**
A：保证 `j = half - i` 在 `[0, n]` 内不越界。如果在长数组二分，j 可能为负。

**Q4：±∞ 怎么处理 int 溢出？**
A：用 `Integer.MIN/MAX_VALUE`。`leftMax + rightMin` 中一个是 MIN_VALUE 时需要小心；但本题不出现（一个是 MIN 说明对面分割左边没数，rightMin 是有效值）。

**Q5：能否用堆？**
A：能但 O((m+n) log k)；不达标。

### 面试官常见 follow-up
1. **"k 个有序数组的中位数？"** → 多个堆 + 二分答案。
2. **"两个数组的第 k 小？"** → 类似本题，每次排除 k/2 个元素。
3. **"流式中位数（LC 295）？"** → 双堆，与本题完全不同的思路。
4. **"无法访问数组的元素（只能查询）？"** → 二分仍可行。
5. **"内存不够，两个数组分别在磁盘？"** → 二分访问的元素数 O(log(m+n))，磁盘 IO 极少。
6. **"如果数组很短（m+n ≤ 100）？"** → 直接合并排序更简单；只在大数据下二分才有意义。

### 同类型推荐（**双数组二分 / 中位数家族**）
- LC 295. 数据流的中位数（双堆）
- LC 480. 滑动窗口中位数
- LC 215. 数组中第 K 大元素（单数组）
- LC 378. 有序矩阵中第 K 小（二维）
- LC 668. 乘法表中第 k 小的数（答案二分）
- LC 786. 第 k 个最小的素数分数
