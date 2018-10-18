/**
 * This Gulpfile will monitor files and restart node.js
 * and reload the Chrome browser tab(s) when files changes.
 *
 * Dependencies:
 *  gulp            npm install -g gulp         (obviously as this is a gulp script)
 *  gulp-nodemon    npm install gulp-nodemon
 *  chrome-cli      brew install chrome-cli     (https://github.com/prasmussen/chrome-cli)
 *
 * Installation
 *  Make sure you have all dependencies
 *  Place this Gulpfile.js in the root of your project
 *
 * Running
 *
 *  Run "gulp" to start node.js. Now when you edit files, node will restart and chrome will
 *       reload the corrresponding tabs.
 */

var waitBeforeReload = 300 // Time it takes for the server to restart
var tabPattern = /\[(?:\d+\:+)*(\d+)\] Node\-RED/g // Name (<title>) of the tab. First subgroup is id of tab.
var nodemonProperties = {
  script: 'www', // node file to run
  ext: 'html js' // files to monitor for change
}

/**
 * Script
 *
 */
var gulp = require('gulp')
var nodemon = require('gulp-nodemon')
var exec = require('child_process').exec

gulp.task('default', function () {
  nodemon(nodemonProperties)
    .on('change', function () {
      setTimeout(function () {
        execute('chrome-cli list tabs', function (chromeTabs) {
          var match
          while (match = tabPattern.exec(chromeTabs)) {
            execute('chrome-cli reload -t ' + match[1])
          }
        })
      }, waitBeforeReload)
    })
})

function execute (command, callback) {
  exec(command, function (error, stdout, stderr) {
    if (typeof callback === 'function') {
      callback(stdout)
    }
  })
}
