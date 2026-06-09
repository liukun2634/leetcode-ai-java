# 06 · 常见转换与陷阱

> LeetCode 上让人写错最多的不是算法，是**类型转换**和**自动装箱**。

---

## 一、`int[]` ↔ `Integer[]` ↔ `List<Integer>` 速查

```java
// === int[] → 其它 ===
int[] a = {1, 2, 3};

// → Integer[]
Integer[] boxed = Arrays.stream(a).boxed().toArray(Integer[]::new);

// → List<Integer>
List<Integer> list = Arrays.stream(a).boxed().collect(Collectors.toList());
// Java 16+ 更简：
List<Integer> list2 = Arrays.stream(a).boxed().toList();   // 不可变

// === Integer[] → 其它 ===
Integer[] arr = {1, 2, 3};

// → int[]
int[] a2 = Arrays.stream(arr).mapToInt(Integer::intValue).toArray();

// → List<Integer>
List<Integer> l = Arrays.asList(arr);              // 定长
List<Integer> l2 = new ArrayList<>(Arrays.asList(arr));  // 可改

// === List<Integer> → 其它 ===
List<Integer> list3 = List.of(1, 2, 3);

// → int[]
int[] a3 = list3.stream().mapToInt(Integer::intValue).toArray();

// → Integer[]
Integer[] arr2 = list3.toArray(new Integer[0]);
```

### 一张表搞定

| 从 \ 到 | `int[]` | `Integer[]` | `List<Integer>` |
|---|---|---|---|
| `int[]` | — | `stream().boxed().toArray(Integer[]::new)` | `stream().boxed().collect(toList())` |
| `Integer[]` | `stream().mapToInt(Integer::intValue).toArray()` | — | `Arrays.asList(arr)` (定长) |
| `List<Integer>` | `stream().mapToInt(Integer::intValue).toArray()` | `toArray(new Integer[0])` | — |

### `char[]` / `String` / `String[]` / `List<String>` 互转

```java
// String ↔ char[]
char[] cs = "abc".toCharArray();
String s  = new String(cs);                       // 全部
String s2 = new String(cs, 0, 2);                 // 截断 [0, 2)
String s3 = String.valueOf(cs);                   // 同 new String(cs)

// String[] ↔ List<String>
String[] arr = {"a", "b", "c"};
List<String> list = new ArrayList<>(Arrays.asList(arr));   // 可变
List<String> view = Arrays.asList(arr);                    // 定长视图
String[] back = list.toArray(new String[0]);

// List<String> 拼成 String
String joined = String.join(",", list);                    // "a,b,c"

// String 拆成 List<String>
List<String> parts = Arrays.asList("a,b,c".split(","));    // 注意 split 是正则
```

### `int[][]` 深拷贝（`clone()` 是浅拷贝坑！）

```java
int[][] grid = {{1, 2}, {3, 4}};

int[][] shallow = grid.clone();        // ❌ 只复制了外层引用，子数组还是同一个
shallow[0][0] = 99;                    // grid[0][0] 也变 99

// ✅ 深拷贝
int[][] deep = new int[grid.length][];
for (int i = 0; i < grid.length; i++) {
    deep[i] = grid[i].clone();
}
// 或 stream 一行写
int[][] deep2 = Arrays.stream(grid).map(int[]::clone).toArray(int[][]::new);
```

> 一维 `int[] a = b.clone();` 是真深拷贝，安全。**多维必须逐行 clone**。

---

## 二、`Arrays.asList` 三个大坑

### 坑 1：基本类型数组传进去

```java
int[] a = {1, 2, 3};
List<int[]> wrong = Arrays.asList(a);       // size = 1，元素是整个数组
// list.get(0) == a
```

> `Arrays.asList(T... a)` 是变长参数。基本类型不能作泛型，整个数组被当成单个对象。

### 坑 2：返回的 List 是**固定长度视图**

```java
List<Integer> l = Arrays.asList(1, 2, 3);
l.add(4);   // ❌ UnsupportedOperationException
l.set(0, 9); // ✅ 可改，但不能加/删
```

> 想要可变：`new ArrayList<>(Arrays.asList(...))`。

### 坑 3：和原数组共享内存

```java
Integer[] arr = {1, 2, 3};
List<Integer> l = Arrays.asList(arr);
arr[0] = 99;          // l.get(0) 也变成 99！
```

---

## 三、自动装箱坑

### 坑 1：`==` 比较 `Integer`

```java
Integer a = 127, b = 127;
a == b;            // true（IntegerCache 缓存 [-128, 127]）

Integer c = 128, d = 128;
c == d;            // ❌ false！是两个对象
c.equals(d);       // ✅ true
```

