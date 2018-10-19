var express = require('express')
var router = express.Router()
var db = require('./db.js')

/* GET users listing. */
router.get('/list', function (req, res, next) {
  db.fetch((result) => {
    var mapping = result
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
      res.send({staus: success ? 'success' : 'failed'})
    })
  }
})

module.exports = router
