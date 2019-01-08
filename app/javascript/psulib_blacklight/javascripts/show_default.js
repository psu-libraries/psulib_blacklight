$(document).ready(function() {
    //link highlighting of hierarchy
    $(".search-subject").hover(
        function () {
            $(this).prevAll().addClass("field-hierarchy");
        },
        function () {
            $(this).prevAll().removeClass("field-hierarchy");
        }
    );
});