const bookCovers = {
  start() {
    const bibkeys = this.getBibkeys();
    const url = `https://books.google.com/books?jscmd=viewapi&bibkeys=${bibkeys}`;
    this.xhrGoogle(url);
  },

  getBibkeys() {
    const bibkeysPrefixed = [];
    document.querySelectorAll("[data-type='bibkeys']").forEach((thumbnail) => {
      const isbnValues = JSON.parse(thumbnail.dataset.isbn);
      const lccnValues = JSON.parse(thumbnail.dataset.lccn);
      const oclcValues = JSON.parse(thumbnail.dataset.oclc);

      // Order of data is important, as we learned in INC1422412. OCLC first will render the
      // correct book cover, ISBN will render the wrong one. The issue was for the record with
      // OCLC:951360498 and ISBN:9788851117283.
      if (oclcValues) {
        bibkeysPrefixed.push(oclcValues.map((oclc) => `OCLC:${oclc}`));
      }
      if (isbnValues) {
        bibkeysPrefixed.push(isbnValues.map((isbn) => `ISBN:${isbn}`));
      }
      if (lccnValues) {
        bibkeysPrefixed.push(lccnValues.map((lccn) => `LCCN:${lccn}`));
      }
    });

    return bibkeysPrefixed.join();
  },

  xhrGoogle(url) {
    $.ajax({
      url,
      dataType: 'jsonp',
      jsonp: 'callback',
    })
      .done((response) => {
        bookCovers.parseXhrGoogleResponse(response, $);
      })
      .fail((jqXHR, textStatus) => {
        console.log(jqXHR, textStatus, 'bookCovers');
      });
  },

  parseXhrGoogleResponse(response, $) {
    for (const bibkey in response) {
      const responseItem = response[bibkey];

      if (Object.prototype.hasOwnProperty.call(responseItem, 'thumbnail_url')) {
        const type = responseItem.bib_key.split(':')[0];
        const identifier = responseItem.bib_key.split(':')[1];
        // instead of zoom of 5
        const thumbUrlZoom1 = `${responseItem.thumbnail_url.slice(0, -1)}1`;
        $(`[data-${type.toLowerCase()}*="${identifier}"]`).replaceWith(
          `<img class="img-fluid" src="${thumbUrlZoom1}">`,
        );
      }
    }
  },
};

export default bookCovers;
