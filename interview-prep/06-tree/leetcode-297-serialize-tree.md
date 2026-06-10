# LeetCode 297. 二叉树的序列化与反序列化 (Serialize and Deserialize Binary Tree)

> 难度：Hard　|　标签：树、设计、BFS、DFS　|　**树编码经典 ⭐⭐⭐⭐**

---

## 一、题目

序列化是将一个数据结构或者对象转换为连续的比特位的操作。反序列化是相反操作。

请设计一个算法来实现二叉树的 **序列化** 与 **反序列化**。不限定算法格式。

**约束**

- 节点数 `[0, 10^4]`，节点值 `[-1000, 1000]`

**示例**

```
输入：root = [1,2,3,null,null,4,5]
输出：[1,2,3,null,null,4,5]   // 任何能往返成原树的格式都算对
```

题目链接：<https://leetcode.cn/problems/serialize-and-deserialize-binary-tree/>

---

## 二、解题思路（学习重点）

### 1. 两种主流方案

| 方案 | 序列化 | 反序列化 | 格式 |
|---|---|---|---|
| **DFS 前序 + null 占位（推荐）** | 前序遍历，遇 null 写 "#" | 队列读 token，递归构造 | `1,2,#,#,3,4,#,#,5,#,#` |
| BFS 层序（LeetCode 默认） | 层序遍历，null 也入字符串 | 队列依次取出，逐层挂载 | `1,2,3,null,null,4,5` |

DFS 前序版代码更短，**面试默认写它**。

### 2. DFS 前序的原理

序列化：
```text
serialize(node):
    if node == null: return "#"
    return node.val + "," + serialize(left) + "," + serialize(right)
```

反序列化：把字符串切成 token 队列，递归构造：
```text
build(queue):
    token = queue.poll()
    if token == "#": return null
    node = new TreeNode(Integer.parseInt(token))
    node.left  = build(queue)
    node.right = build(queue)
    return node
```

> **学习点 ①**：**"前序遍历 + 空节点占位"** 唯一确定一棵二叉树（不需要中序就能反序列化），因为前序自带"先根后子"的层级信息。

### 3. 容易踩的坑

| 坑 | 处理 |
|---|---|
| 序列化用 `+` 拼接 → O(n²) | 用 `StringBuilder` |
| 反序列化用 `String.split` 后取下标 → 索引管理麻烦 | 用 `Queue<String>` |
| 空树处理 | `serialize(null) = "#"` 自然处理 |
| 负数节点（如 -1000） | 用 `Integer.parseInt`，能处理负数 |

---

## 三、详细解题步骤（DFS 前序版）

**步骤 1**：序列化
```java
public String serialize(TreeNode root) {
    StringBuilder sb = new StringBuilder();
    dfsSer(root, sb);
    return sb.toString();
}
private void dfsSer(TreeNode node, StringBuilder sb) {
    if (node == null) { sb.append("#,"); return; }
    sb.append(node.val).append(',');
    dfsSer(node.left, sb);
    dfsSer(node.right, sb);
}
```

**步骤 2**：反序列化
```java
public TreeNode deserialize(String data) {
    Queue<String> q = new ArrayDeque<>(Arrays.asList(data.split(",")));
    return dfsDes(q);
}
private TreeNode dfsDes(Queue<String> q) {
    String t = q.poll();
    if ("#".equals(t)) return null;
    TreeNode node = new TreeNode(Integer.parseInt(t));
    node.left  = dfsDes(q);
    node.right = dfsDes(q);
    return node;
}
```

---

## 四、Java 题解