> **`Integer` 比较永远用 `.equals()`** 或 `.intValue()` 后比。

### 坑 2：`List.remove` 的重载

```java
List<Integer> list = new ArrayList<>(Arrays.asList(1, 2, 3));
list.remove(1);                  // 删索引 1 → [1, 3]
list.remove((Integer) 1);        // 删值 1 → [2, 3]
list.remove(Integer.valueOf(1)); // 同上
```

### 坑 3：`Map.get` 返回 `null`，直接拆箱 NPE

```java
Map<String, Integer> m = new HashMap<>();
int v = m.get("notExist");      // ❌ NullPointerException
int v2 = m.getOrDefault("x", 0); // ✅
```

---

## 四、排序的常见写法

```java
int[] a = {3, 1, 2};
Arrays.sort(a);                        // 升序

Integer[] b = {3, 1, 2};
Arrays.sort(b, Comparator.reverseOrder());   // 降序

// 二维数组
int[][] g = {{2,3},{1,5},{4,1}};
Arrays.sort(g, (x, y) -> x[0] - y[0]);        // 按第一列升序
Arrays.sort(g, Comparator.comparingInt(x -> x[0]));

// 多 key
Arrays.sort(g, (x, y) -> x[0] != y[0] ? x[0] - y[0] : y[1] - x[1]);
Arrays.sort(g,
    Comparator.<int[]>comparingInt(x -> x[0])
              .thenComparingInt(x -> -x[1])
);

// 字符串数组按长度
String[] ss = {"abc","a","ab"};
Arrays.sort(ss, (x, y) -> x.length() - y.length());

// List<int[]>
List<int[]> list = new ArrayList<>();
list.sort((x, y) -> x[0] - y[0]);
Collections.sort(list, (x, y) -> x[0] - y[0]);
```

> 减法陷阱：**只有保证不会溢出**才用 `x - y`，否则用 `Integer.compare(x, y)`。

---

## 五、二分查找：`Arrays.binarySearch` 用法

```java
int[] a = {1, 3, 5, 7, 9};
int i = Arrays.binarySearch(a, 5);   // 2

int j = Arrays.binarySearch(a, 4);
// 找不到时返回 -(insertion_point + 1)
// 4 应插在索引 2 → 返回 -3
int insertAt = -j - 1;               // 2
```

> 用途：**排序后的数组，求"第一个 ≥ x 的位置"** —— 直接 `-binarySearch(a, x) - 1` 就是插入点。
> 但要严谨处理"刚好等于 x"的情况，自己写 `lowerBound` 通常更清晰。

---

## 六、Stream 速查（够用就行）

```java
int[] a = {1, 2, 3, 4, 5};

Arrays.stream(a).sum();              // 15
Arrays.stream(a).max().getAsInt();   // 5
Arrays.stream(a).min().getAsInt();   // 1
Arrays.stream(a).average().getAsDouble();
Arrays.stream(a).filter(x -> x > 2).toArray();
Arrays.stream(a).map(x -> x * x).sum();

// List
List<Integer> list = List.of(1,2,3);
list.stream().mapToInt(Integer::intValue).sum();
```

> ⚠️ **Stream 写起来短但比 for 慢**。LeetCode 数据大时优先 for 循环。

---

## 七、`String.split` 是正则

```java
"a.b.c".split(".");      // ❌ 空数组！'.' 在正则里匹配任意字符
"a.b.c".split("\\.");    // ✅ ["a","b","c"]
"a|b|c".split("\\|");    // ✅
"  a   b  ".split("\\s+"); // 多空格
```

不需要正则、追求性能：`StringTokenizer` 或自己手写。

---

## 八、回顾自测

1. `int[]` 怎么转成 `List<Integer>`？写两行。
2. `Integer a = 200, b = 200; a == b` 结果？
3. `Arrays.asList(new int[]{1,2,3}).size()` 等于？
4. `Arrays.binarySearch(a, x)` 找不到时返回什么？
5. `"1.2.3".split(".")` 返回什么？

<details>
<summary>答案</summary>

1.
```java
int[] a = {1, 2, 3};
List<Integer> list = Arrays.stream(a).boxed().collect(Collectors.toList());
```
2. `false`。`Integer` 缓存范围 `[-128, 127]`，超出后是新对象，`==` 比引用。
3. `1`。`int[]` 不能拆成 `Integer`，整个数组当一个元素。
4. `-(插入点 + 1)`。即"如果要插入，应该插的位置取负再 -1"。
5. 空数组 `[]`。`.` 是正则，匹配任意字符 → 全被吃掉。要用 `"\\."`。

</details>
