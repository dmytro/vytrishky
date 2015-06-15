/*

 *= require jquery.min
 *= require bootstrap.min
 *= require jquery.fancybox
 *= require clean-blog.min
 *= require jquery.easing.min
 *= require jquery.scrollstop
 *= require jquery.scrollsnap
 *= require video_matte

 */

$(document).ready(function() {

    $(document).scrollsnap({
        snaps: '.snap',
        proximity: 200,
        latency: 1000
    });
    $('[data-toggle="tooltip"]').tooltip();

	$(".fancybox")
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
