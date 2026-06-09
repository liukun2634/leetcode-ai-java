# LeetCode 46. 全排列 (Permutations)

> 难度：Medium　|　标签：回溯、数组　|　**回溯模板天花板 ⭐⭐⭐**

---

## 一、题目

给定一个 **不含重复数字** 的数组 `nums`，返回其 **所有可能的全排列**。你可以 **按任意顺序** 返回答案。

**约束**

- `1 <= nums.length <= 6`
- 元素互不相同

**示例**

| 输入 | 输出 |
|---|---|
| `[1,2,3]` | `[[1,2,3],[1,3,2],[2,1,3],[2,3,1],[3,1,2],[3,2,1]]` |
| `[0,1]` | `[[0,1],[1,0]]` |

题目链接：<https://leetcode.cn/problems/permutations/>

---

## 二、解题思路（学习重点）

### 1. 回溯三件套：**路径、选择列表、撤销**

通用模板：
```text
backtrack(path):
    if path 完成:
        把 path 复制进结果集
        return
    for 每个可选元素 c:
        在 path 末尾加上 c       // 做选择
        backtrack(path)         // 递归
        移除 path 末尾的 c       // 撤销选择（回溯）
```

> **学习点 ①**：**"撤销"是回溯的灵魂**。它让我们能用 **同一个 path 对象** 复用内存，避免每层 new 一个新列表。

### 2. 如何表达"可选元素"？

本题用 `boolean[] used` 标记每个下标是否已被选：
- 进入循环 `for (int i = 0; i < n; i++)`：若 `used[i]` 跳过；否则选它。
- 进入下层前置 `used[i] = true`、加入 `path`；
- 返回后撤销 `used[i] = false`、移除 `path` 末尾元素。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 把 `path` 直接 `ans.add(path)` → 后续修改污染答案 | **必须** `ans.add(new ArrayList<>(path))` 拷贝一份 |
| 忘记撤销 `used[i]` 或 `path` 末尾 | 直接错；写完 `for` 内的递归后立即写 |
| 用 `Set<Integer>` 代替 `used` 数组 | 也对，但常数大 |

### 4. 含重复元素怎么办（LC 47）

排序后加 **去重剪枝**：`if (i > 0 && nums[i] == nums[i-1] && !used[i-1]) continue;`

---

## 三、Java 题解（推荐）

```java
class Solution {
    public List<List<Integer>> permute(int[] nums) {
        List<List<Integer>> ans = new ArrayList<>();
        boolean[] used = new boolean[nums.length];
        backtrack(nums, new ArrayList<>(), used, ans);
        return ans;
    }
    private void backtrack(int[] nums, List<Integer> path, boolean[] used, List<List<Integer>> ans) {
        if (path.size() == nums.length) {
            ans.add(new ArrayList<>(path));   // 必须拷贝
            return;
        }
        for (int i = 0; i < nums.length; i++) {
            if (used[i]) continue;
            used[i] = true;
            path.add(nums[i]);
            backtrack(nums, path, used, ans);
            path.remove(path.size() - 1);     // 撤销
            used[i] = false;
        }
    }
}
```

**记忆口诀**：
> **"选 → 递归 → 撤销，路径满了拷一份。"**

---

## 四、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n · n!)** （n! 种排列，每种 O(n) 拷贝） |
| 空间 | O(n) 递归栈 + O(n) used + O(n · n!) 输出 |

---

## 五、示例验证

`nums = [1,2,3]` 的递归树（每层选未用过的数）：

```
[]
├ 1: [1]
│   ├ 2: [1,2]
│   │   └ 3: [1,2,3] ✅
│   └ 3: [1,3]
│       └ 2: [1,3,2] ✅
├ 2: [2]
│   ├ 1: [2,1]
│   │   └ 3: [2,1,3] ✅
│   └ 3: [2,3]
│       └ 1: [2,3,1] ✅
└ 3: [3]
    ├ 1: [3,1]
    │   └ 2: [3,1,2] ✅
    └ 2: [3,2]
        └ 1: [3,2,1] ✅
```

6 个排列 ✅

---

## 六、复盘与延伸

### 一句话总结
> **回溯 = 路径 + 可选集合 + 撤销操作；递归出口处拷贝路径。**

### 新手常见疑问（FAQ）

**Q1：为什么必须拷贝 `path`？**
A：同一个 `path` 对象贯穿全程。不拷贝会导致 `ans` 里装的都是同一个引用，最后都是空列表（所有元素被撤销了）。

**Q2：为什么时间复杂度是 O(n·n!) 而不是 O(n!)？**
A：n! 是叶子数量（所有排列），每个节点拷贝 path 需 O(n)，所以是 O(n·n!)。内部递归调用本身总数也是 O(n!)。

**Q3：能不能不用 `used` 数组，原地交换？**
A：能：起头与 i 交换后递归、返回后换回。代码更短但不直观，且不容易推广到 LC 47 含重复。面试选 used 版。

**Q4：含重复元素（LC 47）怎么去重？**
A：排序后加 `if (i > 0 && nums[i] == nums[i-1] && !used[i-1]) continue;`。关键点：`!used[i-1]` 表示“同位置跳过」而非“同路径跳过”。

**Q5：为什么要紧跟「选 → 递归 → 撤销」三步，不能其中一步拆开？**
A：三步是一个原子操作。拆开后后面的 for 循环会看到不一致的 path/used 状态。「取 → 走 → 还」是回溯的肉身。

### 面试官常见 follow-up
1. **"含重复元素的全排列（LC 47）？"** → 排序 + `!used[i-1]` 去重剪枝。
2. **"第 k 个排列（LC 60）？"** → 不用回溯，用康托展开按位计算 (k-1)/(n-1)! 选首元素，O(n²)。
3. **"下一个排列（LC 31）？"** → 从右找首个下降位 i，从右找首个 > nums[i] 的 j，交换后反转 i+1..end。O(n) 原地。
4. **"排列中某位置限定为某值？"** → 回溯中加剪枝：`if (depth == k && nums[i] != target) continue;`。
5. **"允许每个元素可选多次（重复排列）？"** → 去掉 `used`，每层 `for i = 0..n-1`。总量 n^n，限 n 很小。
6. **"多个集合取笛卡尔积（如手机字母 LC 17）？"** → 回溯根据当前层选不同集合，状态是 depth 而非 used。

### 同类型推荐（**回溯家族**）
**排列类**：
- LC 47. 全排列 II（含重复）
- LC 31. 下一个排列（非回溯）

**子集类**：
- LC 78. 子集
- LC 90. 子集 II（含重复）

**组合类**：
- LC 77. 组合
- LC 39. 组合总和（可重复选）
- LC 40. 组合总和 II（每元素最多一次 + 去重）
- LC 216. 组合总和 III

**字符串/格子**：
- LC 22. 括号生成
- LC 17. 电话号码字母组合
- LC 79. 单词搜索
- LC 131. 分割回文串
- LC 51. N 皇后
- LC 37. 解数独

> **回溯题刷过 10 题以上，框架基本通用**。重点是熟练 **剪枝**。
