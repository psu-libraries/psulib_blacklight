import './show_default';
import './google_preview';
import './a11y_advanced_search';

// Otherwise bootstrap-select won't fire on turbolinked clicks to Advance Search
$(document).on('turbolinks:load', () => {
  $(window).trigger('load.bs.select.data-api');
});
