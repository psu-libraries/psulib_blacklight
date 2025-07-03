import $ from 'jquery';
import alignRtl from '../../../app/javascript/psulib_blacklight/javascripts/align_rtl_index';

global.$ = $;
global.jQuery = $;

beforeEach(() => {
  document.body.innerHTML = `
  <article data-document-id="123" data-document-counter="4" itemscope="itemscope" itemtype="http://schema.org/Thing" class="blacklight-musical-score document document-position-4">
    <header class="documentHeader row">
      <h3 class="index_title document-title-heading col-sm-9 col-lg-10">
        <span class="document-counter">4.</span>
        <a data-context-href="/catalog/123/track?counter=4&amp;document_id=2123&amp;search_id=106" href="/catalog/123">بعض عناوين الأدب</a>
      </h3>
    </header>
  </article>
  <article data-document-id="124" data-document-counter="4" itemscope="itemscope" itemtype="http://schema.org/Thing" class="blacklight-musical-score document document-position-5">
    <header class="documentHeader row">
      <h3 class="index_title document-title-heading col-sm-9 col-lg-10">
        <span class="document-counter">5.</span>
        <a data-context-href="/catalog/124/track?counter=4&amp;document_id=2124&amp;search_id=107" href="/catalog/124">Some other title</a>
      </h3>
    </header>
  </article>
  `;
});

describe('when catalog index list contains rtl text titles', () => {
  test('Aligns rtl text to the right but does not change ltr text', () => {
    const mockComputedStyleRtl = {
      direction: 'rtl',
    };

    const mockComputedStyleLtr = {
      direction: 'ltr',
    };

    window.getComputedStyle = jest.fn().mockImplementation((element) => {
      if (element == 'http://localhost/catalog/123') {
        return mockComputedStyleRtl;
      }
      return mockComputedStyleLtr;
    });

    alignRtl();
    expect($('a')[0].outerHTML).toBe(
      '<a data-context-href="/catalog/123/track?counter=4&amp;' +
      'document_id=2123&amp;search_id=106" href="/catalog/123' +
      '" dir="auto" class="float-end text-align-start col' +
      '-sm-11 p-0 pr-4">بعض عناوين الأدب</a>'
    );
    expect($('a')[1].outerHTML).toBe(
      '<a data-context-href="/catalog/124/track?counter=4&amp;' +
      'document_id=2124&amp;search_id=107" href="/catalog/124' +
      '" dir="auto">Some other title</a>'
    );
  });
});
