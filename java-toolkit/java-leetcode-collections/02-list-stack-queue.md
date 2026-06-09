# 02 · List · Stack · Queue · Deque

> **核心结论**：在 LeetCode 里——
> - 变长数组 → `ArrayList`
> - **栈 → `Deque<T> st = new ArrayDeque<>();`**
> - **队列 → `Deque<T> q = new ArrayDeque<>();`**
> - 单调队列（双端） → 同上，用 `Deque` 接口
>
> 不要再用 `java.util.Stack` 和把 `LinkedList` 当队列。

---

## 一、`ArrayList<T>` —— 变长数组

| 操作 | 写法 | 复杂度 |
|---|---|---|
| 创建 | `List<Integer> list = new ArrayList<>();` | - |
| 预分配容量 | `new ArrayList<>(n)` | 已知大小时强烈推荐 |
| 从集合拷贝 | `new ArrayList<>(otherCollection)` | O(n) |
| 不可变字面量 | `List.of(1, 2, 3)` ⚠️ 定长且不能改 | Java 9+ |
| 加到末尾 | `list.add(x)` | O(1) 摊还 |
| 加到指定位置 | `list.add(i, x)` | O(n) |
| 批量加入 | `list.addAll(other)` | O(k) |
| 读 | `list.get(i)` | O(1) |
| 改 | `list.set(i, x)` | O(1) |
| 删指定位置 | `list.remove(i)` | O(n) |
| 删指定值 | `list.remove(Integer.valueOf(x))` ⚠️ | O(n) |
| 按条件删 | `list.removeIf(x -> x < 0)` | O(n)，避免迭代中手工删 |
| 批量变换 | `list.replaceAll(x -> x * 2)` | O(n) |
| 是否包含 | `list.contains(x)` | O(n) |
| 长度 | `list.size()` | O(1) |
| 末尾 | `list.get(list.size() - 1)` | O(1) |
| 清空 | `list.clear()` | O(n) |
| 转数组 | `list.toArray(new Integer[0])` | O(n) |
| 子列表 | `list.subList(l, r)` —— `[l, r)`，**共享底层数组** | O(1) 视图 |
| 排序 | `list.sort((x,y) -> x-y)` / `Collections.sort(list)` | O(n log n) |

### ⚠️ `remove(int)` vs `remove(Integer)`

```java
List<Integer> list = new ArrayList<>(Arrays.asList(1, 2, 3));
list.remove(1);                 // 删索引 1 → 剩 [1, 3]
list.remove(Integer.valueOf(1)); // 删值 1 → 剩 [2, 3]
```

> 重载 + 自动装箱的经典坑，**面试常考**。

### `Arrays.asList` 的坑

```java
List<Integer> a = Arrays.asList(1, 2, 3);
a.add(4);     // ❌ UnsupportedOperationException：定长视图
```

正确写法：

```java
List<Integer> a = new ArrayList<>(Arrays.asList(1, 2, 3));
```

---

## 二、栈 —— **永远用 `Deque` + `ArrayDeque`**

```java
Deque<Integer> stack = new ArrayDeque<>();
stack.push(1);              // 压栈（= addFirst）
stack.push(2);
int top  = stack.peek();    // 看栈顶 = peekFirst
int out  = stack.pop();     // 弹栈 = removeFirst
int size = stack.size();
boolean empty = stack.isEmpty();
```

### 栈方法对照表

| 概念 | `Deque` API | 备注 |
|---|---|---|
| 入栈 | `push(x)` | = `addFirst(x)` |
| 出栈 | `pop()` | = `removeFirst()`，**空时抛异常** |
| 看栈顶 | `peek()` | = `peekFirst()`，**空时返回 `null`** |
| 是否空 | `isEmpty()` | |
| 大小 | `size()` | |

### 为什么不用 `java.util.Stack`？

- 继承 `Vector` → 方法 `synchronized` → 慢
- 遍历顺序是「**从底到顶**」反直觉
- 官方文档明确推荐用 `Deque` 替代

---

## 三、队列（FIFO）—— **同样用 `Deque` + `ArrayDeque`**

```java
Deque<Integer> queue = new ArrayDeque<>();
queue.offer(1);             // 入队 = addLast
queue.offer(2);
int head = queue.peek();    // 看队头
int out  = queue.poll();    // 出队 = removeFirst
```

