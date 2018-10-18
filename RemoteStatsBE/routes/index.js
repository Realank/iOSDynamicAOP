var express = require('express')
var router = express.Router()
var request = require('request')

/* GET home page. */
router.get('/', function (req, res, next) {
  request('http://localhost:3000/api', function (error, response, body) {
    if (!error && response.statusCode === 200) {
      console.log(body) // Show the HTML for the baidu homepage.
      var mapping = JSON.parse(body)
      if (mapping.status === 'success') {
        res.render('index', {result: mapping.monitor})
      } else {
        res.render('index', { result: body })
      }
    } else {
      res.render('index', { result: 'Express' })
    }
  }
  )
})

module.exports = router
