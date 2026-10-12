import CheckboxSubmitAll from './checkbox_submit_all';

document.addEventListener('turbo:load', function () {
  const bookmarkAllButton = $('#bookmark-all');
  bookmarkAllButton.on('click', (event) => {
    const bookmarkCheckboxes = $('form[data-absent="Bookmark"]');

    new CheckboxSubmitAll(bookmarkCheckboxes).clicked(event);
  });
});
