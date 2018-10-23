var express = require('express')
var router = express.Router()
var db = require('./db.js')

/* GET users listing. */
router.get('/list', function (req, res, next) {
  db.fetch((result) => {
    var mapping = result
    putHeader(res)
    res.send(JSON.stringify({
      status: 'success',
      monitor: mapping
    }))
  })
})

router.post('/upload', function (req, res, next) {
  var mapping = req.body

  var className = mapping.className
  var methodName = mapping.methodName
  if (className.length > 0 && methodName.length > 0) {
    console.log('类型判读通过')
    db.add(className, methodName, (success) => {
      putHeader(res)
      res.send({staus: success ? 'success' : 'failed'})
    })
  }
})

router.post('/remove', function (req, res, next) {
  var mapping = req.body

  var className = mapping.className
  var methodName = mapping.methodName
  if (className.length > 0 && methodName.length > 0) {
    console.log('类型判读通过')
    db.remove(className, methodName, (success) => {
      console.log('remove success in api')
      putHeader(res)
      res.send({staus: success ? 'success' : 'failed'})
    })
  }
})

function putHeader (res) {
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS')
  res.header('Access-Control-Allow-Headers', 'X-Requested-With')
  res.header('Access-Control-Allow-Headers', 'Content-Type')
}

module.exports = router
