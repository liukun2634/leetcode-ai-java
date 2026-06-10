# LeetCode 41. 缺失的第一个正数 (First Missing Positive)

> 难度：Hard　|　标签：数组、原地哈希　|　**原地哈希天花板 ⭐⭐⭐⭐**

---

## 一、题目

给你一个未排序的整数数组 `nums`，请你找出其中没有出现的 **最小的正整数**。

请你实现 **时间复杂度为 O(n)** 并且只使用 **常数级别额外空间** 的算法。

**约束**

- `1 <= nums.length <= 10^5`
- `-2^31 <= nums[i] <= 2^31 - 1`

**示例**

| 输入 | 输出 |
|---|---|
| `[1,2,0]` | `3` |
| `[3,4,-1,1]` | `2` |
| `[7,8,9,11,12]` | `1` |

题目链接：<https://leetcode.cn/problems/first-missing-positive/>

---

## 二、解题思路（学习重点）

### 1. 关键观察：答案必在 `[1, n+1]` 范围内

设数组长度 `n`：
- 最理想情况，数组恰好装着 `1, 2, ..., n`，答案是 `n+1`
- 否则答案一定是 `[1, n]` 里某个缺失的数

所以**只需关注 `[1, n]` 的数字**，其他（≤0、>n、重复）都可丢弃。

### 2. 原地哈希：让 `nums[i] = i+1`（值 v 放在下标 v-1）

把数组本身当哈希表用：
- 把值 `v ∈ [1, n]` 的元素，**交换到下标 `v-1` 的位置**
- 这样数组里每个值各归其位

最后再扫一遍：**第一个 `nums[i] != i+1` 的位置 i**，答案就是 `i+1`；全部归位则答案是 `n+1`。

> **学习点 ①**：当题目要求 **O(1) 空间** 且元素是"小范围整数"时，第一反应应该是 **原地哈希**（用下标当 key）。同模板：LC 442（找重复数）、LC 448（找消失的数）、LC 287（找重复数，Floyd 也行）。

### 3. 交换的细节：用 `while` 而非 `if`

每个位置 i 处理时，把 `nums[i]` 换到它该去的位置 `nums[i]-1`：
```java
while (nums[i] >= 1 && nums[i] <= n && nums[nums[i] - 1] != nums[i]) {
    swap(nums, i, nums[i] - 1);
}
```

**关键条件**：
- `nums[i] ∈ [1, n]` 才有意义（其他值直接跳过）
- `nums[nums[i] - 1] != nums[i]` 防止重复值死循环（如 `[1, 1]`）

**为什么用 while 不是 if**：交换后 `nums[i]` 变成新的值，可能又需要交换。只有当 `nums[i]` 不在 `[1,n]` 或目标位置已经是它时才停。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 用 if 而非 while → 一次交换不够 | 必须 `while` 让 `nums[i]` 反复归位 |
| 重复值 `[1,1]` → 死循环 | 加 `nums[nums[i]-1] != nums[i]` 判断 |
| 越界：`nums[i] <= 0` 或 `> n` | 必须跳过 |
| 误以为最后位置应是 `nums[i] = i` | 是 `i + 1`（值从 1 开始，下标从 0 开始） |

---

## 三、详细解题步骤

**步骤 1**：遍历每个位置 i = 0..n-1，把 `nums[i]` 归位
```java
for (int i = 0; i < n; i++) {
    while (nums[i] >= 1 && nums[i] <= n && nums[nums[i] - 1] != nums[i]) {
        int j = nums[i] - 1;
        int tmp = nums[i];
        nums[i] = nums[j];
        nums[j] = tmp;
    }
}
```

**步骤 2**：再扫一遍，找第一个 `nums[i] != i+1` 的位置
```java
for (int i = 0; i < n; i++) {
    if (nums[i] != i + 1) return i + 1;
}
```

**步骤 3**：全部归位 → 答案 `n+1`
```java
return n + 1;
```

---

## 四、Java 题解

```java
class Solution {
    public int firstMissingPositive(int[] nums) {
        int n = nums.length;
        for (int i = 0; i < n; i++) {
            while (nums[i] >= 1 && nums[i] <= n && nums[nums[i] - 1] != nums[i]) {
                int j = nums[i] - 1;
                int tmp = nums[i];
                nums[i] = nums[j];
                nums[j] = tmp;
            }
        }
        for (int i = 0; i < n; i++) {
            if (nums[i] != i + 1) return i + 1;
        }
        return n + 1;
    }
}
```

