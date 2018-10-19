var express = require('express')
var router = express.Router()
var request = require('request')

/* GET home page. */
router.get('/', function (req, res, next) {
  request('http://localhost:3000/api/list', function (error, response, body) {
    if (!error && response.statusCode === 200) {
      console.log(body)
      var mapping = JSON.parse(body)
      if (mapping.status === 'success') {
        res.render('index', {result: mapping.monitor})
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
