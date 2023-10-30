const { environment } = require('@rails/shakapacker')
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
        Popper: ['popper.js', 'default'],
        Rails: 'rails-ujs'
    })
)


module.exports = environment
