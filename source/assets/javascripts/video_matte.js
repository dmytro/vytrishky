$('video.bgvid').on('play', function () {
    var inner = $(this);
    var width = inner.offset().left;

    var idx = $(this).index();

    if (width > 0) {

        var outer = inner.parent();
        var lft = "bgvid-l-" + idx;
        var rgt = "bgvid-r-" + idx;
        outer.append("<div id='"+ lft +"'>");
        outer.append("<div id='"+ rgt +"'>");

        var css = {
            position: 'absolute',
            top: 0,
            height: inner.height(),
            width: width,
            "background-color": "#666"
        };

        $("#" + lft).css(css).css({left: 0});
        $("#" + rgt).css(css).css({right: 0});
    }

});

$('video').on('ended', function () {
    this.load();
    this.play();
});
