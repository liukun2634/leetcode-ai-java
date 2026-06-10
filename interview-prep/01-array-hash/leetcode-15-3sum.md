# LeetCode 15. 三数之和 (3Sum)

> 难度：Medium　|　标签：数组、排序、双指针　|　**面试高频 ⭐⭐⭐**

---

## 一、题目

给你一个整数数组 `nums`，判断是否存在三元组 `[nums[i], nums[j], nums[k]]` 满足 `i != j`、`i != k`、`j != k`，同时 `nums[i] + nums[j] + nums[k] == 0`。返回所有和为 `0` 且 **不重复** 的三元组。

**约束**

- `3 <= nums.length <= 3000`
- `-10^5 <= nums[i] <= 10^5`

**示例**

| 输入 | 输出 |
|---|---|
| `[-1,0,1,2,-1,-4]` | `[[-1,-1,2],[-1,0,1]]` |
| `[0,1,1]` | `[]` |
| `[0,0,0]` | `[[0,0,0]]` |

题目链接：<https://leetcode.cn/problems/3sum/>

---

## 二、解题思路（学习重点）

### 1. 从 Two Sum 推广

固定一个数 `nums[i]`，剩下的问题转化为 **在 `nums[i+1..n-1]` 找两个数和为 `-nums[i]`**。如果直接用哈希，去重相当难写。

**经典做法**：**先排序**，再用 **双指针** 在右侧夹逼。

**为什么排序是关键转折**：
- 排序后 **相同数字相邻**，去重只需要看相邻是否相等；
- 排序后子数组有序，**双指针** 才有意义（和大了 `r--`、和小了 `l++` 单调地逼近），把内层 O(n²) 砍到 O(n)。
- 「无序数组 + 哈希」也能 AC，但去重要用 `Set<List<Integer>>` 兜底，常数大且代码丑。

### 2. 双指针 + 去重的三大要点

> 这三点漏掉任何一个都过不了，**面试必背**。

| 要点 | 写法 |
|---|---|
| ① 排序 | `Arrays.sort(nums)` —— 让相同数字相邻，便于去重和单调收缩 |
| ② 固定首元素 + 双指针夹逼 | `l = i+1, r = n-1`；和 < 0 → `l++`；和 > 0 → `r--`；和 == 0 → 记录 |
| ③ 三层去重 | a) **i 去重**：若 `nums[i] == nums[i-1]` 跳过<br>b) **l 去重**：命中后 `while(l<r && nums[l]==nums[l+1]) l++`<br>c) **r 去重**：命中后 `while(l<r && nums[r]==nums[r-1]) r--` |

### 3. 剪枝小技巧

- 若 `nums[i] > 0`：之后所有数都 ≥ `nums[i] > 0`，三数和必 > 0，**直接 break**。
- 第一个数 `nums[0] > 0` 或最后一个 `nums[n-1] < 0` → 不可能有解。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 哈希集合 + 强制 `Set<List<Integer>>` 去重 → AC 但慢 | 排序 + 三层去重是正解 |
| 去重写成 `nums[i] == nums[i+1]` 会漏掉 `[0,0,0]` | 应是 `nums[i] == nums[i-1]` |
| 命中后忘记同时 `l++; r--` | 否则死循环 |

---

## 三、Java 题解（推荐）

```java
class Solution {
    public List<List<Integer>> threeSum(int[] nums) {
        Arrays.sort(nums);
        List<List<Integer>> ans = new ArrayList<>();
        int n = nums.length;

        for (int i = 0; i < n - 2; i++) {
            if (nums[i] > 0) break;                          // 剪枝
            if (i > 0 && nums[i] == nums[i - 1]) continue;   // i 去重

            int l = i + 1, r = n - 1, target = -nums[i];
            while (l < r) {
                int sum = nums[l] + nums[r];
                if (sum == target) {
                    ans.add(Arrays.asList(nums[i], nums[l], nums[r]));
                    while (l < r && nums[l] == nums[l + 1]) l++;  // l 去重
                    while (l < r && nums[r] == nums[r - 1]) r--;  // r 去重
                    l++; r--;
                } else if (sum < target) {
                    l++;
                } else {
                    r--;
                }
            }
        }
        return ans;
    }
}
```

**记忆口诀**：
> **"排序、固定一头、双指针夹、三层去重。"**

---

## 四、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n²)** —— 外层 n，内层双指针 O(n) |
| 空间 | O(1)（不算输出与排序的栈） |

> 哈希做法理论也是 O(n²)，但常数大、去重麻烦。

---

## 五、示例验证

`nums = [-1,0,1,2,-1,-4]` 排序后 → `[-4,-1,-1,0,1,2]`

