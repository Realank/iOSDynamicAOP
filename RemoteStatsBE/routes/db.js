let mongoose = require('mongoose')
let Schema = mongoose.Schema
let mappingSchema = new Schema({
  className: String,
  methodName: String,
  eventCode: String,
  metaData: String,
  collectDetail: Boolean,
  filterList: [
    { key: String, content: String }
  ]
})
function fetch (cb) {
  mongoose.connect('mongodb://127.0.0.1:27017/mappings', { useNewUrlParser: true }, (err) => {
    if (err) {
      console.log('连接数据库失败' + err)
      cb([])
    } else {
      console.log('连接成功')

      let MappingModel = mongoose.model('MappingModel', mappingSchema)
      // let doc = new MappingModel()
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

function add (newMapping, cb) {
  mongoose.connect('mongodb://127.0.0.1/mappings', { useNewUrlParser: true }, (err) => {
    if (err) {
      console.log('连接数据库失败')
      cb(false)
    } else {
      console.log('连接成功')
      let MappingModel = mongoose.model('MappingModel', mappingSchema)
      console.log('insert new mapping ' + JSON.stringify(newMapping))
      let doc = new MappingModel(newMapping)
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

function remove (existMapping, cb) {
  mongoose.connect('mongodb://127.0.0.1/mappings', { useNewUrlParser: true }, (err) => {
    if (err) {
      console.log('连接数据库失败')
      cb(false)
    } else {
      console.log('连接成功')
      let MappingModel = mongoose.model('MappingModel', mappingSchema)
      MappingModel.findOneAndDelete({ className: existMapping.className, methodName: existMapping.methodName }, (err, doc) => {
        cb(!err)
      })
    }
  })
}

module.exports = { fetch, add, remove }
