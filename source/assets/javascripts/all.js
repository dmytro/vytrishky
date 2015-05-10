/*

*= require jquery.min
*= require bootstrap.min
*= require jquery.fancybox
*= require clean-blog.min

*/

$(document).ready(function() {
    $(document).ready(function() {
		$(".fancybox").fancybox({
            padding    : 0,
            margin     : 10,
            nextEffect : 'fade',
            prevEffect : 'none',
            autoCenter : false,
            afterLoad  : function () {
                $.extend(this, {
                    aspectRatio : false,
                    type    : 'html',
                    width   : '100%',
                    height  : '100%',
                    content : '<div class="fancybox-image" style="background-image:url(' + this.href + '); background-size: cover; background-position:50% 50%;background-repeat:no-repeat;height:100%;width:100%;" /></div>'
            });
            }
        })
	});

});
