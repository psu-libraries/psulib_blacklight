// // See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.

const webpack = require('webpack')
const { generateWebpackConfig } = require('shakapacker')

module.exports = generateWebpackConfig({
  plugins: [
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
    })
  ],
})