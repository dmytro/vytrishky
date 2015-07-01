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
            padding    : 2,
            margin     : 0,
            nextEffect : 'fade',
            prevEffect : 'none',
            autoCenter : false,
            afterLoad  : function () {
                $.extend(this, {
                    aspectRatio : false,
                    type    : 'html',
                    width   : '100%',
                    height  : '100%',
                    content : '<div class="fancybox-image" style="background-image:url(' + this.href + '); " /></div>'
                });
            }
	    });

    $("#disqus-comments-control").click( function () {
        $("#disqus-comments").toggle("slow");
        $("#disqus-comments-control .fa-caret-down").toggle();
        $("#disqus-comments-control .fa-caret-up").toggle();
    })
    // When user clicks on top link - always show comments.
    $("#disqus-comments-toplink").click( function () {
        $("#disqus-comments").show("slow");
        $("#disqus-comments-control .fa-caret-down").hide();
        $("#disqus-comments-control .fa-caret-up").show();
    })
});
