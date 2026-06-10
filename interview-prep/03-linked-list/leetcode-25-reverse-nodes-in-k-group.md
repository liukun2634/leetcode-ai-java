# LeetCode 25. K 个一组翻转链表 (Reverse Nodes in K-Group)

> 难度：Hard　|　标签：链表、递归　|　**链表反转进阶 ⭐⭐⭐⭐**

---

## 一、题目

给你链表的头节点 `head`，每 `k` 个节点一组进行翻转，返回修改后的链表。

- `k` 是一个正整数，它的值小于或等于链表的长度
- 如果节点总数 **不是 k 的整数倍**，那么剩余的节点应保持原有顺序
- 不能改变节点内部的值，只能修改节点指针

**约束**

- 链表节点数 `1 <= n <= 5000`
- `1 <= k <= n`

**示例**

```
输入：1→2→3→4→5, k=2
输出：2→1→4→3→5

输入：1→2→3→4→5, k=3
输出：3→2→1→4→5
```

题目链接：<https://leetcode.cn/problems/reverse-nodes-in-k-group/>

---

## 二、解题思路（学习重点）

### 1. 把问题拆成"反转一组 + 接到后面"

对每一组 k 个节点：
1. **先数够 k 个节点**，记录这组的最后一个 `groupEnd`
2. **把这一组反转**（用 LC 206 的三指针模板）
3. **把上一组的尾连接到这一组反转后的新头**
4. **更新 prev 指向这一组反转后的新尾**（即原来的 groupStart）
5. 继续处理下一组

> **学习点 ①**：长链表操作题的核心是 **dummy + 三个关键指针**（prev 上一组尾、groupStart 当前组头、groupEnd 当前组尾）。

### 2. 反转 k 个节点的模板

复用 LC 206 三指针：
```text
prev = null, cur = groupStart
for i in 1..k:
    next = cur.next
    cur.next = prev
    prev = cur
    cur = next
```
反转后 prev 是新头，原 groupStart 是新尾，next 是下一组开始。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 数节点时遇到 null 提前停 → 这组不反转 | 数够 k 个才能反转 |
| 反转后忘了把"上一组尾"连到"这组新头" | dummy / prev 指针牢记 |
| 反转后 groupStart 变成尾，next 接错 | groupStart.next = next 是反转完成的关键 |

---

## 三、详细解题步骤

**步骤 1**：建 dummy
```java
ListNode dummy = new ListNode(0, head);
ListNode prevGroupTail = dummy;
```

**步骤 2**：循环处理每一组
```java
while (true) {
    // 数 k 个节点，找到这组的尾
    ListNode groupEnd = prevGroupTail;
    for (int i = 0; i < k && groupEnd != null; i++) groupEnd = groupEnd.next;
    if (groupEnd == null) break;        // 不够 k 个，停

    ListNode groupStart = prevGroupTail.next;
    ListNode nextGroupStart = groupEnd.next;

    // 反转 [groupStart, groupEnd]
    ListNode prev = nextGroupStart, cur = groupStart;
    while (cur != nextGroupStart) {
        // 注意：这里 cur != nextGroupStart 而不是 != null，停在该组之后
    }
    // 实际写法见下方完整代码
}
```

完整反转细节见解法 A 代码。

---

## 四、Java 题解

### 解法 A：迭代（推荐）

```java
class Solution {
    public ListNode reverseKGroup(ListNode head, int k) {
        ListNode dummy = new ListNode(0, head);
        ListNode prevGroupTail = dummy;

        while (true) {
            // 1. 找到本组的尾节点 groupEnd
            ListNode groupEnd = prevGroupTail;
            for (int i = 0; i < k && groupEnd != null; i++) groupEnd = groupEnd.next;
            if (groupEnd == null) break;     // 不足 k 个，结束

            ListNode groupStart = prevGroupTail.next;
            ListNode nextGroupStart = groupEnd.next;

            // 2. 反转 [groupStart, groupEnd]
            ListNode prev = nextGroupStart;
            ListNode cur = groupStart;
            while (cur != nextGroupStart) {
                ListNode next = cur.next;
                cur.next = prev;
                prev = cur;
                cur = next;
            }

            // 3. 接回主链：上一组尾 → 这组新头（groupEnd）
            prevGroupTail.next = groupEnd;
            // 反转后 groupStart 变成新尾，已经在 while 内指向 nextGroupStart

            // 4. 准备下一轮
            prevGroupTail = groupStart;     // 原 groupStart = 反转后的新尾
        }

        return dummy.next;
    }
}
```

