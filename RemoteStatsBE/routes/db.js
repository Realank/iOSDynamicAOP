var mongoose = require('mongoose')
var Schema = mongoose.Schema
var mappingSchema = new Schema({
  className: String,
  methodName: String
})
function fetch (cb) {
  mongoose.connect('mongodb://127.0.0.1:27017/mapping', { useNewUrlParser: true }, (err) => {
    if (err) {
      console.log('连接数据库失败' + err)
      cb([])
    } else {
      console.log('连接成功')

      var MappingModel = mongoose.model('MappingModel', mappingSchema)
      // var doc = new MappingModel()
      MappingModel.find((err, docs) => {
        mongoose.disconnect()
        if (err) {
          console.log('mongo find error')
          cb([])
        } else {
          cb(docs)
        }
      })
    }
  })
}

function add (className, methodName, cb) {
  mongoose.connect('mongodb://127.0.0.1/mapping', { useNewUrlParser: true }, (err) => {
    if (err) {
      console.log('连接数据库失败')
      cb(false)
    } else {
      console.log('连接成功')
      var MappingModel = mongoose.model('MappingModel', mappingSchema)
      var doc = new MappingModel({className, methodName})
      doc.save(function (err, doc) {
        mongoose.disconnect()
        if (err) {
          console.log('mongo add error')
          cb(false)
        } else {
          cb(true)
        }
      })
    }
  })
}

function remove (className, methodName, cb) {
  mongoose.connect('mongodb://127.0.0.1/mapping', { useNewUrlParser: true }, (err) => {
    if (err) {
      console.log('连接数据库失败')
      cb(false)
    } else {
      console.log('连接成功')
      var MappingModel = mongoose.model('MappingModel', mappingSchema)
      MappingModel.findOneAndDelete({className, methodName}, (err, doc) => {
        cb(!err)
      })
    }
  })
}

module.exports = {fetch, add, remove}
