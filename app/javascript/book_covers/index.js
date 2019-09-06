

const bookCovers = {
    start() {
        const bibkeys = this.getBibkeys();
        const url = "https://books.google.com/books?jscmd=viewapi&bibkeys=" + bibkeys;
        this.xhrGoogle(url);
    },

    getBibkeys() {
        let bibkeys_prefixed = [];
        document.querySelectorAll("[data-type='bibkeys']").forEach(function(thumbnail) {
            let isbn_values = JSON.parse(thumbnail.dataset.isbn);
            let lccn_values = JSON.parse(thumbnail.dataset.lccn);
            let oclc_values = JSON.parse(thumbnail.dataset.oclc);

            if (isbn_values) {
                bibkeys_prefixed.push(isbn_values.map(isbn => "ISBN:" + isbn));
            }
            if (oclc_values) {
                bibkeys_prefixed.push(oclc_values.map(oclc => "OCLC:" + oclc));
            }
            if (lccn_values) {
                bibkeys_prefixed.push(lccn_values.map(lccn => "LCCN:" + lccn));
            }
        });

        return bibkeys_prefixed.join();
    },

    xhrGoogle(url) {
        $.ajax(
            {
                url: url,
                dataType: "jsonp",
                jsonp: "callback"
            }
        ).done(function(response) {
            for (var bibkey in response) {
                let response_item = response[bibkey];

                if (response_item.hasOwnProperty("thumbnail_url")) {
                    var type = response_item.bib_key.split(":")[0];
                    var identifier = response_item.bib_key.split(":")[1];
                    var thumb_url_zoom_1 = response_item.thumbnail_url.slice(0,-1) + "1"; // instead of zoom of 5
                    $('[data-' + type.toLowerCase() + '*="' + identifier + '"]')
                        .replaceWith(`<img class="img-fluid" src="${thumb_url_zoom_1}">`);
                }
            }
        });
    }
};


export default bookCovers;