**记忆口诀**：
> **"数 k 个 → 切两端 → 反转 → 头接前、尾接后；prev 指向新尾。"**

### 解法 B：递归

```java
class Solution {
    public ListNode reverseKGroup(ListNode head, int k) {
        ListNode cur = head;
        for (int i = 0; i < k; i++) {
            if (cur == null) return head;     // 不足 k 个，保持原序
            cur = cur.next;
        }
        // 反转前 k 个，cur 是下一组的头
        ListNode newHead = reverseFirstK(head, k);
        head.next = reverseKGroup(cur, k);    // 递归处理剩余
        return newHead;
    }
    private ListNode reverseFirstK(ListNode head, int k) {
        ListNode prev = null, cur = head;
        for (int i = 0; i < k; i++) {
            ListNode next = cur.next;
            cur.next = prev;
            prev = cur;
            cur = next;
        }
        return prev;
    }
}
```

---

## 五、复杂度

| 解法 | 时间 | 空间 |
|---|---|---|
| 迭代 | **O(n)** | **O(1)** |
| 递归 | O(n) | O(n/k) 递归栈 |

---

## 六、示例验证

`1→2→3→4→5, k=2`

| 轮 | prevGroupTail | groupStart | groupEnd | 反转 | 接回后链表 |
|---|---|---|---|---|---|
| 1 | dummy | 1 | 2 | 1→2 → 2→1 | dummy→2→1→3→4→5 |
| 2 | 1 | 3 | 4 | 3→4 → 4→3 | dummy→2→1→4→3→5 |
| 3 | 3 | 5 | null (不足) | 跳出 | — |

返回 `2→1→4→3→5` ✅

---

## 七、复盘与延伸

### 一句话总结
> **每组反转 + dummy 指针管理：数 k 个、反转、接回主链、prev 指向新尾。**

### 新手常见疑问（FAQ）

**Q1：为什么需要 dummy？**
A：第一组反转后，原 head 变成第一组的尾，新的头是原 k 节点。dummy 让"接前"操作统一（`dummy.next = newHead`）。

**Q2：递归版栈深度多少？**
A：n/k 层。n=5000、k=1 → 5000 层，JVM 默认栈 ~10⁴ 安全；但 k=1 时反转每组没意义，实际不会这样。

**Q3：剩余不足 k 个为什么不反转？**
A：题目要求。如果题目要求"剩余也反转"，把退出条件改成 `cur != null` 即可。

**Q4：反转一组的 while 条件 `cur != nextGroupStart` 是什么意思？**
A：把 prev 初始化为 nextGroupStart，反转时一直反转到 cur 跨过 groupEnd（即等于 nextGroupStart）。这样 groupStart 的 next 自动接到 nextGroupStart。

**Q5：能否用栈反转？**
A：可以，把 k 个节点 push 入栈再 pop 重连。O(n) 空间，不如三指针。

### 面试官常见 follow-up
1. **"剩余不足 k 个也要反转？"** → 数节点时不检查 null，强行反转剩余。
2. **"每 k 个一组旋转（不反转）？"** → 找到分割点，重新拼接。
3. **"反转链表的某个区间 [m, n]？"** → [LC 92](https://leetcode.cn/problems/reverse-linked-list-ii/)，dummy + 走到 m-1，反转 (n-m+1) 个。
4. **"两两交换（k=2 特例，[LC 24](https://leetcode.cn/problems/swap-nodes-in-pairs/)）？"** → 本题代入 k=2 即可。
5. **"如果 k 很大，链表很长，避免爆栈？"** → 用迭代版。
6. **"如何用栈实现？"** → 每次压 k 个，pop 时重连前驱。代码更长但思路直观。

### 同类型推荐（**链表反转家族**）
- [LC 206. 反转链表](https://leetcode.cn/problems/reverse-linked-list/)（最简版）
- [LC 92. 反转链表 II](https://leetcode.cn/problems/reverse-linked-list-ii/)（区间反转）
- [LC 24. 两两交换链表中的节点](https://leetcode.cn/problems/swap-nodes-in-pairs/)（k=2 特例）
- [LC 61. 旋转链表](https://leetcode.cn/problems/rotate-list/)（不是反转）
- [LC 234. 回文链表](https://leetcode.cn/problems/palindrome-linked-list/)（找中点 + 反转后半）
- [LC 143. 重排链表](https://leetcode.cn/problems/reorder-list/)（找中点 + 反转后半 + 合并）
