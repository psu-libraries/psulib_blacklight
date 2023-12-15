import CheckboxSubmitAll from './checkbox_submit_all';

$(document).ready(() => {
  const bookmarkAllButton = $('#bookmark-all');
  bookmarkAllButton.on('click', () => {
    const bookmarkCheckboxes = $('form[data-absent="Bookmark"]');

    new CheckboxSubmitAll(bookmarkCheckboxes).clicked();
  });
});
