package com.atguigu.hdfs;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FSDataInputStream;
import org.apache.hadoop.fs.FSDataOutputStream;
import org.apache.hadoop.fs.FileStatus;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IOUtils;

import java.io.IOException;
import java.net.URI;

/**
 * HDFS Java API 操作示例
 *
 * 覆盖：创建目录、上传、下载、删除、重命名、遍历、读取内容、获取文件详情、追加写入
 *
 * 编译运行见同目录 README.md 或执行 run_hdfs_api.sh
 *
 * @author 张齐涛
 */
public class HdfsClient {

    /** NameNode 地址 */
    private static final String HDFS_URI = "hdfs://hadoop102:8020";
    /** HDFS 超级用户名（须与集群配置一致，否则会报 Permission denied） */
    private static final String HDFS_USER = "atguigu";

    private final FileSystem fs;

    public HdfsClient() throws IOException, InterruptedException {
        Configuration conf = new Configuration();

        // ---------- 获取 FileSystem 的两种方式 ----------
        // 方式一（推荐）：显式指定 URI 和用户，优先级最高，不依赖配置文件
        fs = FileSystem.get(URI.create(HDFS_URI), conf, HDFS_USER);

        // 方式二：依赖 core-site.xml 中的 fs.defaultFS
        // 需要在 classpath 中放 core-site.xml，否则会连到本地文件系统
        // fs = FileSystem.get(conf);

        System.out.println("[初始化] 已连接 HDFS: " + fs.getUri());
    }

    // ============================================================
    // 1. 创建目录
    // ============================================================
    public void mkdirs(String path) throws IOException {
        boolean created = fs.mkdirs(new Path(path));
        System.out.printf("[创建目录] %s -> %s%n", path, created ? "成功" : "已存在");
    }

    // ============================================================
    // 2. 上传文件
    // 参数依次为：是否删除本地源文件、是否覆盖目标文件、本地路径、HDFS 路径
    // ============================================================
    public void upload(String local, String remote) throws IOException {
        fs.copyFromLocalFile(false, true, new Path(local), new Path(remote));
        System.out.printf("[上传文件] %s -> %s%n", local, remote);
    }

    // ============================================================
    // 3. 下载文件
    // ============================================================
    public void download(String remote, String local) throws IOException {
        // 参数：是否删除源文件、HDFS 路径、本地路径、是否使用本地文件系统
        fs.copyToLocalFile(false, new Path(remote), new Path(local), true);
        System.out.printf("[下载文件] %s -> %s%n", remote, local);
    }

    // ============================================================
    // 4. 删除文件或目录（recursive 决定是否递归删除）
    // ============================================================
    public void delete(String path, boolean recursive) throws IOException {
        boolean deleted = fs.delete(new Path(path), recursive);
        System.out.printf("[删除] %s -> %s%n", path, deleted ? "成功" : "目标不存在");
    }

    // ============================================================
    // 5. 重命名 / 移动
    // ============================================================
    public void rename(String oldPath, String newPath) throws IOException {
        boolean ok = fs.rename(new Path(oldPath), new Path(newPath));
        System.out.printf("[重命名] %s -> %s : %s%n", oldPath, newPath, ok ? "成功" : "失败");
    }

    // ============================================================
    // 6. 遍历目录，打印文件详情
    // ============================================================
    public void listFiles(String path) throws IOException {
        FileStatus[] statuses = fs.listStatus(new Path(path));
        System.out.println("[遍历目录] " + path + " 共 " + statuses.length + " 项");
        for (FileStatus st : statuses) {
            System.out.printf("    %s  权限=%s  副本=%d  大小=%d  属主=%s%n",
                    st.getPath().getName(),
                    st.getPermission(),
                    st.getReplication(),
                    st.getLen(),
                    st.getOwner());
        }
    }

    // ============================================================
    // 7. 读取文件内容
    // ============================================================
    public void cat(String path) throws IOException {
        System.out.println("[读取内容] " + path);
        try (FSDataInputStream in = fs.open(new Path(path))) {
            // 方式一：利用 IOUtils 拷贝到标准输出
            IOUtils.copyBytes(in, System.out, 4096, false);
            System.out.println();
        }
    }

    // ============================================================
    // 8. 获取文件/目录详情
    // ============================================================
    public void fileDetail(String path) throws IOException {
        Path p = new Path(path);
        if (!fs.exists(p)) {
            System.out.println("[详情] " + path + " 不存在");
            return;
        }
        FileStatus st = fs.getFileStatus(p);
        System.out.printf("[详情] %s | 目录=%s | 文件=%s | 大小=%d 字节 | 修改时间=%d%n",
                path,
                fs.isDirectory(p),
                fs.isFile(p),
                st.getLen(),
                st.getModificationTime());
    }

    // ============================================================
    // 9. 直接写入文件（不经过本地）
    // ============================================================
    public void write(String path, String content) throws IOException {
        try (FSDataOutputStream out = fs.create(new Path(path), true)) {
            out.write(content.getBytes("UTF-8"));
        }
        System.out.printf("[写入文件] %s 完成%n", path);
    }

    // ============================================================
    // 10. 追加内容（HDFS 支持 append，但并非所有场景都建议使用）
    // ============================================================
    public void append(String path, String content) throws IOException {
        try (FSDataOutputStream out = fs.append(new Path(path))) {
            out.write(content.getBytes("UTF-8"));
        }
        System.out.printf("[追加写入] %s 完成%n", path);
    }

    public void close() throws IOException {
        fs.close();
        System.out.println("[关闭] FileSystem 已释放");
    }

    // ============================================================
    // 演示入口
    // ============================================================
    public static void main(String[] args) {
        HdfsClient client = null;
        try {
            client = new HdfsClient();

            System.out.println("\n==================== HDFS Java API 演示 ====================");

            // 1. 创建目录
            client.mkdirs("/api-test");

            // 2. 直接写入文件
            client.write("/api-test/hello.txt", "Hello HDFS\n第二行内容\n");

            // 3. 追加内容
            client.append("/api-test/hello.txt", "追加的一行\n");

            // 4. 读取内容
            client.cat("/api-test/hello.txt");

            // 5. 查看详情
            client.fileDetail("/api-test/hello.txt");

            // 6. 遍历目录
            client.listFiles("/api-test");

            // 7. 重命名
            client.rename("/api-test/hello.txt", "/api-test/hello-renamed.txt");

            // 8. 遍历确认改名成功
            client.listFiles("/api-test");

            // 9. 清理（保留目录，删掉测试文件）
            client.delete("/api-test/hello-renamed.txt", false);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (client != null) {
                try {
                    client.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
