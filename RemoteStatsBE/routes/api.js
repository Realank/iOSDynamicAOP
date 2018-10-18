var express = require('express')
var router = express.Router()

/* GET users listing. */
router.get('/', function (req, res, next) {
  res.send(JSON.stringify({
    status: 'success',
    monitor: [ {
      className: 'ViewController',
      methodName: 'viewDidAppear:'
    }, {
      className: 'UIViewController',
      methodName: 'viewDidAppear:'
    }]
  }))
})

module.exports = router
