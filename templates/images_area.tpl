<!-- 动态生成图片区域 -->
% for i, img in enumerate(images):
    % if i % 4 == 0:
        <div class="row">
    % end
    
    <div class="col-md-3 thumbnail" data-toggle="modal" data-target="#my_modal">
        <img src="/images/{{ img.name }}" class="img-responsive" data-toggle="tooltip" data-placement="bottom" title="{{ img.caption.replace(" ","") }}">
    </div>

    % if i % 4 == 3:
        </div>
    % end
% end

<script type="text/javascript">
    // 初始化“工具提示”插件，即鼠标悬停图片后在图片下方显示描述
    $(function () {
        $('[data-toggle="tooltip"]').tooltip();
    });

    // 点击图片后触发该函数：显示模态框（图片详情）
    $('.img-responsive').click( function(){
        $('#modal_image').attr( 'src', $(this).attr("src") );
        $('#modal_input').val( $(this).attr("data-original-title") );
        $('#modal_input').attr( "readonly", "readonly" );
        
        $("#modal_msg_div").css("display", "none");
        $("#modal_confirm_div").css("display", "none");
        $('#modal_image_div').css('display', 'inline');
    });
</script>