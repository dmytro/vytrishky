/*

 *= require jquery.min
 *= require bootstrap.min
 *= require jquery.fancybox
 *= require clean-blog.min

 */

$(document).ready(function() {
	$(".fancybox")
        .attr('rel', 'gallery')
        .fancybox({
            padding    : 5,
            margin     : 0,
            nextEffect : 'fade',
            prevEffect : 'none',
            autoCenter : false,
            afterLoad  : function () {
                $.extend(this, {
                    aspectRatio : false,
                    type    : 'html',
                    width   : '97%',
                    height  : '97%',
                    content : '<div class="fancybox-image" style="background-image:url(' + this.href + '); background-size: contain; background-position:50% 50%;background-repeat:no-repeat;height:100%;width:100%;" /></div>'
                });
            }
	})
});
