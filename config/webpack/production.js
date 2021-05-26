/* eslint-env node */

process.env.NODE_ENV = process.env.NODE_ENV || 'production';

const environment = require('./environment');

module.exports = environment.toWebpackConfig(environment);
// module.exports = environment.toWebpackConfig();

// const { webpackConfig, merge } = require('@rails/webpacker')
// const customConfig = require('./custom')

// module.exports = merge(webpackConfig, customConfig)
