# -*-coding:utf-8-*-

from collections import namedtuple
import os
import json

Image = namedtuple('Image', ['name', 'caption'])

def get_all_images(dir, json_file='image_info.json', image_type='jpg'):
    '''从指定目录获取所有图片信息'''
    image_info = None
    if os.path.exists(dir+json_file):
        with open(dir+json_file, 'r') as f:
            image_info = json.loads( f.read() )

    image_files = [ i for i in os.listdir(dir) if i.endswith("." + image_type) ]
    images = []
    if image_info:
        for f in image_files:
            caption = image_info.get(f)
            images.append( Image( name=f, caption=(caption or "<未处理>") ) )
    else:
        images = [ Image(name=f, caption="<未处理>") for f in image_files]

    return images

def image_match(caption, search_keys):
    for skey in search_keys:
        if skey in caption:
            return True
    return False