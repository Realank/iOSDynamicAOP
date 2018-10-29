import React, { Component } from 'react'
import './App.css'

import { Provider } from 'react-redux'
import { createStore, applyMiddleware } from 'redux'
// import thunk from 'redux-thunk'
import Monitor from './Components/Monitor'

const debug = 0
const baseUrl = debug ? 'http://localhost:3000/' : 'http://www.realank.com:3000/'

const persistedState = {
  list: [

  ],
  newMapping: {
  },
  loading: true
}

const fetchSuccess = (list) => {
  return {
    type: 'FetchSuccess',
    content: list
  }
}
const fetchFailed = (err) => {
  return {
    type: 'FetchFailed',
    content: err
  }
}

const fetchList = () => {
  console.log('fetchList')
  fetch(baseUrl + 'api/list').then(
    (res) => {
      if (res.status !== 200) {
        // error
        store.dispatch(fetchFailed('Load list error ' + res.status))
      } else {
        return res.json()
      }
    }).then(
    (json) => {
      console.log('fetch success ' + JSON.stringify(json))
      if (json && json.status === 'success' && json.monitor) {
        store.dispatch(fetchSuccess(json.monitor))
      } else {
        store.dispatch(fetchFailed('Parse list error'))
      }
    }).catch(
    (err) => {
      store.dispatch(fetchFailed('Catch error ' + err))
    })
}

function keyWordsTest (string, allowBlank = false, addtionalChar = '') {
  if (!allowBlank) {
    if (!string || string.length === 0) {
      return false
    }
  }
  const regExp = '^[a-zA-Z_][\\w_' + addtionalChar + ']{0,50}$'
  var keywordsPattern = new RegExp(regExp)

  return keywordsPattern.test(string)
}

const upload = (newMapping) => {
  console.log('upload:' + JSON.stringify(newMapping))
  // safety check
  if (!newMapping) {
    alert('Error: fill blanks')
    return
  }

  if (!keyWordsTest(newMapping.className)) {
    alert('Error: wrong class name ')
    return
  }

  if (!keyWordsTest(newMapping.methodName, false, ':')) {
    alert('Error: wrong method name')
    return
  }

  if (!keyWordsTest(newMapping.eventCode)) {
    alert('Error: wrong event code')
    return
  }

  if (!keyWordsTest(newMapping.mark, true)) {
    alert('Error: wrong mark')
    return
  }

  const mapping = {
    className: newMapping.className,
    methodName: newMapping.methodName,
    eventCode: newMapping.eventCode,
    mark: newMapping.mark,
    collectDetail: newMapping.collectDetail,
    filterList: newMapping.filterList
  }
  fetch(baseUrl + 'api/upload', {
    method: 'post',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json;charset=UTF-8'
    },
    body: JSON.stringify(mapping)
  }).then((res) => {
    if (res.status !== 200) {
      // error
      store.dispatch(fetchFailed('Error: ' + res.status))
    } else {
      return res.json()
    }
  }).then(
    (json) => {
      if (json && json.status === 'success') {
        fetchList()
      } else if (json && json.status === 'failed') {
        alert('Error: ' + json.msg)
      }
    }
  )
}

const remove = (existMapping) => {
  console.log('remove:' + JSON.stringify(existMapping))
  fetch(baseUrl + 'api/remove', {
    method: 'post',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json;charset=UTF-8'
    },
    body: JSON.stringify({className: existMapping.className, methodName: existMapping.methodName})
  }).then((res) => {
    if (res.status !== 200) {
      // error
      store.dispatch(fetchFailed('Remove error ' + res.status))
    } else {
      fetchList()
    }
  })
}

const validString = (string) => {
  if (string && string.length > 0) {
    return true
  } else {
    return false
  }
}

const reducer = (state = persistedState, action) => {
  console.log('action:' + JSON.stringify(action))
  let newState = Object.assign({}, state)
  let newMapping = {...newState.newMapping}
  switch (action.type) {
    case 'AddNew':
      upload(newState.newMapping)
      return newState
    case 'AddFilter':
      if (keyWordsTest(newState.newMapping.inputing_filter_key) && keyWordsTest(newState.newMapping.inputing_filter_content)) {
        let newMapping = {...newState.newMapping}
        let oldFilterList = newMapping.filterList
        if (!oldFilterList) {
          oldFilterList = []
        }
        newMapping.filterList = oldFilterList.map((item) => item)
        newMapping.filterList.push({key: newState.newMapping.inputing_filter_key, content: newState.newMapping.inputing_filter_content})
        newMapping.inputing_filter_key = ''
        newMapping.inputing_filter_content = ''
        newState.newMapping = newMapping
        console.log('added filter')
        return newState
      } else {
        alert('wrong filter')
        return newState
      }

    case 'Input':
      newMapping[action.content.name] = action.content.value
      newState.newMapping = newMapping
      return newState
    case 'Remove':
      remove(action.content)
      return newState
    case 'RemoveFilter':
      let oldFilterList = newMapping.filterList
      if (!oldFilterList) {
        oldFilterList = []
      }
      newMapping.filterList = oldFilterList.filter((item) => (item.key !== action.content.key && item.content !== action.content.content))
      newState.newMapping = newMapping
      return newState
    case 'Reload':
      fetchList()
      return newState
    case 'FetchSuccess':
      return {
        list: action.content,
        loading: false
      }
    case 'FetchFailed':
      console.log('fetch failed' + action.content)
      alert(action.content)
      return newState
    default:
      return newState
  }
}

const store = createStore(
  reducer
  // applyMiddleware(thunk)
)

class App extends Component {
  render () {
    return (
      <Provider store={store}>
        <Monitor />
      </Provider>
    )
  }
}

export default App
