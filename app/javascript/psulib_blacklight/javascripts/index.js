import './show_default';
import './availability';

// Otherwise bootstrap-select won't fire on turbolinked clicks to Advance Search
$(document).on('turbolinks:load', function() {
    $(window).trigger('load.bs.select.data-api');
});
