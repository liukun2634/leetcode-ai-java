# LeetCode 21. 合并两个有序链表 (Merge Two Sorted Lists)

> 难度：Easy　|　标签：链表、递归　|	|	**dummy 头模板必背 ⭐⭐⭐**

---

## 一、题目

将两个升序链表合并为一个新的 **升序** 链表并返回。新链表是通过拼接给定的两个链表的所有节点组成的。

**约束**

- 两个链表的节点数目范围是 `[0, 50]`

**示例**

```
输入：list1 = 1 → 2 → 4
      list2 = 1 → 3 → 4
输出：1 → 1 → 2 → 3 → 4 → 4
```

---

## 二、解题思路（学习重点）

### 1. dummy 头节点：链表题的"统一边界处理神器"

**核心痛点**：链表合并时第一个新节点要"格外照顾"（要么需要 `if` 判断当前是不是第一个，要么需要单独写代码）。

**dummy 节点**：在结果链表前 **多放一个哨兵节点**，所有插入操作都按"接在某节点后面"统一处理，最后返回 `dummy.next`。

> **学习点 ①**：**任何"构造新链表" / "可能删头节点" 的题，都先 `new ListNode(-1)` 当 dummy**。如：LC 21（合并）、LC 23（k 路合并）、LC 25（k 个一组反转）、LC 86（分割）、LC 203（删除值为 val 的节点）。

### 2. 标准模板

```text
dummy = new ListNode(-1)
tail = dummy
while l1 != null && l2 != null:
    if l1.val <= l2.val:
        tail.next = l1
        l1 = l1.next
    else:
        tail.next = l2
        l2 = l2.next
    tail = tail.next
tail.next = (l1 != null) ? l1 : l2   // 接上剩余
return dummy.next
```

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 忘记 `tail = tail.next` → 死循环 | 模板第 8 行必写 |
| 没接剩余链表 → 漏一截 | while 之后单独一行 |
| 用 `<` 而非 `<=` 影响稳定性？ | 本题不影响，按习惯即可 |

---

## 三、详细解题步骤（迭代法）

**步骤 1**：建 dummy 与 tail 指针
```java
ListNode dummy = new ListNode(-1);
ListNode tail = dummy;
```

**步骤 2**：循环比较两个链表头
```java
while (l1 != null && l2 != null) {
    if (l1.val <= l2.val) {
        tail.next = l1;      // 把 l1 接到尾巴
        l1 = l1.next;        // l1 前移
    } else {
        tail.next = l2;
        l2 = l2.next;
    }
    tail = tail.next;        // 尾巴前移
}
```

**步骤 3**：把还剩的那个链表整条接到尾巴
```java
tail.next = (l1 != null) ? l1 : l2;
```

**步骤 4**：返回 `dummy.next`（跳过 dummy 哨兵）。

---

## 四、Java 题解

### 解法 A：迭代 + dummy（推荐）

```java
class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        ListNode dummy = new ListNode(-1), tail = dummy;
        while (l1 != null && l2 != null) {
            if (l1.val <= l2.val) {
                tail.next = l1;
                l1 = l1.next;
            } else {
                tail.next = l2;
                l2 = l2.next;
            }
            tail = tail.next;
        }
        tail.next = (l1 != null) ? l1 : l2;
        return dummy.next;
    }
}
```

**记忆口诀**：
> **"dummy 当锚、tail 走龙；小的接、大的等、剩的整条挂。"**

### 解法 B：递归

```java
class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        if (l1 == null) return l2;
        if (l2 == null) return l1;
        if (l1.val <= l2.val) {
            l1.next = mergeTwoLists(l1.next, l2);
            return l1;
        } else {
            l2.next = mergeTwoLists(l1, l2.next);
            return l2;
        }
    }
}
```

> 面试推荐迭代版（O(1) 额外空间），递归当亮点补充。

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 迭代 | **O(m + n)** | **O(1)** |
| 递归 | O(m + n) | O(m + n) 递归栈 |

---

## 六、示例验证

`l1 = 1→2→4`，`l2 = 1→3→4`

| 步 | l1 | l2 | 比较 | 接谁 | tail 链表 |
|---|---|---|---|---|---|
| 1 | 1 | 1 | 1≤1 | l1 | dummy→1 |
| 2 | 2 | 1 | 2>1 | l2 | dummy→1→1 |
| 3 | 2 | 3 | 2≤3 | l1 | dummy→1→1→2 |
| 4 | 4 | 3 | 4>3 | l2 | dummy→1→1→2→3 |
| 5 | 4 | 4 | 4≤4 | l1 | dummy→1→1→2→3→4 |
| 6 | null | 4 | 退出循环 | 剩 l2 整条挂 | dummy→1→1→2→3→4→4 |

返回 `dummy.next = 1→1→2→3→4→4` ✅

---

## 七、复盘与延伸

### 一句话总结
> **dummy + tail 走龙：小的接、大的等、剩的整条挂。**

### 新手常见疑问（FAQ）

**Q1：不用 dummy 怎么写？为什么推荐 dummy？**
A：不用 dummy 需要判“是否是第一个节点”才能决定是初始化 head 还是接在后面，多一堆 if。dummy 让所有插入都变“接在某个节点后面”，代码更短。

**Q2：为什么要 `tail = tail.next`？不写会怎样？**
A：tail 不动，下一轮又 `tail.next = ?` 会覆盖刚才接上的节点。最后只会接上一个节点 + 留下剩下那条下去，结果丢节点。

**Q3：为什么最后能“整条挂”（`tail.next = l1 != null ? l1 : l2`）？**
A：两链本身有序，某一条走完后，另一条剩下的节点都 ≥ 已拼接部分的最后一个。直接整条接上仍然有序。

**Q4：递归版与迭代版选哪个？**
A：面试写迭代（O(1) 额外空间）。递归代码短但栈深度 O(m+n)，长链会爆栈。可以说“递归版代码更优雅，但考虑栈空间主选迭代”。

**Q5：需要复制节点后拼接，还是可以复用原节点？**
A：题目默认可复用原节点（指针拼接），更高效。若需要“不修改原链表”，才复制节点。

### 面试官常见 follow-up
1. **"合并 K 个有序链表？"** → 小顶堆装 k 个头节点，每次弹最小；或两两合并分治。即 **LC 23**。
2. **"两条链表中其中一条是降序呢？"** → 先反转那条降序链表，再走本模板。
3. **"合并后去重呢？"** → 拼接时检查 `tail.val == 待接节点.val`，重复则跳过。
4. **"不修改原链表，返回新链？"** → 在 `tail.next = l1` 之前改为 `tail.next = new ListNode(l1.val)`，额外 O(m+n) 空间。
5. **"数组版（LC 88）怎么更优？"** → 从后往前拼，避免后移。
6. **"外部排序场景，两个有序文件合并？"** → 同思路，改用 BufferedReader 读两个文件 + tail 写出。

### 同类型推荐（**dummy + 双指针 家族**）
- LC 23. 合并 K 个升序链表（K 路 + 堆）
- LC 86. 分割链表（双 dummy）
- LC 203. 删除链表中等于给定值的节点
- LC 1669. 合并两个链表（区间删除 + 插入）
- LC 88. 合并两个有序数组（数组版，从后往前更妙）
