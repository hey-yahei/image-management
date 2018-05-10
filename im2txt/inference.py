# -*-coding:utf-8-*-
# Copyright 2016 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
r"""Generate captions for images using default beam search parameters."""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import os
import json

import tensorflow as tf

from im2txt import configuration
from im2txt import inference_wrapper
from im2txt.inference_utils import caption_generator
from im2txt.inference_utils import vocabulary

class Inferencer:
  def __init__(self, ckpt_path, vocab_file):
    self.ckpt_path = ckpt_path
    self.vocab_file = vocab_file
    self.outputs = {}

  def inference(self, input_dir, files_list=[]):
    # 清除outputs
    self.outputs = {}
    # 构建模型
    g = tf.Graph()
    with g.as_default():
      model = inference_wrapper.InferenceWrapper()
      restore_fn = model.build_graph_from_config(configuration.ModelConfig(),
                                                 self.ckpt_path)
    g.finalize()

    # 创建字典
    vocab = vocabulary.Vocabulary(self.vocab_file)

    # 筛选待生成描述的文件
    filenames = []
    if files_list == []:    # 如果没有指定文件，则对所有图片生成描述
      files_list = os.listdir(input_dir)
      files_list = [f for f in files_list if f.endswith(".jpg")]

    # 获取图片完整路径
    for filename in files_list:
      full_name = os.path.join(input_dir, filename)
      filenames.append(full_name)


    with tf.Session(graph=g) as sess:
      # 从checkpoint读取参数
      restore_fn(sess)

      # 创建描述生成器
      generator = caption_generator.CaptionGenerator(model, vocab)

      # 逐一生成描述
      for filename in filenames:
        # 读取图片
        with tf.gfile.GFile(filename, "rb") as f:
          image = f.read()
        # 搜索描述
        captions = generator.beam_search(sess, image)
        # print("Captions for image %s:" % os.path.basename(filename))
        # 去除语句的开头标志和结尾标志
        sentence = [vocab.id_to_word(w) for w in captions[0].sentence[1:-1]]
        # 将结果添加到输出的字典中
        self.outputs[os.path.basename(filename)] = "".join(sentence)

  def write2json(self, output_file, overwrite=True):
    if overwrite or not os.path.exists(output_file):
      # 如果开启overwrite或目录下没有相应的json文件，则写入一个新文件
      outputs = self.outputs
    else:
      # 如果打开了overwrite且存在json文件，则在原json数据的基础上追加
      with open(output_file, "r") as f:
        old_data = json.loads( f.read() )
      outputs = {**old_data, **self.outputs}
      # print(outputs)

    # 写入文件
    with tf.gfile.GFile(output_file, 'w') as f:
      f.write( json.dumps(outputs, sort_keys=True, indent=4, separators=(',', ': ')) )