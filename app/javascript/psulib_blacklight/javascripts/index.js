import './show_default';

// Otherwise bootstrap-select won't fire on turbolinked clicks to Advance Search
$(document).on('turbolinks:load', () => {
  $(window).trigger('load.bs.select.data-api');
});