```java
public class Codec {
    private static final String NULL = "#";
    private static final String SEP  = ",";

    public String serialize(TreeNode root) {
        StringBuilder sb = new StringBuilder();
        dfsSer(root, sb);
        return sb.toString();
    }
    private void dfsSer(TreeNode node, StringBuilder sb) {
        if (node == null) { sb.append(NULL).append(SEP); return; }
        sb.append(node.val).append(SEP);
        dfsSer(node.left, sb);
        dfsSer(node.right, sb);
    }

    public TreeNode deserialize(String data) {
        Queue<String> q = new ArrayDeque<>(Arrays.asList(data.split(SEP)));
        return dfsDes(q);
    }
    private TreeNode dfsDes(Queue<String> q) {
        String t = q.poll();
        if (NULL.equals(t)) return null;
        TreeNode node = new TreeNode(Integer.parseInt(t));
        node.left  = dfsDes(q);
        node.right = dfsDes(q);
        return node;
    }
}
```

**记忆口诀**：
> **"前序 + # 占位；反序读队列、空就 null、非空建节点递归左右。"**

---

## 五、复杂度

| 操作 | 时间 | 空间 |
|---|---|---|
| serialize / deserialize | **O(n)** | O(n) |

---

## 六、示例验证

```
       1
      / \
     2   3
        / \
       4   5
```

序列化（前序）：`1,2,#,#,3,4,#,#,5,#,#,`

反序列化：
- poll "1" → node(1)
  - left: poll "2" → node(2)
    - left: poll "#" → null
    - right: poll "#" → null
  - right: poll "3" → node(3)
    - left: poll "4" → node(4) → 左右 null
    - right: poll "5" → node(5) → 左右 null

返回原树 ✅

---

## 七、复盘与延伸

### 一句话总结
> **前序遍历 + null 占位，能唯一编码一棵二叉树；反序列化用队列按序消费。**

### 新手常见疑问（FAQ）

**Q1：为什么单独前序就够，不需要中序？**
A：因为加了 null 占位符，每个节点的位置在序列里被完全确定（前序顺序 + 空节点边界）。没有 null 占位时确实需要前序+中序或后序+中序才能唯一还原。

**Q2：BFS 层序版怎么写？**
A：序列化时按层遍历，null 也写入字符串；反序列化时队列依次取出节点，每次为当前节点挂左右孩子（左右孩子的下标在序列中按顺序）。代码长但符合 LeetCode 输入格式。

**Q3：序列化为什么不用 `+` 拼？**
A：String 不可变，`+` 每次新建对象，O(n²) 内存与时间。`StringBuilder` 摊销 O(1) 追加。

**Q4：可以用 JSON / Protobuf 吗？**
A：可以，但面试看的是算法不是序列化库。手写前序是标准答案。

**Q5：节点值含逗号 `,` 怎么办？**
A：本题值是整数不含逗号。如果是字符串值（如 LC 449 BST），需要转义或换分隔符。

### 面试官常见 follow-up
1. **"反序列化用迭代不用递归？"** → 自己模拟栈：遇 # pop 一层；遇值入栈作为当前节点孩子。
2. **"N 叉树的序列化（LC 428）？"** → 前序时也写孩子数量，如 `1[3]2[0]3[0]4[0]`；或带分隔符 / 括号。
3. **"BST 的序列化（LC 449）？"** → 只用前序（无 null），反序列化时用上下界判断每个值归属。空间更省。
4. **"流式反序列化（逐字节）？"** → 用 BufferedReader，每读一个 token 处理。
5. **"加密 / 压缩？"** → 序列化后 gzip + base64。
6. **"内存不够，要序列化到磁盘？"** → 同思路，输出到 FileWriter，反序列化时按需读。

### 同类型推荐（**树编码 / 设计家族**）
- LC 428. 序列化和反序列化 N 叉树
- LC 449. 序列化和反序列化 BST
- [LC 105. 从前序与中序遍历序列构造二叉树](https://leetcode.cn/problems/construct-binary-tree-from-preorder-and-inorder-traversal/)
- [LC 106. 从中序与后序遍历序列构造二叉树](https://leetcode.cn/problems/construct-binary-tree-from-inorder-and-postorder-traversal/)
- LC 889. 根据前序和后序遍历构造二叉树
- [LC 652. 寻找重复的子树](https://leetcode.cn/problems/find-duplicate-subtrees/)（序列化作为哈希 key）
- LC 1485. 克隆含随机指针的二叉树
