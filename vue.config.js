// vue.config.js
/* var nodeExternals = require('webpack-node-externals')
module.exports = {
  configureWebpack: {
    target: 'node', // in order to ignore built-in modules like path, fs, etc.
    externals: [nodeExternals()],
    module: {
      rules: [
        // ... другие правила
        {
          loader: 'babel-loader',
          test: /\.(js)$/,
          exclude: /node_modules/
        }
      ]
    },
    plugins: [

    ]
  }
} */

module.exports = {
  configureWebpack: {
    module: {
      rules: [
        {
          test: /\.js$/,
          loader: 'babel-loader',
          exclude: file => (
            /node_modules/.test(file) &&
            !/\.vue\.js/.test(file)
          )
        }
        /* {
          test: /\.css$/,
          // exclude: /(node_modules|bower_components|build)/,
          use: ['vue-style-loader',
            {
              loader: 'css-loader',
              options: { importLoaders: 1 }
            }
          ]
        } */
      ]
    }
  }
}
