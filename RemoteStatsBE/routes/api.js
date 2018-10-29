let express = require('express')
let cors = require('cors')
let router = express.Router()
let db = require('./db.js')

router.use(cors())
/* GET users listing. */
router.get('/list', function (req, res, next) {
  db.fetch((result) => {
    let mapping = result
    putHeader(res)
    res.send(JSON.stringify({
      status: 'success',
      monitor: mapping
    }))
  })
})

router.post('/upload', function (req, res, next) {
  let mapping = req.body
  let className = mapping.className
  let methodName = mapping.methodName
  let eventCode = mapping.eventCode
  let mark = mapping.mark
  let collectDetail = mapping.collectDetail
  if (className && methodName && eventCode && className.length > 0 && methodName.length > 0 && eventCode.length > 0) {
    let newMapping = {
      className, methodName, eventCode, mark, collectDetail, filterList: mapping.filterList
    }
    console.log('类型判读通过')
    db.add(newMapping, (success) => {
      putHeader(res)
      if (success) {
        res.send({status: 'success'})
      } else {
        res.send({status: 'failed', msg: 'DB error'})
      }
    })
  } else {
    console.log('类型判断失败')
    putHeader(res)
    res.send({status: 'failed', msg: 'Please fill blanks'})
  }
})

router.post('/remove', function (req, res, next) {
  let mapping = req.body

  let className = mapping.className
  let methodName = mapping.methodName
  if (className.length > 0 && methodName.length > 0) {
    console.log('类型判读通过')
    db.remove({className, methodName}, (success) => {
      console.log('remove success in api')
      putHeader(res)
      res.send({status: success ? 'success' : 'failed'})
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
