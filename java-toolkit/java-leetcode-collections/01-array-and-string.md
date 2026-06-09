# 01 · 数组 & 字符串

> 最基础的两种容器，但坑也最多：`int[]` 不是 `Integer[]`，`String.split` 用正则，`==` 比的是引用……

---

## 一、原生数组 `int[]` / `T[]`

### 1. 声明 & 初始化

```java
int[] a = new int[5];                  // [0,0,0,0,0]
int[] b = {1, 2, 3};                   // 字面量
int[] c = new int[]{1, 2, 3};          // 函数返回时必须用 new int[]
int[][] grid = new int[m][n];          // 二维
int[][] g2  = {{1,2},{3,4}};
```

### 2. 常用 `Arrays.*` 方法

| 操作 | 写法 | 复杂度 |
|---|---|---|
| 排序 | `Arrays.sort(a)` | O(n log n) |
| 排序（区间） | `Arrays.sort(a, 0, k)` | 排 `[0, k)` |
| 排序（自定义 cmp，**只能用 `Integer[]`**） | `Arrays.sort(boxed, (x,y)->y-x)` | 见下方 |
| 排序二维 | `Arrays.sort(intervals, (x,y)->x[0]-y[0])` | 按首元素排 |
| 拷贝 | `Arrays.copyOf(a, newLen)` | 末尾自动补 0 |
| 切片拷贝 | `Arrays.copyOfRange(a, from, to)` | `[from, to)` |
| 填充 | `Arrays.fill(a, -1)` | DP 初始化常用 |
| 二分查找 | `Arrays.binarySearch(a, key)` | 找不到返回 `-(插入点+1)` |
| 打印 | `Arrays.toString(a)` / `Arrays.deepToString(grid)` | 调试神器 |
| 转 stream | `Arrays.stream(a).sum()` | 求和 / max / min |
| 比较 | `Arrays.equals(a, b)` / `Arrays.deepEquals(g1, g2)` | **不能用 `==`** |
| 哈希 | `Arrays.hashCode(a)` / `Arrays.deepHashCode(grid)` | 数组当 key 时用（仍不推荐做 HashMap key） |
| 按索引函数填充 | `Arrays.setAll(a, i -> i * i)` | Java 8+，省一个 for |
| 包装成定长 List | `Arrays.asList(1, 2, 3)` ⚠️ | 见下方 §1.5 三大坑 |

### 3. ⚠️ `int[]` vs `Integer[]`：能否传 comparator？

```java
int[] a = {3,1,2};
Arrays.sort(a);                            // ✅ 升序
// Arrays.sort(a, (x,y)->y-x);             // ❌ 编译错：int[] 不支持 comparator

Integer[] b = {3,1,2};
Arrays.sort(b, (x,y) -> y - x);            // ✅ 降序

// int[] 想降序：先升序再反转 / 转 Integer[]
int[] arr = {3,1,2};
Integer[] boxed = Arrays.stream(arr).boxed().toArray(Integer[]::new);
Arrays.sort(boxed, Comparator.reverseOrder());
arr = Arrays.stream(boxed).mapToInt(Integer::intValue).toArray();
```

> **小技巧**：二维数组可以传 comparator，因为元素类型已经是对象（`int[]`）。

```java
int[][] points = {{1,3},{2,1},{0,4}};
Arrays.sort(points, (p, q) -> p[1] - q[1]);   // ✅ 按第二列升序
```

### 4. 二维数组的初始化坑

```java
int[][] dp = new int[m][n];
Arrays.fill(dp, -1);                            // ❌ 只填了一行的引用
for (int[] row : dp) Arrays.fill(row, -1);      // ✅ 每行单独 fill
```

### 5. 二维数组的「行数 / 列数」

```java
int[][] grid = new int[m][n];
int rows = grid.length;          // m
int cols = grid[0].length;       // n —— 注意要先确保非空
```

> ⚠️ **不规则二维数组**（jagged array）每行长度可能不同，要 `grid[i].length`，不能假设都等于 `grid[0].length`。

### 6. ⚠️ `Arrays.asList` 三大坑（必背）

```java
// 坑 1：基本类型数组传进去，size == 1
int[] a = {1, 2, 3};
List<int[]> wrong = Arrays.asList(a);   // size = 1，元素是整个 int[]
// 想要 List<Integer> 必须先 boxed
List<Integer> ok = Arrays.stream(a).boxed().collect(Collectors.toList());

// 坑 2：返回的是 "定长视图"，不能 add/remove
List<Integer> l = Arrays.asList(1, 2, 3);
l.set(0, 9);   // ✅ 可改
l.add(4);      // ❌ UnsupportedOperationException
// 想可变：
List<Integer> mut = new ArrayList<>(Arrays.asList(1, 2, 3));

// 坑 3：和原数组共享内存
Integer[] arr = {1, 2, 3};
List<Integer> view = Arrays.asList(arr);
arr[0] = 99;            // view.get(0) 也变成 99
```

