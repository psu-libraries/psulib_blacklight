$(document).on('turbolinks:load', function() {
    var isbns_prefixed = [];

    $("[data-type='isbn']").each(function(index, thumbnail) {
        var isbn_values = $(thumbnail).data('isbn');

        if (isbn_values) {
            isbns_prefixed.push(isbn_values.map(isbn => "ISBN:" + isbn));
        }
    });

    $.ajax(
        {
            url: "https://books.google.com/books?jscmd=viewapi&bibkeys=" + isbns_prefixed.join(),
            dataType: "jsonp",
            jsonp: "callback"
        }
    ).done(
        function(response) {
            for (var isbn in response) {
                response_item = response[isbn];

                if (response_item.hasOwnProperty("thumbnail_url")) {
                    var type = response_item.bib_key.split(":")[0];
                    var identifier = response_item.bib_key.split(":")[1];
                    var thumb_url_zoom_1 = response_item.thumbnail_url.slice(0,-1) + "1"; // instead of zoom of 5
                    $('[data-' + type.toLowerCase() + '*="' + identifier + '"]')
                        .replaceWith(`<img src="${thumb_url_zoom_1}">`);
                }
            }
        }
    )
});