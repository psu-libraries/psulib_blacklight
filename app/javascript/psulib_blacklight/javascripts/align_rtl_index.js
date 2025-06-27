const alignRtl = function () {
  // Align rtl text properly
  $('article').each(function () {
    const titleLink = this.querySelector('.index_title').querySelector('a');
    titleLink.setAttribute('dir', 'auto');
    if (window.getComputedStyle(titleLink).direction === 'rtl') {
      titleLink.setAttribute(
        'class',
        'float-end text-align-start col-sm-11 p-0 pr-4',
      );
    }
  });
};

export default alignRtl;
