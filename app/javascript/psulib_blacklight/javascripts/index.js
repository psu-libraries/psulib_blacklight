import './show_default';
import alignRtl from './align_rtl_index';
import './a11y_advanced_search';
import './bookmark_all_on_page';
import './set_hathi_google_links';

// Otherwise bootstrap-select won't fire on turbolinked clicks to Advance Search
$(document).on('turbo:load', () => {
  alignRtl();
  $(window).trigger('load.bs.select.data-api');
});