> 详细版见 [06 · 常见转换与陷阱](./06-conversions-and-pitfalls.md#二arraysaslist-三个大坑)。

---

## 二、`ArrayList` ↔ `int[]` 转换

> 高频考点。**记 4 条 + 1 个坑**就够了。

```java
// int[] → List<Integer>
int[] a = {1,2,3};
List<Integer> list = Arrays.stream(a).boxed().collect(Collectors.toList());

// List<Integer> → int[]
int[] a2 = list.stream().mapToInt(Integer::intValue).toArray();

// int[] → Integer[]（要 comparator 时用）
Integer[] arr = Arrays.stream(a).boxed().toArray(Integer[]::new);

// Integer[] → int[]
int[] a3 = Arrays.stream(arr).mapToInt(Integer::intValue).toArray();
```

> **坑**：`Arrays.asList(a)` 当 `a` 是 `int[]` 时返回的是 `List<int[]>`（只含 1 个元素），不是 `List<Integer>`！
> 因为泛型不接受基本类型。务必先 `boxed()`。

---

## 三、字符串 `String`

### 1. 不可变，比较用 `equals`

```java
String s = "abc", t = "abc";
s == t;                  // 字面量常量池可能是 true，但不要依赖
s.equals(t);             // ✅ 唯一正确写法
s.equalsIgnoreCase(t);   // 忽略大小写
```

### 2. 常用方法速查

| 操作 | 写法 |
|---|---|
| 长度 | `s.length()`（数组是 `.length`，没括号！） |
| 取字符 | `s.charAt(i)` |
| 子串 | `s.substring(l, r)` —— `[l, r)` |
| 拆分（注意是正则） | `s.split(",")` / `s.split("\\s+")` |
| 去首尾空白 | `s.trim()` / `s.strip()` (Java 11+) |
| 包含 / 起止 | `s.contains("ab")` / `s.startsWith` / `s.endsWith` |
| 索引 | `s.indexOf('a')` / `s.lastIndexOf('a')` |
| 替换 | `s.replace('a','b')` / `s.replaceAll("\\d", "*")`（正则） |
| 大小写 | `s.toLowerCase()` / `toUpperCase()` |
| 转 char 数组 | `s.toCharArray()` |
| 比较字典序 | `s.compareTo(t)` 返回负 / 0 / 正 |
| 转数字 | `Integer.parseInt(s)` / `Long.parseLong(s)` |
| 拼接（不用 sb） | `String.join(",", "a", "b")` / `String.join("-", list)` |
| 格式化 | `String.format("%05d", 7)` → `"00007"`；`%.2f` 保留两位小数 |
| 重复 | `"ab".repeat(3)` → `"ababab"`（Java 11+） |
| 字符流 | `s.chars()` 返回 `IntStream`，直接 `.filter` / `.count` |
| char[] → String | `new String(arr)` / `new String(arr, 0, len)` |
| 值 → String | `String.valueOf(123)` / `String.valueOf('x')` |

### 3. 频次统计：`char` → `int` 数组

```java
int[] cnt = new int[26];
for (char c : s.toCharArray()) cnt[c - 'a']++;
```

> 处理 ASCII 用 `new int[128]`。

---

## 四、`StringBuilder` —— 拼接 / 修改

> **任何循环里拼字符串都要用 `StringBuilder`**，否则 O(n²)。

| 操作 | 写法 |
|---|---|
| 创建 | `StringBuilder sb = new StringBuilder();` |
| 预分配容量 | `new StringBuilder(1024)` —— 已知大小时减少扩容 |
| 拼接 | `sb.append("x")` / `sb.append(123)` / `sb.append('a')` |
| 取字符 | `sb.charAt(i)` |
| 改字符 | `sb.setCharAt(i, 'x')` |
| 取子串 | `sb.substring(l, r)` —— `[l, r)`，返回 `String` |
| 查找子串 | `sb.indexOf("ab")` / `sb.lastIndexOf("ab")` |
| 替换区间 | `sb.replace(l, r, "xyz")` —— `[l, r)` 整段换掉 |
| 删除最后一个 | `sb.deleteCharAt(sb.length() - 1)` |
| 删除区间 | `sb.delete(l, r)` —— `[l, r)` |
| 插入 | `sb.insert(i, "abc")` |
| 反转 | `sb.reverse()` |
| 长度 | `sb.length()` |
| 截断 | `sb.setLength(k)` |
| 输出 | `sb.toString()` |

> **回溯题模板**：递归前 `sb.append(c)`，递归后 `sb.deleteCharAt(sb.length()-1)`。

---

## 五、`char` 实战技巧

```java
Character.isDigit(c)        // '0'..'9'
Character.isLetter(c)
Character.isLetterOrDigit(c)
Character.isUpperCase(c)
Character.isLowerCase(c)
Character.toLowerCase(c)
Character.toUpperCase(c)
c - '0'                      // char 转数字
c - 'a'                      // char 转 0..25 索引
(char)('a' + k)              // 数字转 char
```

---

## 六、回顾自测

1. `int[]` 能不能用 `Arrays.sort` 传 comparator？要降序怎么办？
2. `String.split(".")` 为什么不会按点拆？
3. 循环里 `s += "x"` 为什么是 O(n²)？
4. `Arrays.asList(new int[]{1,2,3}).size()` 等于多少？为什么？
5. `Arrays.fill(dp, -1)` 在二维 `dp` 上为什么不生效？

<details>
<summary>答案</summary>

1. 不能。`Arrays.sort(int[])` 是 dual-pivot quicksort 无 comparator 版本。降序：boxing 成 `Integer[]` 再排序，或者升序后 `for` 循环反转。
2. `split` 参数是正则，`.` 在正则里匹配任意字符。要用 `"\\."`。
3. `String` 不可变，每次 `+=` 都创建新对象，重新拷贝整个字符串。
4. `1`。`Arrays.asList` 把 `int[]` 当成单个对象塞进去。
5. `Arrays.fill` 只能填一维。要 `for (int[] row : dp) Arrays.fill(row, -1)`。

</details>
