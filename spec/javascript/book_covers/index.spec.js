import bookCovers from '../../../app/javascript/book_covers';

describe('bookCovers', () => {
  it('can parse and format bibkeys', () => {
    // Mocking html expected from Ruby code - code that is tested by rspec at catalog_helper.spec.rb
    document.body.innerHTML = '<span class="fas fa-responsive-sizing faspsu-proceeding-congress" '
           + '    data-isbn="[&quot;3801210022&quot;]" '
           + '    data-oclc="[&quot;8151989&quot;]" '
           + '    data-lccn="[&quot;62022109&quot;]" '
           + '    data-type="bibkeys">'
           + '</span>';

    expect(bookCovers.getBibkeys()).toMatch('OCLC:8151989,ISBN:3801210022,LCCN:62022109');
  });

  it('replaces HTML with book covers from Google Books', () => {
    const response = {
      'ISBN:9780972658355': {
        bib_key: 'ISBN:9780972658355',
        info_url: 'https://books.google'
               + '.com/books?id=EPJVAAAACAAJ\u0026source=gbs_ViewAPI',
        preview_url: 'https://books.google'
               + '.com/books?id=EPJVAAAACAAJ\u0026source=gbs_ViewAPI',
        thumbnail_url: 'https://books.google'
               + '.com/books/content?id=EPJVAAAACAAJ\u0026printsec=frontcover\u0026img=1\u0026zoom=5',
        preview: 'noview',
        embeddable: false,
        can_download_pdf: false,
        can_download_epub: false,
        is_pdf_drm_enabled: false,
        is_epub_drm_enabled: false,
      },
    };
    const replaceWith = jest.fn();
    const jQuery = jest.fn(() => ({
      replaceWith,
    }));

    bookCovers.parseXhrGoogleResponse(response, jQuery);

    expect(replaceWith.mock.calls.length).toBe(1);
  });
});
