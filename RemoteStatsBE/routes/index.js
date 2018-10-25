var express = require('express')
var router = express.Router()
var request = require('request')

var test = 1
var host = test ? 'http://localhost:3000' : 'http://www.realank.com:3000'

/* GET home page. */
router.get('/', function (req, res, next) {
  request(host + '/api/list', function (error, response, body) {
    if (!error && response.statusCode === 200) {
      console.log(body)
      var mapping = JSON.parse(body)
      if (mapping.status === 'success') {
        res.render('index', {result: mapping.monitor, host: host})
      } else {
        res.render('index', { error: body })
      }
    } else {
      res.render('index', { error: 'can\'s request'})
    }
  }
  )
})

module.exports = router
