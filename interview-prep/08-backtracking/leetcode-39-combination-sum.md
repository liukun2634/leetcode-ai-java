# LeetCode 39. 组合总和 (Combination Sum)

> 难度：Medium　|　标签：数组、回溯　|　**回溯组合家族 ⭐⭐⭐**

---

## 一、题目

给你一个 **无重复元素** 的整数数组 `candidates` 和一个目标整数 `target`，找出 `candidates` 中可以使数字和为目标数 `target` 的所有 **不同组合**，并以列表形式返回。

`candidates` 中的 **同一个数字可以无限制重复被选取**。如果至少一个数字的被选数量不同，则两种组合是不同的。

对于给定的输入，保证和为 `target` 的不同组合数少于 `150` 个。

**约束**

- `1 <= candidates.length <= 30`
- `2 <= candidates[i] <= 40`
- `1 <= target <= 40`

**示例**

| 输入 | 输出 |
|---|---|
| `candidates=[2,3,6,7], target=7` | `[[2,2,3], [7]]` |
| `candidates=[2,3,5], target=8` | `[[2,2,2,2], [2,3,3], [3,5]]` |
| `candidates=[2], target=1` | `[]` |

题目链接：<https://leetcode.cn/problems/combination-sum/>

---

## 二、解题思路（学习重点）

### 1. 与 LC 78（子集）/ LC 77（组合）的区别

| 题 | 元素可重复选？ | 大小固定？ | 和约束？ |
|---|---|---|---|
| LC 78 子集 | ❌ | ❌ | — |
| LC 77 组合 | ❌ | ✅(=k) | — |
| **LC 39** | **✅** | ❌ | **= target** |
| LC 40 组合总和 II | ❌（数组含重复但每元素一次） | ❌ | = target |

### 2. 回溯模板：循环传 `i` 而不是 `i+1`

每个元素可重复选 → 递归传 `i`（仍可选自己），而非 `i+1`。

```text
backtrack(start, remain, path):
    if remain == 0: ans.add(path 拷贝); return
    if remain < 0: return                     // 剪枝：超了
    for i = start..n-1:
        path.add(candidates[i])
        backtrack(i, remain - candidates[i], path)   // 注意是 i 不是 i+1
        path.removeLast()
```

> **学习点 ①**：**"元素可重复选"**：循环传 `i`；**"元素不可重复选"**：循环传 `i+1`；**"数组含重复但每元素只选一次"**：排序 + 同层去重（LC 40）。

### 3. 排序后剪枝（可选优化）

排序 candidates 后，当 `candidates[i] > remain` 时直接 break（剪掉后面更大的）。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 循环传 `i+1` → 每元素只用一次 → 漏 [2,2,3] | 必须传 `i` |
| 循环 `i = 0..n-1` 不传 start → 出现 [2,3,2] 这种重复组合 | 必须 `i = start..n-1` |
| 没剪枝 → TLE | 加 `if (remain < 0) return;` 或排序后 break |
| ans 直接 add path | 必须拷贝 `new ArrayList<>(path)` |

---

## 三、详细解题步骤

**步骤 1**：排序（用于剪枝）
```java
Arrays.sort(candidates);
```

**步骤 2**：回溯
```java
private void backtrack(int[] candidates, int start, int remain,
                       List<Integer> path, List<List<Integer>> ans) {
    if (remain == 0) {
        ans.add(new ArrayList<>(path));
        return;
    }
    for (int i = start; i < candidates.length; i++) {
        if (candidates[i] > remain) break;      // 排序后剪枝
        path.add(candidates[i]);
        backtrack(candidates, i, remain - candidates[i], path, ans);  // 注意 i
        path.remove(path.size() - 1);
    }
}
```

**步骤 3**：调用
```java
public List<List<Integer>> combinationSum(int[] candidates, int target) {
    Arrays.sort(candidates);
    List<List<Integer>> ans = new ArrayList<>();
    backtrack(candidates, 0, target, new ArrayList<>(), ans);
    return ans;
}
```

---

