// vue.config.js

module.exports = {
  configureWebpack: {
    module: {
      rules: [
        // ... другие правила
        {
          loader: 'babel-loader',
          test: /\.(js|jsx)$/
        }
      ]
    },
    plugins: [

    ]
  }
}
