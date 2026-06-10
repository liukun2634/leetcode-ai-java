# LeetCode 155. 最小栈 (Min Stack)

> 难度：Medium　|　标签：栈、设计　|　**辅助栈设计经典 ⭐⭐⭐**

---

## 一、题目

设计一个支持 `push`、`pop`、`top` 操作，并能在 **常数时间内检索到最小元素** 的栈。

实现 `MinStack` 类：
- `MinStack()` 初始化堆栈对象
- `void push(int val)` 将元素 val 推入栈
- `void pop()` 删除堆栈顶部的元素
- `int top()` 获取堆栈顶部的元素
- `int getMin()` 获取堆栈中的最小元素

**约束**

- `-2^31 <= val <= 2^31 - 1`
- pop、top、getMin 总是在非空栈上调用

题目链接：<https://leetcode.cn/problems/min-stack/>

---

## 二、解题思路（学习重点）

### 1. 为什么不能"只用一个变量记录 min"？

考虑 `push(3), push(1), pop()`：
- push 3 → min = 3
- push 1 → min = 1
- pop → min 应回到 3，但单变量丢失了 3

**关键：需要记录"每个时刻的 min 历史"**。

### 2. 辅助栈方案：两个栈同步增减

- `stack`：正常栈
- `minStack`：每个位置存"截至此时为止的最小值"

push 时：
```text
stack.push(val)
minStack.push(min(minStack.peek(), val))   // 如 minStack 空，直接 push val
```

pop 时同时弹两个栈。

> **学习点 ①**：**"维护历史最值"** 的最直接做法 = **同步辅助栈**。同模板：LC 716（最大栈）、LC 232（两栈实现队列变种）。

### 3. 优化版：辅助栈只在"变小或相等"时记录

辅助栈大小可能从 n 优化到 ≤ n。pop 时若弹出值等于 minStack 顶才弹辅助栈。空间常数小一点。

### 4. 进阶：单栈 + 差值（O(1) 额外空间）

不存原值，存"差值 val - currentMin"：
- val ≥ min：push 差值（≥0）
- val < min：push (val - min)（<0），同时更新 min

pop 时根据栈顶 ≥0 / <0 还原。

> 这种解法常数小，但代码绕，**面试默认写辅助栈版**。

### 5. 容易踩的坑

| 坑 | 处理 |
|---|---|
| `minStack` 空时直接调 `peek` | push 时检查空，直接 push val |
| pop 时只弹 stack 不弹 minStack | 必须同步 |
| 用 `Stack` 慢 | `Deque<Integer> stack = new ArrayDeque<>();` |

---

## 三、详细解题步骤

**步骤 1**：定义两个栈
```java
private Deque<Integer> stack = new ArrayDeque<>();
private Deque<Integer> minStack = new ArrayDeque<>();
```

**步骤 2**：push
```java
public void push(int val) {
    stack.push(val);
    minStack.push(minStack.isEmpty() ? val : Math.min(minStack.peek(), val));
}
```

**步骤 3**：pop
```java
public void pop() {
    stack.pop();
    minStack.pop();
}
```

**步骤 4**：top / getMin
```java
public int top()    { return stack.peek(); }
public int getMin() { return minStack.peek(); }
```

---

## 四、Java 题解

### 解法 A：同步辅助栈（推荐）

```java
class MinStack {
    private final Deque<Integer> stack = new ArrayDeque<>();
    private final Deque<Integer> minStack = new ArrayDeque<>();

    public void push(int val) {
        stack.push(val);
        minStack.push(minStack.isEmpty() ? val : Math.min(minStack.peek(), val));
    }
    public void pop()       { stack.pop(); minStack.pop(); }
    public int top()        { return stack.peek(); }
    public int getMin()     { return minStack.peek(); }
}
```

**记忆口诀**：
> **"两栈同步：push 一个最值压顶，pop 一起出。"**

### 解法 B：单栈 + 差值（O(1) 额外空间）

```java
class MinStack {
    private final Deque<Long> stack = new ArrayDeque<>();
    private long min;

    public void push(int val) {
        if (stack.isEmpty()) {
            stack.push(0L);
            min = val;
        } else {
            stack.push((long) val - min);
            if (val < min) min = val;
        }
    }
    public void pop() {
        long diff = stack.pop();
        if (diff < 0) min -= diff;     // val < min → 还原前 min
    }
    public int top() {
        long diff = stack.peek();
        return diff < 0 ? (int) min : (int) (min + diff);
    }
    public int getMin() { return (int) min; }
}
```

---

## 五、复杂度

| 操作 | 时间 | 空间 |
|---|---|---|
| push/pop/top/getMin | **O(1)** | O(n)（辅助栈版）/ O(1)（差值版）|

---

## 六、示例验证

```
push(-2)  → stack=[-2],     min=[-2]
push(0)   → stack=[-2,0],   min=[-2,-2]
push(-3)  → stack=[-2,0,-3], min=[-2,-2,-3]
getMin()  → -3
pop()     → stack=[-2,0],   min=[-2,-2]
top()     → 0
getMin()  → -2
```

✅

---

## 七、复盘与延伸

### 一句话总结
> **同步辅助栈：每次 push 把"截至此时的最小值"也压入辅助栈；pop 同时弹两个。**

### 新手常见疑问（FAQ）

**Q1：能不能"只用一个变量记 min"？**
A：不行。pop 后 min 需要回到上一时刻的值，单变量无法记录历史。

**Q2：辅助栈空间能否优化？**
A：能：只在 `val <= minStack.peek()` 时入辅助栈，pop 时若顶值相等才弹。最坏仍 O(n)，但常数更小。

**Q3：差值法的精度问题？**
A：差值可能超 int 范围（如 `Integer.MAX_VALUE - Integer.MIN_VALUE`）。用 `long`。

**Q4：能否求 getMedian？**
A：不能 O(1)。中位数需双堆维护（LC 295）。

**Q5：线程安全吗？**
A：本题单线程；多线程要加锁或用 `ConcurrentLinkedDeque`，但操作不再 O(1) 原子。

### 面试官常见 follow-up
1. **"实现 MaxStack（[LC 716](https://leetcode.cn/problems/max-stack/)）？"** → 把 `Math.min` 换成 `Math.max`。但 [LC 716](https://leetcode.cn/problems/max-stack/) 还要支持 popMax，需要双链表 + TreeMap。
2. **"O(1) 空间方案？"** → 差值法（见解法 B）。
3. **"两栈实现队列（[LC 232](https://leetcode.cn/problems/implement-queue-using-stacks/)）？"** → 类似设计题，用 in/out 双栈。
4. **"队列实现栈（[LC 225](https://leetcode.cn/problems/implement-stack-using-queues/)）？"** → 用两个队列轮转。
5. **"线程安全的 MinStack？"** → 加 ReentrantLock；或读多写少时 RWLock。
6. **"返回 getMin 时的栈快照？"** → 用持久化数据结构（不可变栈）。

### 同类型推荐（**栈设计家族**）
- [LC 232. 用栈实现队列](https://leetcode.cn/problems/implement-queue-using-stacks/)
- [LC 225. 用队列实现栈](https://leetcode.cn/problems/implement-stack-using-queues/)
- [LC 716. 最大栈](https://leetcode.cn/problems/max-stack/)
- [LC 895. 最大频率栈](https://leetcode.cn/problems/maximum-frequency-stack/)
- [LC 1381. 设计一个支持增量操作的栈](https://leetcode.cn/problems/design-a-stack-with-increment-operation/)
- [LC 1063. 有效子数组数](https://leetcode.cn/problems/number-of-valid-subarrays/)（单调栈）
