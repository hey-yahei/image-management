# -*-coding:utf-8-*-

from bottle import route, run, template, static_file, request
from utils.image import get_all_images, image_match
from im2txt.inference import Inferencer
import os
import jieba
import json
from time import time

# 参数设置
CHECKPOINT_PATH = "im2txt/model/model.ckpt-385634"
VOCAB_FILE = "im2txt/model/word_counts.txt"
IMAGES_DIR = "images/"
JSON_FILE = IMAGES_DIR + "image_info.json"

# 创建描述生成对象待用
infer = Inferencer(
    ckpt_path=CHECKPOINT_PATH,
    vocab_file=VOCAB_FILE
)

# ============== 静态资源路径映射 ==========
# 图片资源
@route("/images/<filename>")
def static_images(filename):
    return static_file(filename, root='images/')
# js资源
@route("/js/<filename>")
def static_js(filename):
    return static_file(filename, root='js/')
# css资源
@route("/css/<filename>")
def static_css(filename):
    return static_file(filename, root='css/')


# ============== 主页 ==========
@route("/")
def index():
    return template("templates/index.tpl")


# ============== 图片相关url ==========
# 更新图片区域的所有图片（以及描述）
@route("/update_images")
def update_images():
    images = get_all_images(IMAGES_DIR)
    return template("templates/images_area.tpl", images=images)
# 响应“添加图片”按钮
@route("/add_images", method="post")
def add_images():
    upload_files = request.files.getall('data')
    for image in upload_files:
        # print("add_images", image.filename)
        if image.filename not in os.listdir(IMAGES_DIR):
            image.save(IMAGES_DIR + image.filename)
    return """
            <script language="javascript" type="text/javascript">
                window.top.window.stopUpload();
            </script>   
            """
# 响应“删除图片”按钮
@route("/delete_image", method='post')
def delete_image():
    name = os.path.basename(request.forms.name)
    # print("delete", name)
    os.remove(IMAGES_DIR + name)

    return ""



# ============== 描述相关url ==========
# 响应“生成描述”按钮
@route("/generate_caption")
def generate_caption():
    t = time()

    images = get_all_images(IMAGES_DIR)
    imgs2handle = [ img.name for img in images if img.caption == '<未处理>']

    # print(imgs2handle)
    infer.inference(input_dir=IMAGES_DIR, files_list=imgs2handle)
    infer.write2json(JSON_FILE, overwrite=False)

    return str(time() - t)
# 响应“清空描述”按钮
@route("/clear_caption")
def clear_caption():
    try:
        os.remove(JSON_FILE)
    except:
        pass

    return ""
# 获取标记状态（用于右上角的“未标记/总数”显示）
@route("/caption_state")
def caption_state():
    counter = 0
    images = get_all_images(IMAGES_DIR)
    for img in images:
        if img.caption == '<未处理>':
            counter += 1

    return json.dumps({'unlabel': counter, 'total': len(images)})
# 响应“修改描述”按钮
@route("/modify_caption", method='post')
def modify_caption():
    name = os.path.basename(request.forms.name)
    new_caption = request.forms.new_caption

    if not os.path.exists(JSON_FILE):
        with open(JSON_FILE, 'w') as f:
            f.write( json.dumps({"name" : name, "caption": new_caption}, sort_keys=True, indent=4, separators=(',', ': ')) )
    else:
        with open(JSON_FILE, 'r') as f:
            old_data = json.loads( f.read() )
            old_data[name] = new_caption
        with open(JSON_FILE, 'w') as f:
            f.write( json.dumps(old_data, sort_keys=True, indent=4, separators=(',', ': ')) )

    return ""


# ===================== 搜索url ###################
# 搜索前的预处理，用jieba对搜索内容进行分词
@route("/cut_words", method='post')
def cut_words():
    words = request.forms.search_input.strip()
    words = " ".join( jieba.cut(words) )
    # print(words)
    return words
# 实际的搜索
@route("/search", method='post')
def search():
    search_content = request.forms.search_input.strip()

    images = get_all_images(IMAGES_DIR)
    if search_content != '':
        search_keys = search_content.split(" ")
        # print(list(search_keys))
        images = [img for img in images if image_match(img.caption, search_keys)]

    return template("templates/images_area.tpl", images=images)


run(host="localhost", port=8080, debug=True)