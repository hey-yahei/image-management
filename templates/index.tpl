<html>
    <head>
        <meta charset="utf-8">
        <title>毕设</title>

        <!-- Bootstrap 核心 CSS 文件 -->
        <link rel="stylesheet" href="/css/bootstrap.min.css">
        <!-- Bootstrap 主题文件（一般不用引入） -->
        <link rel="stylesheet" href="/css/bootstrap-theme.min.css">
        <!-- Bootstrap 核心 JavaScript 文件，jquery文件 -->
        <script src="/js/jquery.js"></script>
        <script src="/js/bootstrap.min.js"></script>
    </head>
    
    <body>
        <!-- 模态框 -->
        <div class="modal fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" id='my_modal'>
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <!-- 用于显示图片详情的模态框 -->
                    <div id="modal_image_div" style="display:none; ">
                        <img src="" id="modal_image" style="width:100%"><!--ajax动态加载-->
                        <form style="margin: 5%">
                            <div class="form-group">
                                <label for="modal_input">描述：</label>
                                <input type="text" class="form-control" id="modal_input" name="modal_input" readonly="readonly"><!--ajax动态加载-->
                            </div>
                        </form>
                        <div class='text-center' style="margin-bottom: 5%">
                            <button type="button" class="btn btn-success" id='modify_caption' onclick="modify_caption()">修改描述</button>
                            <button type="button" class="btn btn-danger" id='delete_image' onclick="delete_image()">删除图片</button>
                        </div>
                    </div>

                    <!-- 用于显示确认框的的模态框 -->
                    <div id='modal_confirm_div' style="display: none">
                        <div class="modal-body"><p id="confirm_content"><!--ajax动态加载--></p></div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                            <button type="button" class="btn btn-primary" onclick="confirm_ok()">确认</button>
                        </div>
                    </div>

                    <!-- 用于显示消息框的模态框 -->
                    <div id="modal_msg_div" style="display: none">
                        <div class="modal-body"><p id="modal_msg"><!--ajax动态加载--></p></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- bootstrap栅格系统 -->
        <div class="container">
            <!-- 标题行 -->
            <div class="row" style="margin-top:3%; margin-bottom: 3%">
                <div class="text-center">
                    <h1>图片描述与归档</h1>
                </div>
            </div>

            <!-- 操作栏、信息栏 -->
            <div class="row">
                <!-- 搜索栏 -->
                <div class="col-md-4">
                    <input id="search_input" name="search_input" type="text" class="form-control" placeholder="搜索">
                </div>

                <!-- 按钮部分 -->
                <div class="col-md-1">
                    <form method="post" id='file_upload' action='/add_images' enctype="multipart/form-data" target="upload_target">
                        <input id='file_input' name='data' type="file" multiple="multiple" style="display: none"/>
                        <button type="button" class="btn btn-primary" id='add_images' onclick="document.getElementById('file_input').click()">添加图片</button>
                    </form>
                    <iframe id="upload_target" name="upload_target" src"#" style="display: none"></iframe>
                </div>
                <div class="col-md-1">
                    <button type="button" class="btn btn-success" id='generate_caption' onclick="generate_caption()">生成描述</button>
                </div>
                <div class="col-md-1">
                    <button type="button" class="btn btn-danger" id='clear_caption' onclick="clear_caption()">清空描述</button>
                </div>

                <!-- 状态栏 -->
                <div class="col-md-offset-3 col-md-2 text-center">
                    <div class='row'>
                        未标记 / 总数
                    </div>
                    <span class="label label-warning" id='state_unlabel'></span> /
                    <span class="label label-primary" id='state_total'></span>
                </div>
            </div>

            <!-- 图片展示区域 -->
            <div style="overflow:scroll; height:70%; overflow-x:hidden" id='images_area'><!--ajax动态加载，模板文件：images_area.tpl--></div>
        </div>

        <!-- 自定义js部分 -->
        <script type="text/javascript">
            // 模态框 - 确认框相关----------->
            var confirm_callback = null;    // 暂存点击“确认”后的回调函数

            // 辅助函数：显示确认框
            function show_confirm_dialog(content, callback){
                // 显示模态框，写入信息
                $(".modal").modal("show");
                $("#confirm_content").text(content);
                // 只保留确认框
                $("#modal_msg_div").css("display", "none");
                $("#modal_image_div").css("display", "none");
                $("#modal_confirm_div").css("display", "inline");
                // 暂存回调函数，等待“确认”
                confirm_callback = callback;
            }

            // 模态框 - 确认框 - “确认”按钮的触发函数
            function confirm_ok(){                
                // 调用回调函数
                confirm_callback();
            }
            // <-------------------模态框 - 确认框相关

            // “添加图片”完成后触发该函数
            function stopUpload(){
                alert("完成图片添加");
                $('#images_area').load('/update_images');
                update_state();
            }

            // 点击“生成描述”后触发该函数
            function generate_caption(){
                show_confirm_dialog(
                    "确认为未标记的 " + $('#state_unlabel').text() + " 张图片生成描述？",
                    function(){
                        $("#modal_confirm_div").css("display", "none");
                        $("#modal_msg").text("正在生成描述......");
                        $("#modal_msg_div").css("display", "inline");

                        $.get(
                            '/generate_caption',
                            function(result){
                                alert("描述生成完毕~\n用时：" + result + " 秒");
                                $(".modal").modal('hide');
                                $('#images_area').load('/update_images');
                                update_state();
                            }
                        );
                    }
                );
            }

            // 点击“清空描述”后触发该函数
            function clear_caption(){
                show_confirm_dialog(
                    "确认清空所有描述？",
                    function(){
                        $.get(
                            '/clear_caption',
                            function(result){
                                alert("已清空所有描述");
                                $(".modal").modal('hide');
                                $('#images_area').load('/update_images');
                                update_state();
                            }
                        );
                    }
                );
            }

            // 辅助函数：刷新状态栏的“未标记/总数”
            function update_state(){
                $.getJSON(
                    '/caption_state',
                    function(result){
                        // console.log(result);
                        $('#state_unlabel').text(result['unlabel']);
                        $('#state_total').text(result['total']);
                    }
                )
            }

            // 点击“修改描述”后触发该函数
            function modify_caption(){
                show_confirm_dialog(
                    "确认修改描述？",
                    function(){
                        $.post(
                            '/modify_caption',
                            {
                                "name" : $('#modal_image').attr('src'),
                                "new_caption" : $('#modal_input').val()
                            },
                            function(result){
                                $(".modal").modal('hide');
                                $('#images_area').load('/update_images');
                            }
                        );
                    }
                );
            }

            // 点击“删除图片”后触发该函数
            function delete_image(){
                show_confirm_dialog(
                    "确认删除图片？",
                    function(){
                        $.post(
                            '/delete_image',
                            {'name': $('#modal_image').attr('src')},
                            function(result){
                                $(".modal").modal('hide');
                                $('#images_area').load('/update_images');
                                update_state();
                            }
                        )
                    }
                );
            }
        </script>

        <script type="text/javascript">
            // 页面初始化：刷新图片区域、状态栏
            $(document).ready(function(){
                $('#images_area').load('/update_images');
                update_state();
            });

            // 双击图片详情的描述输入框，激活输入框的输入功能
            $('#modal_input').dblclick( function(){
                $(this).removeAttr("readonly");
            });

            // 点击“添加图片”，选择好文件后触发该函数
            $('#file_input').change( function(){
                console.log("upload file");
                $('form#file_upload').submit();
            });

            // 在搜索栏敲击键盘触发该函数，只响应回车键
            $('#search_input').keydown(function(e){
                if( e.keyCode == 13 ){   // 回车
                    $.post(
                        '/cut_words',
                        {"search_input" : $(this).val()},
                        function(result){
                            $('#search_input').val(result);     // 奇了怪，$(this).val(result)不行？

                            $.post(
                                '/search',
                                {"search_input" : result},
                                function(result){
                                    $("#images_area").html(result);
                                }
                            );
                        }
                    );
                }
            });
        </script>
    </body>
</html>