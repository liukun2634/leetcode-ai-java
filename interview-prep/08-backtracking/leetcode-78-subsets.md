# LeetCode 78. 子集 (Subsets)

> 难度：Medium　|　标签：回溯、位运算　|	|	**子集回溯模板 ⭐⭐⭐**

---

## 一、题目

给你一个整数数组 `nums`，数组中的元素 **互不相同**。返回该数组所有可能的 **子集**（幂集）。

解集 **不能** 包含重复的子集。你可以按 **任意顺序** 返回解集。

**约束**

- `1 <= nums.length <= 10`
- 元素互不相同

**示例**

| 输入 | 输出 |
|---|---|
| `[1,2,3]` | `[[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]` |
| `[0]` | `[[],[0]]` |

题目链接：<https://leetcode.cn/problems/subsets/>

---

## 二、解题思路（学习重点）

### 1. 子集 vs 排列 vs 组合

| 类型 | 关心顺序？ | 大小固定？ | 例子 |
|---|---|---|---|
| 排列 | ✅ | ✅（全部） | LC 46 |
| **子集** | ❌ | ❌（任何大小） | **LC 78** |
| 组合 | ❌ | ✅（固定 k） | LC 77 |

> **学习点 ①**：子集要 **避免选过的再选**（避免 `[1,2]` 和 `[2,1]` 重复），所以回溯模板的循环必须 **从 `start` 开始**（不是 0）。

### 2. 通用回溯模板（"选 vs 不选" 的视角更短）

**视角 A：枚举起点（推荐）**

```text
backtrack(start, path):
    ans.add(copy(path))         // 每个 path（任意大小）都是合法子集
    for i = start..n-1:
        path.add(nums[i])
        backtrack(i + 1, path)
        path.removeLast()
```

`start` 保证不会回头选已经选过的数。

**视角 B：每个元素选或不选**

```text
dfs(idx, path):
    if idx == n:
        ans.add(copy(path)); return
    // 选
    path.add(nums[idx])
    dfs(idx + 1, path)
    path.removeLast()
    // 不选
    dfs(idx + 1, path)
```

> 视角 A 更通用（直接套到组合 LC 77）；视角 B 更接近"二进制位"思维。

### 3. 位运算解法（O(n · 2^n)，最短代码）

子集总数 `2^n`；用 `mask = 0..2^n-1`，第 `i` 位为 1 表示选 `nums[i]`。

### 4. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 内层 `for i = 0..n-1` 不带 start | 会产生 `[1,2]` 和 `[2,1]` 重复 |
| 把 `path` 直接 add | 后续修改会污染答案，必须拷贝 |
| 含重复元素（LC 90）→ 排序 + 跳重 | 见下方"同类型推荐" |

---

## 三、详细解题步骤（视角 A）

**步骤 1**：初始化
```java
List<List<Integer>> ans = new ArrayList<>();
List<Integer> path = new ArrayList<>();
```

**步骤 2**：定义递归
```java
private void backtrack(int[] nums, int start, List<Integer> path, List<List<Integer>> ans) {
    ans.add(new ArrayList<>(path));     // 每次进来都收集（含空集）
    for (int i = start; i < nums.length; i++) {
        path.add(nums[i]);
        backtrack(nums, i + 1, path, ans);
        path.remove(path.size() - 1);
    }
}
```

**步骤 3**：主函数调用 `backtrack(nums, 0, path, ans);`

---

## 四、Java 题解

### 解法 A：回溯（推荐）

```java
class Solution {
    public List<List<Integer>> subsets(int[] nums) {
        List<List<Integer>> ans = new ArrayList<>();
        backtrack(nums, 0, new ArrayList<>(), ans);
        return ans;
    }
    private void backtrack(int[] nums, int start, List<Integer> path, List<List<Integer>> ans) {
        ans.add(new ArrayList<>(path));
        for (int i = start; i < nums.length; i++) {
            path.add(nums[i]);
            backtrack(nums, i + 1, path, ans);
            path.remove(path.size() - 1);
        }
    }
}
```

**记忆口诀**：
> **"每进函数收一份，循环从 start 防回头。"**

### 解法 B：位运算

