# 多模态 VisualGLM-6B 使用示例

部署模型：

```sql
!byzerllm setup single;

run command as LLM.`` where 
action="infer"
and pretrainedModelType="custom/visualglm"
and localModelDir="/home/winubuntu/projects/visualglm-6b/visualglm-6b-model"
and udfName="chat"
and modelTable="command";
```

在 Byzer Notebook 上传一张照片，默认会上传在虚拟文件系统 `/tmp/upload` 目录下。
使用如下方式图片：

```sql
load binaryFile.`/tmp/upload/*.JPG` as images;
select base64(content) as image from images as encoded_images;
select image as content, "image" as mime from encoded_images as output;
```

Byzer Notebook 会展示这个第一张图片。


使用模型识别图片并且进行描述：

```sql
select chat(
llm_param(map(
  "instruction","请尽情的描述照片中女子的美丽",
  "image",image
))) from encoded_images as output;
```