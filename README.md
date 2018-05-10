## 基于图片描述的图片管理软件
一个小玩具——    
1. 为图片自动生成一句话描述    
2. 支持手动修改图片对应的描述     
3. 支持通过搜索描述的方式，以文字来检索图片    
4. 支持简单的图片管理，添加图片到图库、从图库中移除图片等         
  
描述生成的模型基于google的im2txt模型；      
数据集来源于AI Challenger；     
  
### 使用说明    
1. 安装python
2. 安装python依赖包    
    ```bash
    pip install -r requirement.txt
    ```
3. 执行server.py文件    
    ```bash
    python server.py
    ```
4. 用浏览器访问地址 `localhost:8080`        