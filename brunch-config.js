exports.config = {
  files: {
    javascripts: {
      joinTo: {
        "js/app.js": /^(web\/static\/js|node_modules)/,
        "js/vendor.js": /^(web\/static\/vendor|deps)/
      },
      order: {
        before: [
          "web/static/vendor/js/jquery-2.2.4.min.js"
        ]
      }
    },
    stylesheets: {
      joinTo: "css/app.css",
      order: {
        after: ["web/static/css/app.css"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    elmBrunch: {
      mainModules: ['web/static/elm/Online.elm'],
      outputFolder: 'web/static/vendor',
      makeParameters: ['--debug']
    },
    sass: {
      options: {
        includePaths: [
          'node_modules/bootstrap/scss/',
          'node_modules/font-awesome/scss/'
        ]
      }
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    enabled: true
  }
};
