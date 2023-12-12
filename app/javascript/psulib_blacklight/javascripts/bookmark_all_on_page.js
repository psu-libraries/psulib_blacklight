import CheckboxSubmit from 'blacklight/checkbox_submit'

$(document).ready(() => {
  let bookmarkAllButton = $('#bookmark-all');
  bookmarkAllButton.on("click", function () {
    let bookmarkCheckboxes = $('[id^=toggle-bookmark_]');

    $.each(bookmarkCheckboxes, function (index, item) {
      item.click() //closest('form')
      //if (form) new CheckboxSubmit(form).clicked(e);
    })
  });
});
