const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

// const customConfig = require('./custom')

// Set nested object prop using path notation
// environment.config.set('resolve.extensions', ['.foo', '.bar'])
// environment.config.set('output.filename', '[name].js')
// Merge custom config
// environment.config.merge(customConfig)


environment.plugins.prepend(
    'Provide',
    new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        jquery: 'jquery',
        'window.jQuery': 'jquery',
        Popper: ['popper.js', 'default'],
    })
)


module.exports = environment