## 四、Java 题解

```java
class Solution {
    public List<List<Integer>> combinationSum(int[] candidates, int target) {
        Arrays.sort(candidates);
        List<List<Integer>> ans = new ArrayList<>();
        backtrack(candidates, 0, target, new ArrayList<>(), ans);
        return ans;
    }
    private void backtrack(int[] c, int start, int remain,
                           List<Integer> path, List<List<Integer>> ans) {
        if (remain == 0) {
            ans.add(new ArrayList<>(path));
            return;
        }
        for (int i = start; i < c.length; i++) {
            if (c[i] > remain) break;
            path.add(c[i]);
            backtrack(c, i, remain - c[i], path, ans);
            path.remove(path.size() - 1);
        }
    }
}
```

**记忆口诀**：
> **"循环传 i 可重选；remain 归 0 收一份；超额 break 剪枝。"**

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | O(S)，S = 所有解的总长度。受题目"≤150 个解"约束 |
| 空间 | O(target) 递归栈 |

---

## 六、示例验证

`candidates=[2,3,6,7], target=7` 的递归树：

```
[] (remain=7)
├ 2 → [2] (5)
│   ├ 2 → [2,2] (3)
│   │   ├ 2 → [2,2,2] (1) → 2 > 1 break
│   │   └ 3 → [2,2,3] (0) ✅
│   ├ 3 → [2,3] (2) → 2 > 2? no, 但 3 > 2 break。wait. 进入 i=2 即 6 > 2 break
│   └ ...
├ 3 → [3] (4)
│   ├ 3 → [3,3] (1) → break
│   └ ...
├ 6 → [6] (1) → break
└ 7 → [7] (0) ✅
```

输出 `[[2,2,3], [7]]` ✅

---

## 七、复盘与延伸

### 一句话总结
> **回溯，循环传 i 让元素可重复选；remain == 0 收解，remain < 0 或排序剪枝。**

### 新手常见疑问（FAQ）

**Q1：为什么循环传 i 而不是 i+1？**
A：传 i 允许下一层再选自己；传 i+1 是"每个元素只选一次"。`[2,2,3]` 这样的解需要重复选 2，必须传 i。

**Q2：为什么不能 `i = 0..n-1`（不传 start）？**
A：会产生 `[2,3,2]` 与 `[2,2,3]` 这种顺序不同的重复组合。`start` 保证组合无序。

**Q3：排序剪枝的好处？**
A：排序后小元素在前；遇到 `c[i] > remain` 时后面更大的也都超了，可以 break。无序时只能 continue。

**Q4：如果有重复元素（LC 40）？**
A：排序后加 `if (i > start && c[i] == c[i-1]) continue;` 跳过同层重复元素，且循环传 `i+1`（每个只用一次）。

**Q5：能用 DP 解吗？**
A：求方案数可以（背包 DP）；求所有方案需要回溯（输出量呈指数级）。

### 面试官常见 follow-up
1. **"每个元素只能选一次（LC 40）？"** → 循环传 `i+1` + 同层去重。
2. **"求方案数（不要具体方案）？"** → 完全背包 DP，`dp[j] += dp[j-c]`。
3. **"组合总和 III（1-9，固定 k 个数）？"** → 多一个 `path.size() == k` 检查。LC 216。
4. **"组合总和 IV：顺序不同算不同（不是组合而是排列）？"** → DP `dp[i] += dp[i-c]`（外层和、内层 c）。LC 377。
5. **"返回最少元素个数的组合？"** → 转 LC 322 零钱兑换，DP。
6. **"target 很大（如 10^9）？"** → 回溯爆炸，需要 DP / 数学。

### 同类型推荐（**回溯组合家族**）
- LC 40. 组合总和 II（含重复，每元素一次）
- LC 216. 组合总和 III（固定 k 个数）
- LC 377. 组合总和 IV（求方案数 / 排列）
- LC 77. 组合（固定 k）
- LC 78. 子集
- LC 90. 子集 II
- LC 322. 零钱兑换（最少件数）