```java
class Solution {
    public List<List<Integer>> subsets(int[] nums) {
        int n = nums.length;
        List<List<Integer>> ans = new ArrayList<>();
        for (int mask = 0; mask < (1 << n); mask++) {
            List<Integer> sub = new ArrayList<>();
            for (int i = 0; i < n; i++) {
                if ((mask & (1 << i)) != 0) sub.add(nums[i]);
            }
            ans.add(sub);
        }
        return ans;
    }
}
```

### 解法 C：迭代构造

每次把 nums[i] 追加到已有所有子集后面，得到新子集。

```java
class Solution {
    public List<List<Integer>> subsets(int[] nums) {
        List<List<Integer>> ans = new ArrayList<>();
        ans.add(new ArrayList<>());
        for (int x : nums) {
            int size = ans.size();
            for (int i = 0; i < size; i++) {
                List<Integer> newSub = new ArrayList<>(ans.get(i));
                newSub.add(x);
                ans.add(newSub);
            }
        }
        return ans;
    }
}
```

---

## 五、复杂度

| 项 | 复杂度 |
|---|---|
| 时间 | **O(n · 2^n)** |
| 空间 | O(n) 递归栈 + 输出 |

---

## 六、示例验证

`nums = [1,2,3]` 的递归树：

```
[]                                      ← 收
 ├ 1 → [1]                              ← 收
 │   ├ 2 → [1,2]                        ← 收
 │   │   └ 3 → [1,2,3]                  ← 收
 │   └ 3 → [1,3]                        ← 收
 ├ 2 → [2]                              ← 收
 │   └ 3 → [2,3]                        ← 收
 └ 3 → [3]                              ← 收
```

8 个子集 ✅

---

## 七、复盘与延伸

### 一句话总结
> **子集回溯：每进函数 `ans.add(path 拷贝)`；循环 `i = start..n-1`，递归传 `i+1`。**

### 新手常见疑问（FAQ）

**Q1：为什么循环从 `start` 而不是 `0`？**
A：防止重复选择产生重复子集（如 `[1,2]` 和 `[2,1]`）。子集需要集合语义，不关心选择顺序，仅需“向后选”保证唯一性。

**Q2：为什么递归出口不是 `idx == n`？**
A：子集允许任意大小（含空集与全集），每个 `path` 都是合法子集。在函数入口收集就不会遭漏。

**Q3：含重复元素（LC 90）怎么去重？**
A：排序后加 `if (i > start && nums[i] == nums[i-1]) continue;`。注意是 `i > start` 而非 `i > 0`，以避免跳过同一层重复但需要代入不同路径的情形。

**Q4：位运算版与回溯版哪个面试优先？**
A：回溯是主解（能推广到 LC 90 含重复、LC 77 固定大小等变体）。位运算可作为亮点提及，但依赖 n ≤ 32。

**Q5：如果 n 超过 30、5、30？**
A：子集总数 2^n，n>30 会超出 int，但题目一般限 n ≤ 20 以保证可枚举。若 n 很大但只要“某些子集”，需重新制定问题。

### 面试官常见 follow-up
1. **"含重复元素的子集（LC 90）？"** → 排序 + `i > start && nums[i]==nums[i-1]` 跳重。
2. **"固定大小 k 的组合（LC 77）？"** → `path.size() == k` 才收集；可加剪枝 `i ≤ n - (k - path.size()) + 1`。
3. **"递增子序列（LC 491）？"** → 只选后位 ≥ path.last 的元素，同层用 Set 去重。
4. **"求第 k 个子集？"** → 把 k 当作位掩码，按位压入元素。
5. **"每个元素可选多次（多重集子集）？"** → 递归改为 `backtrack(i, ...)` 不是 `i+1`；需限制 path 总长避免无限。
6. **"子集和为 target（LC 39/40）？"** → 加剪枝 `sum > target` 提前返回；LC 40 需去重。

### 同类型推荐（**回溯三大金刚**）
**子集**：
- LC 78（本题）/ LC 90（含重复）/ LC 491（递增子序列）

**组合**：
- LC 77. 组合 / LC 39. 组合总和 / LC 40. 组合总和 II / LC 216. 组合总和 III

**排列**：
- LC 46. 全排列 / LC 47. 全排列 II / LC 60. 排列序列

**字符串/网格**：
- LC 17. 电话号码字母组合
- LC 22. 括号生成
- LC 131. 分割回文串
- LC 79. 单词搜索
