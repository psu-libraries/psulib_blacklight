import './images'
import './styles/app';
// Vendor
require('twitter-typeahead-rails/vendor/assets/javascripts/twitter/typeahead/typeahead.bundle');
require('popper.js/dist/umd/popper');
require('bootstrap/dist/js/bootstrap');

import Turbolinks from 'turbolinks'
Turbolinks.start()

// Local
require('blacklight-frontend/app/javascript/blacklight/core')
require('blacklight-frontend/app/javascript/blacklight/autocomplete')
require('blacklight-frontend/app/javascript/blacklight/checkbox_submit')
require('blacklight-frontend/app/javascript/blacklight/modal')
require('blacklight-frontend/app/javascript/blacklight/bookmark_toggle')
require('blacklight-frontend/app/javascript/blacklight/collapsable')
require('blacklight-frontend/app/javascript/blacklight/facet_load')
require('blacklight-frontend/app/javascript/blacklight/search_context')
// doing the above rather than require('blacklight-frontend/app/assets/javascripts/blacklight/blacklight')
// each script may have an import it's doing
// also, you need to use the code for core from:
// https://raw.githubusercontent.com/projectblacklight/blacklight/6a40c2e6065bcaf5e9dbe7f87d7b034e892e6dae/app/javascript/blacklight/core.js


// Removed from _home_text.html.erb
Blacklight.onLoad(function() {
    $('#about .card-header').one('click', function() {
        $($(this).data('target')).load($(this).find('a').attr('href'));
    });
});