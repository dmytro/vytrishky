$('video').on('play', function () {
    var inner = $(this);
    var width = inner.offset().left;

    if (width > 0) {

        var outer = inner.parent();
        outer.append("<div id='bgvid-l'>");
        outer.append("<div id='bgvid-r'>");

        var css = {
            position: 'absolute',
            top: 0,
            height: inner.height(),
            width: width,
            "background-color": "#666"
        };

        $("#bgvid-l").css(css);
        $("#bgvid-r").css(css);

        $("#bgvid-l").css({left: 0});
        $("#bgvid-r").css({right: 0});

    }

});

$('video').on('ended', function () {
    this.load();
    this.play();
});
