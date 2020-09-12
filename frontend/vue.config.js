const path = require("path");

module.exports = {
  lintOnSave: false,
  devServer: {
    overlay: {
      warnings: true,
      errors: true,
    },
    proxy: {
      "/api": {
        target: "http://loclahost:4000/api",
        ws: false,
        changeOrigin: true,
      },
      "/playground": {
        target: "http://localhost:3000/playground",
      },
    },
  },
  outputDir: path.resolve(__dirname, "build"),
  configureWebpack: {
    module: {
      rules: [
        {
          test: /\.(graphql|gql)$/,
          loader: "graphql-tag/loader",
        },
      ],
    },
  },
};
