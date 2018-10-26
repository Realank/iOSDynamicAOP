import React, { Component } from 'react'
import './App.css'

import { Provider } from 'react-redux'
import { createStore, applyMiddleware } from 'redux'
// import thunk from 'redux-thunk'
import Monitor from './Components/Monitor'

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
  fetch('http://www.realank.com:3000/api/list').then((res) => res.json()).then((json) => {
    console.log('fetch success ' + JSON.stringify(json))
    if (json && json.status === 'success' && json.monitor) {
      store.dispatch(fetchSuccess(json.monitor))
    }
  })
}

const upload = (newMapping) => {
  console.log('upload:' + JSON.stringify(newMapping))
  fetch('http://www.realank.com:3000/api/upload', {
    method: 'post',
    mode: 'no-cors',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(newMapping)
  }).then((res) => {
    fetchList()
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
      if (validString(newState.newMapping.inputing_filter_key) && validString(newState.newMapping.inputing_filter_content)) {
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
      }
      return newState
    case 'Input':
      newMapping[action.content.name] = action.content.value
      newState.newMapping = newMapping
      return newState
    case 'Remove':
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
