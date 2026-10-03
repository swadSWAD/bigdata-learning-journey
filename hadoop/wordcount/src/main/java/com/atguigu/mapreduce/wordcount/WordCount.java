package com.atguigu.mapreduce.wordcount;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;
import java.util.StringTokenizer;

/**
 * MapReduce 经典案例：词频统计
 *
 * 运行方式：
 *   hadoop jar wordcount.jar com.atguigu.mapreduce.wordcount.WordCount /input /output
 *
 * @author 张齐涛
 */
public class WordCount {

    /**
     * Mapper 阶段：把每一行文本切分成单词，每个单词输出一个 (word, 1)
     *
     * 泛型依次为：输入 key、输入 value、输出 key、输出 value
     * 默认输入 key 是行偏移量（Object），value 是一行文本（Text）
     */
    public static class TokenizerMapper extends Mapper<Object, Text, Text, IntWritable> {

        private final static IntWritable one = new IntWritable(1);
        private final Text word = new Text();

        @Override
        public void map(Object key, Text value, Context context)
                throws IOException, InterruptedException {

            StringTokenizer itr = new StringTokenizer(value.toString());
            while (itr.hasMoreTokens()) {
                word.set(itr.nextToken());
                // 每出现一次就输出一个 1，交给 Reduce 汇总
                context.write(word, one);
            }
        }
    }

    /**
     * Reducer 阶段：把相同单词的计数累加
     */
    public static class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

        private final IntWritable result = new IntWritable();

        @Override
        public void reduce(Text key, Iterable<IntWritable> values, Context context)
                throws IOException, InterruptedException {

            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }

    public static void main(String[] args) throws Exception {

        if (args.length < 2) {
            System.err.println("Usage: WordCount <input_path> <output_path>");
            System.exit(-1);
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "word count");

        // 指定主类，用于在集群上定位 jar 包
        job.setJarByClass(WordCount.class);

        // 设置 Mapper 与 Reducer
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);   // Combiner 在 Map 端先做一次局部聚合，减少网络传输
        job.setReducerClass(IntSumReducer.class);

        // 设置输出 key/value 类型
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        // 设置输入输出路径
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        // 提交任务并等待完成
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