| i | nums[i] | l..r 操作 | 命中 |
|---|---|---|---|
| 0 | -4 | 找 4：(-1+2=1)→l++, (-1+2=1)→l++, (0+2=2)→l++, (1+2=3)→l++ 结束 | — |
| 1 | -1 | 找 1：(-1+2=1) ✅ 记 `[-1,-1,2]`; l=3,r=4 (0+1=1) ✅ 记 `[-1,0,1]`; l=4,r=3 结束 | 2 个 |
| 2 | -1 | `==nums[1]` 跳过 | — |
| 3 | 0 | 找 0：(1+2=3)→r--, (1+1=2) 越界 结束 | — |

输出 `[[-1,-1,2],[-1,0,1]]` ✅

---

## 六、复盘与延伸

### 一句话总结
> **排序后枚举第一个数，把问题降维成有序数组的 Two Sum，再夹逼 + 跳重。**

### 新手常见疑问（FAQ）

**Q1：去重的三个地方分别在去什么？**
A：
- **i 去重**：避免外层固定相同的首元素，导致整组三元组重复（如 `[-1,-1,0,1]` 中 i=0/1 都固定 -1 会输出两遍 `[-1,0,1]`）。
- **l 去重**：命中后跳过左侧相同值，避免 `[-2,1,1,1]` 输出两遍 `[-2,1,1]`。
- **r 去重**：同理跳过右侧相同值。

**Q2：去重为什么写成 `nums[i] == nums[i-1]`？写成 `nums[i] == nums[i+1]` 行不行？**
A：不行。`nums[i] == nums[i+1]` 会让 `[0,0,0]` 在 i=0 就跳过，根本进不了双指针；`nums[i] == nums[i-1]` 保证至少有一个相同值进入循环。

**Q3：命中后 `l++; r--` 漏写一个会怎样？**
A：死循环。双指针都没动，`sum` 不变，永远命中。

**Q4：可以不排序吗？**
A：可以但更难——必须用 `HashSet<List<Integer>>` 去重，O(n²) 时间但常数和空间都更大；面试不推荐。

**Q5：和为目标值 t（不是 0）的 3Sum 怎么改？**
A：把 `target = -nums[i]` 改成 `target = t - nums[i]`，其他完全一样。

### 面试官常见 follow-up
1. **"如果是 3Sum Closest（求最接近 target 的三数和）？"** → 双指针正常移动，但每次比较 `Math.abs(sum - target)` 更新 best。即 [**LC 16**](https://leetcode.cn/problems/3sum-closest/)。
2. **"统计满足 nums[i]+nums[j]+nums[k] < target 的三元组数量？"** → 双指针：若 `sum < target`，说明 `l..r-1` 都满足，一次性 `count += r - l`，再 `l++`。即 [**LC 259**](https://leetcode.cn/problems/3sum-smaller/)。
3. **"扩展到 K Sum 通用模板呢？"** → 递归：`kSum(nums, target, k)`，k > 2 时枚举 i 后递归 `kSum(..., k-1)`，k == 2 时双指针。
4. **"如果数组很大、内存不够，无法整组排序呢？"** → 外部排序（归并）+ 双指针；或 MapReduce 按值分桶。
5. **"4Sum II（四个独立数组取一个数和为 0）有什么 trick？"** → 分组哈希：A+B 的所有和入 map，统计 -(C+D) 的频次，O(n²) 时间。即 [**LC 454**](https://leetcode.cn/problems/4sum-ii/)。
6. **"输出三元组数量太多，能否只输出数量？"** → 算法不变，只是不保存 `ans`，用计数器替代；可省内存。

### 自我提问
1. 排序的代价是 O(n log n)，相比 O(n²) 是否值得？→ 完全值得，且为去重铺路。
2. 为什么内层不用 Two Sum 的哈希？→ 哈希难以同时保持去重和有序性。
3. 如何扩展到 4Sum？→ 多套一层循环（O(n³)），其余结构一致。

### 同类型推荐（这是 **K Sum** 模板的源头）
- [LC 1. Two Sum](https://leetcode.cn/problems/two-sum/)（哈希）
- [LC 167. Two Sum II](https://leetcode.cn/problems/two-sum-ii-input-array-is-sorted/)（有序数组 + 双指针，是 3Sum 的子问题）
- [LC 16. 3Sum Closest](https://leetcode.cn/problems/3sum-closest/)（夹逼时记录最接近 target 的和）
- [LC 18. 4Sum](https://leetcode.cn/problems/4sum/)（多一层循环）
- [LC 259. 3Sum Smaller](https://leetcode.cn/problems/3sum-smaller/)（双指针统计而非记录）
- [LC 454. 4Sum II](https://leetcode.cn/problems/4sum-ii/)（**分组哈希**：四个数组两两组合）
