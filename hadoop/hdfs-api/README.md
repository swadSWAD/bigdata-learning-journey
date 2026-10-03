# HDFS Java API 示例

用 Java 客户端操作 HDFS 的完整示例，覆盖日常开发中最常用的 10 个操作。

## 包含的操作

| # | 方法 | 说明 |
|:--:|:---|:---|
| 1 | `mkdirs` | 创建目录（支持多级） |
| 2 | `upload` | 本地上传到 HDFS |
| 3 | `download` | HDFS 下载到本地 |
| 4 | `delete` | 删除文件或目录 |
| 5 | `rename` | 重命名 / 移动 |
| 6 | `listFiles` | 遍历目录并打印文件详情 |
| 7 | `cat` | 读取文件内容 |
| 8 | `fileDetail` | 获取文件/目录的详细信息 |
| 9 | `write` | 直接写入文件（不经过本地） |
| 10 | `append` | 追加内容 |

## 关键知识点

### 1. 获取 FileSystem 对象

有两种方式，**推荐第一种**：

```java
// 方式一：显式指定 URI 和用户（优先级最高，不依赖配置文件）
Configuration conf = new Configuration();
FileSystem fs = FileSystem.get(URI.create("hdfs://hadoop102:8020"), conf, "atguigu");

// 方式二：依赖 core-site.xml 中的 fs.defaultFS
FileSystem fs = FileSystem.get(conf);
```

**方式二的坑**：如果 classpath 里没有 `core-site.xml`，`FileSystem.get(conf)` 会连到**本地文件系统**而不是 HDFS，而且不会报错——你会看到文件"写入成功"，但在 HDFS 上找不到，因为写到本地磁盘了。

### 2. 用户身份

第三个参数是 HDFS 用户名，**必须与集群配置的超级用户一致**。如果集群的 HDFS 目录属主是 `atguigu`，而这里传 `root`，会直接报：

```
org.apache.hadoop.security.AccessControlException: Permission denied:
user=root, access=WRITE, inode="/":atguigu:supergroup:drwxr-xr-x
```

**HDFS 的权限校验基于用户名，不是操作系统权限**——这是新手最容易困惑的点。

### 3. copyFromLocalFile 的参数

```java
fs.copyFromLocalFile(
    boolean delSrc,      // 是否删除本地源文件
    boolean overwrite,   // 是否覆盖 HDFS 上的同名文件
    Path src,            // 本地路径
    Path dst             // HDFS 路径
);
```

注意 `delSrc` 传 `true` 会把本地文件删掉，用的时候要小心。

## 如何运行

### 方式一：用脚本（不依赖 Maven）

```bash
bash run_hdfs_api.sh
```

脚本会自动取 `hadoop classpath`、编译、运行。

### 方式二：用 Maven

```bash
mvn clean package
mvn exec:java -Dexec.mainClass="com.atguigu.hdfs.HdfsClient"
```

### 方式三：手动编译

```bash
CP=$(hadoop classpath)
javac -encoding UTF-8 -cp "$CP" -d target/classes \
    src/main/java/com/atguigu/hdfs/HdfsClient.java
java -cp "target/classes:$CP:$HADOOP_HOME/etc/hadoop" com.atguigu.hdfs.HdfsClient
```

## 运行结果示例

```
[初始化] 已连接 HDFS: hdfs://hadoop102:8020

==================== HDFS Java API 演示 ====================
[创建目录] /api-test -> 成功
[写入文件] /api-test/hello.txt 完成
[追加写入] /api-test/hello.txt 完成
[读取内容] /api-test/hello.txt
Hello HDFS
第二行内容
追加的一行

[详情] /api-test/hello.txt | 目录=false | 文件=true | 大小=46 字节 | 修改时间=1780000000000
[遍历目录] /api-test 共 1 项
    hello.txt  权限=rw-r--r--  副本=3  大小=46  属主=atguigu
[重命名] /api-test/hello.txt -> /api-test/hello-renamed.txt : 成功
[删除] /api-test/hello-renamed.txt -> 成功
[关闭] FileSystem 已释放
```
