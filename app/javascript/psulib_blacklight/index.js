// Load in all the PSU Libraries Blacklight core customizations
import './images'
import './styles'
import './javascripts'

// Vendor
import 'popper.js/dist/umd/popper'
import 'bootstrap/dist/js/bootstrap'
import 'bootstrap-select/dist/css/bootstrap-select'
import 'bootstrap-select/dist/js/bootstrap-select'

// Fonts
import 'typeface-open-sans'
import 'typeface-roboto-slab'

// Blacklight Upstream Over-rides
// doing the above rather than require('blacklight-frontend/app/assets/javascripts/blacklight/blacklight')
import 'blacklight-frontend/app/javascript/blacklight/core'
import 'blacklight-frontend/app/javascript/blacklight/checkbox_submit'
import 'blacklight-frontend/app/javascript/blacklight/modal'
import 'blacklight-frontend/app/javascript/blacklight/bookmark_toggle'
import 'blacklight-frontend/app/javascript/blacklight/collapsable'
import 'blacklight-frontend/app/javascript/blacklight/facet_load'
import 'blacklight-frontend/app/javascript/blacklight/search_context'