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


// Find all YouTube videos
var $allVideos = $("iframe[src^='//www.youtube.com']"),

    // The element that is fluid width
    $fluidEl = $("body");

// Figure out and save aspect ratio for each video
$allVideos.each(function() {

  $(this)
    .data('aspectRatio', this.height / this.width)

    // and remove the hard coded width/height
    .removeAttr('height')
    .removeAttr('width');

});

// When the window is resized
$(window).resize(function() {

  var newWidth = $fluidEl.width();

  // Resize all videos according to their own aspect ratio
  $allVideos.each(function() {

    var $el = $(this);
    $el
      .width(newWidth)
      .height(newWidth * $el.data('aspectRatio'));

  });

// Kick off one resize to fix all videos on page load
}).resize();