**记忆口诀**：
> **"值 v 放下标 v-1；while 归位防重复；扫一遍找第一个错位。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n)** —— 每个位置最多被交换 1 次（每次交换都让一个值归位） |
| 空间 | **O(1)** |

---

## 六、示例验证

`nums = [3, 4, -1, 1]`（n=4）

**归位阶段**：

| i | nums (开始) | 操作 | nums (结束) |
|---|---|---|---|
| 0 | [3,4,-1,1] | 3→下标2: swap(0,2) → [-1,4,3,1]；-1 跳过 | [-1,4,3,1] |
| 1 | [-1,4,3,1] | 4→下标3: swap(1,3) → [-1,1,3,4]；1→下标0: swap(1,0) → [1,-1,3,4]；-1 跳过 | [1,-1,3,4] |
| 2 | [1,-1,3,4] | 3 已在下标 2，停 | [1,-1,3,4] |
| 3 | [1,-1,3,4] | 4 已在下标 3，停 | [1,-1,3,4] |

**扫描阶段**：
- i=0: nums[0]=1 ✅
- i=1: nums[1]=-1 ≠ 2 → **返回 2** ✅

---

## 七、复盘与延伸

### 一句话总结
> **答案必在 [1, n+1] 内；用原地哈希把值 v 放到下标 v-1，扫一遍找第一个错位。**

### 新手常见疑问（FAQ）

**Q1：为什么答案必在 `[1, n+1]`？**
A：n 个位置最多装 n 个不同正数，最优情况是装满 `1..n`，此时答案 n+1；否则中间必有缺失，答案 ≤ n。

**Q2：为什么用 while 而不是 if 做交换？**
A：交换后 `nums[i]` 变成新值，新值可能也需要归位。比如 `[3,4,1,2]`，i=0 处先 swap 3→下标2 得 `[1,4,3,2]`，此时 nums[0]=1 还需要继续归位。

**Q3：为什么要判 `nums[nums[i]-1] != nums[i]`？**
A：防止重复值死循环。如 `[1,1]`，i=0 时 nums[0]=1，目标下标 0 已是 1，不再交换；否则会一直 swap(0,0)。

**Q4：负数、0、超大值会捣乱吗？**
A：不会。`nums[i] >= 1 && nums[i] <= n` 把它们过滤掉，跳到下一个 i。

**Q5：能否用 HashSet 代替？**
A：能，但空间 O(n)，不满足题目要求。HashSet 版本：把所有正数入 set，从 1 开始找第一个不在 set 的。

### 面试官常见 follow-up
1. **"如果允许 O(n) 额外空间呢？"** → HashSet 或开 `boolean[n+1]` 标记。代码更短，但空间不达标。
2. **"求所有缺失的正数（[LC 448](https://leetcode.cn/problems/find-all-numbers-disappeared-in-an-array/)）？"** → 同模板归位后，所有 `nums[i] != i+1` 的位置 i+1 都缺失。
3. **"求重复的数字（[LC 442](https://leetcode.cn/problems/find-all-duplicates-in-an-array/)）？"** → 归位时 swap 失败的值就是重复的；或用 Floyd 判圈（[LC 287](https://leetcode.cn/problems/find-the-duplicate-number/)）。
4. **"如果数组很大无法装入内存？"** → 外部排序后扫描；或位图（n/8 字节）。
5. **"如果允许修改但要求保持原数组顺序？"** → 无法原地，需 O(n) 额外空间。
6. **"如果输入是流式（来一个数处理一个）？"** → 没法原地哈希；需要维护"已见过的正数集合"。

### 同类型推荐（**原地哈希家族**）
- [LC 287. 寻找重复数](https://leetcode.cn/problems/find-the-duplicate-number/)（Floyd 判圈）
- [LC 442. 数组中重复的数据](https://leetcode.cn/problems/find-all-duplicates-in-an-array/)
- [LC 448. 找到所有数组中消失的数字](https://leetcode.cn/problems/find-all-numbers-disappeared-in-an-array/)
- [LC 268. 丢失的数字](https://leetcode.cn/problems/missing-number/)（位运算 / 数学）
- [LC 645. 错误的集合](https://leetcode.cn/problems/set-mismatch/)
- [LC 128. 最长连续序列](https://leetcode.cn/problems/longest-consecutive/)（哈希起点）
