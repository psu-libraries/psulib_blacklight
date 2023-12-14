import CheckboxSubmitAll from './checkbox_submit_all';

$(document).ready(() => {
  let bookmarkAllButton = $('#bookmark-all');
  bookmarkAllButton.on("click", function () {
    let bookmarkCheckboxes = $('form[data-absent="Bookmark"]');

    new CheckboxSubmitAll(bookmarkCheckboxes).clicked();
  });
});
