// Load in all the PSU Libraries Blacklight core customizations
import './images';
import './styles/index.scss';
import './javascripts';

// Vendor
import 'bootstrap/dist/js/bootstrap.bundle.min';

// Fonts
import '@fontsource/open-sans';
import '@fontsource/roboto-slab';

// Blacklight Upstream Javascript
// Picking and choosing rather than taking all JS from BL
import 'blacklight-frontend/app/javascript/blacklight/core';
import 'blacklight-frontend/app/javascript/blacklight/checkbox_submit';
import 'blacklight-frontend/app/javascript/blacklight/modal';
import 'blacklight-frontend/app/javascript/blacklight/button_focus';
import 'blacklight-frontend/app/javascript/blacklight/facet_load';
import 'blacklight-frontend/app/javascript/blacklight/search_context';
