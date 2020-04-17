

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

            // Order of data is important, as we learned in INC1422412. OCLC first will render the
            // correct book cover, ISBN will render the wrong one. The issue was for the record with
            // OCLC:951360498 and ISBN:9788851117283.
            if (oclc_values) {
                bibkeys_prefixed.push(oclc_values.map(oclc => "OCLC:" + oclc));
            }
            if (isbn_values) {
                bibkeys_prefixed.push(isbn_values.map(isbn => "ISBN:" + isbn));
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
            bookCovers.parseXhrGoogleResponse(response, $);
        }).fail(function( jqXHR, textStatus) {
            console.log(jqXHR, textStatus, 'bookCovers');
        });
    },

    parseXhrGoogleResponse(response, $) {
        for (let bibkey in response) {
            let response_item = response[bibkey];

            if (Object.prototype.hasOwnProperty.call(response_item, "thumbnail_url")) {
                let type = response_item.bib_key.split(":")[0];
                let identifier = response_item.bib_key.split(":")[1];
                // instead of zoom of 5
                let thumb_url_zoom_1 = response_item.thumbnail_url.slice(0,-1) + "1";
                $('[data-' + type.toLowerCase() + '*="' + identifier + '"]')
                    .replaceWith(`<img class="img-fluid" src="${thumb_url_zoom_1}">`);
            }
        }
    }
};


export default bookCovers;