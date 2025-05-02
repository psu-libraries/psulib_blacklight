import $ from 'jquery';
import bookCovers from '../../../app/javascript/book_covers';

describe('bookCovers', () => {
  const response = {
    'ISBN:9780972658355': {
      bib_key: 'ISBN:9780972658355',
      info_url:
        'https://books.google' +
        '.com/books?id=EPJVAAAACAAJ\u0026source=gbs_ViewAPI',
      preview_url:
        'https://books.google' +
        '.com/books?id=EPJVAAAACAAJ\u0026source=gbs_ViewAPI',
      thumbnail_url:
        'https://books.google' +
        '.com/books/content?id=EPJVAAAACAAJ\u0026printsec=frontcover\u0026img=1\u0026zoom=5',
      preview: 'noview',
      embeddable: false,
      can_download_pdf: false,
      can_download_epub: false,
      is_pdf_drm_enabled: false,
      is_epub_drm_enabled: false,
    },
  };
  beforeEach(() => {
    document.body.innerHTML =
      '<a aria-hidden="true">' +
      ' <span class="fas fa-responsive-sizing faspsu-proceeding-congress" ' +
      '     data-isbn="[&quot;9780972658355&quot;]" ' +
      '     data-title="Test Book &quot;Title&quot;: A Subtitle / Foo Bar" ' +
      '     data-type="bibkeys">' +
      ' </span>' +
      '</a>';
  });

  it('can parse and format bibkeys', () => {
    // Mocking html expected from Ruby code - code that is tested by rspec at catalog_helper.spec.rb
    document.body.innerHTML =
      '<span class="fas fa-responsive-sizing faspsu-proceeding-congress" ' +
      '    data-isbn="[&quot;3801210022&quot;]" ' +
      '    data-oclc="[&quot;8151989&quot;]" ' +
      '    data-lccn="[&quot;62022109&quot;]" ' +
      '    data-type="bibkeys">' +
      '</span>';

    expect(bookCovers.getBibkeys()).toMatch(
      'OCLC:8151989,ISBN:3801210022,LCCN:62022109',
    );
  });

  it('replaces HTML with book covers from Google Books', () => {
    const replaceWith = jest.fn();
    const parent = jest.fn();
    const jQuery = jest.fn((selector) => {
      // Verify the selector is targeting the element with the correct ISBN
      expect(selector).toBe('[data-isbn*="9780972658355"]');
      return {
        length: 1,
        data: (key) =>
          key === 'title' ? 'Test Book Title: A Subtitle / Foo Bar' : null,
        replaceWith,
        parent,
      };
    });

    bookCovers.parseXhrGoogleResponse(response, jQuery);

    expect(replaceWith.mock.calls.length).toBe(1);
  });

  it('formats accessibility attributes correctly', () => {
    bookCovers.parseXhrGoogleResponse(response, $);

    const img = document.querySelector('img');
    expect(img).not.toBeNull();

    const expectedAltText = 'Cover image for Test Book "Title"';
    expect(img.getAttribute('alt')).toBe(expectedAltText);
    expect(img.getAttribute('aria-label')).toBe(expectedAltText);

    const parent = img.parentNode;
    expect(parent).not.toBeNull();
    expect(parent.tagName === 'A').toBe(true);
    expect(parent.getAttribute('aria-hidden')).toBeNull();
  });
});