### 队列方法对照表

| 概念 | 推荐 API | 异常版本 | 备注 |
|---|---|---|---|
| 入队 | `offer(x)` | `add(x)` | 末尾插入 |
| 出队 | `poll()` | `remove()` | 队头删除，空时分别返回 `null` / 抛异常 |
| 看队头 | `peek()` | `element()` | 同上 |

> **`offer/poll/peek` 用 `null` 表示空**，循环 `while ((x = q.poll()) != null)` 很常用。

### 为什么不用 `new LinkedList<>()` 当队列？

- `LinkedList` 每个节点有 next/prev 指针 → 内存开销 + cache miss
- `ArrayDeque` 是循环数组 → 更快，几乎所有场景胜出
- 唯一例外：要在中间插入/删除节点（LeetCode 几乎不需要）

---

## 四、双端队列 / 单调队列 —— 用全套 `Deque` API

```java
Deque<Integer> dq = new ArrayDeque<>();

// 头部
dq.offerFirst(1);   dq.pollFirst();   dq.peekFirst();
// 尾部
dq.offerLast(2);    dq.pollLast();    dq.peekLast();
```

### 单调队列模板（LeetCode 239 滑动窗口最大值）

```java
public int[] maxSlidingWindow(int[] nums, int k) {
    Deque<Integer> dq = new ArrayDeque<>();      // 存索引，保证 nums 对应值递减
    int[] ans = new int[nums.length - k + 1];
    for (int i = 0; i < nums.length; i++) {
        // 1. 弹出窗口外
        if (!dq.isEmpty() && dq.peekFirst() <= i - k) dq.pollFirst();
        // 2. 维持单调递减：弹掉所有比当前小的尾部
        while (!dq.isEmpty() && nums[dq.peekLast()] < nums[i]) dq.pollLast();
        // 3. 加入当前
        dq.offerLast(i);
        // 4. 记录答案
        if (i >= k - 1) ans[i - k + 1] = nums[dq.peekFirst()];
    }
    return ans;
}
```

> 模板背熟：「**弹过期 → 维持单调 → 入队 → 取头**」。

---

## 五、`LinkedList` 什么时候用？

| 场景 | 推荐 |
|---|---|
| 当队列 / 栈 | ❌ 用 `ArrayDeque` |
| 当 List | ❌ 用 `ArrayList`（`get(i)` O(n) vs O(1)） |
| 需要在迭代中频繁 `it.remove()` | ✅ `LinkedList` 节省指针 |
| 实现 LRU 自己手写双向链表 | ✅ 借鉴它的双向节点设计，但通常用 `LinkedHashMap`（见 04） |

> 结论：**LeetCode 99% 题目不需要 `LinkedList`**。

---

## 六、四种 API 的"抛异常 vs 返回 null"对照（必背）

| 操作 | 抛异常 | 返回 null / false |
|---|---|---|
| 队列入 | `add(x)` | `offer(x)` |
| 队列出 | `remove()` | `poll()` |
| 看队头 | `element()` | `peek()` |
| 栈入 | `push(x)` | （无） |
| 栈出 | `pop()` | （无） |

> 记忆口诀：「**`add/remove/element` 暴脾气，`offer/poll/peek` 好脾气**」。
> LeetCode 推荐**全程用好脾气版**，配 `isEmpty()` 检查。

---

## 七、回顾自测

1. `Deque` 当栈时，`push`/`pop` 操作的是哪一端？
2. `LinkedList<Integer> q = new LinkedList<>(); q.poll();` 当队列空时返回什么？
3. `list.remove(1)` 和 `list.remove(Integer.valueOf(1))` 区别？
4. 为什么不要 `new Stack<>()`？
5. `ArrayList` 末尾 add 是 O(1) 吗？

<details>
<summary>答案</summary>

1. 头部（`addFirst` / `removeFirst`）。
2. `null`。`poll` 不抛异常，`remove()` 才抛。
3. 前者按索引删，后者按值删。
4. 继承 `Vector`、`synchronized` 慢、遍历顺序反直觉，官方推荐 `Deque`。
5. **摊还** O(1)。底层数组满时翻倍扩容（拷贝 O(n)），但平均仍 O(1)。

</details>
