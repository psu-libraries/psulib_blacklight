import './show_default';
import alignRtl from './align_rtl_index';
import './google_preview';
import './a11y_advanced_search';
import './bookmark_all_on_page';

$(document).ready(alignRtl());

// Otherwise bootstrap-select won't fire on turbolinked clicks to Advance Search
$(document).on('turbolinks:load', () => {
  $(window).trigger('load.bs.select.data-api');
});
