$(document).ready(() => {
  // link highlighting of hierarchy
  $('.search-subject').hover(
    function () {
      $(this).prevAll().addClass('field-hierarchy');
    },
    function () {
      $(this).prevAll().removeClass('field-hierarchy');
    }
  );

  // Align rtl text properly
  $('article').each(function () {
    const titleLink = this.querySelector('.index_title').querySelector('a');
    titleLink.setAttribute('dir', 'auto');
    if (getComputedStyle(titleLink).direction === 'rtl') {
      titleLink.setAttribute(
        'class',
        'float-right text-align-start col-sm-11 p-0 pr-4'
      );
    }
  });
});
