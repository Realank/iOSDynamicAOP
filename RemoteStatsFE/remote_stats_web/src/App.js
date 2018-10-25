import React, { Component } from 'react'
import './App.css'

class Waiting extends Component {
  render () {
    return (
      <tr>
        <td class='empty'>waiting...</td>
        <td class='empty' />
      </tr>
    )
  }
}

class Empty extends Component {
  render () {
    return (
      <tr>
        <td class='empty'>empty</td>
        <td class='empty' />
      </tr>
    )
  }
}

class MappingItem extends Component {
  render () {
    const mappingItem = this.props.mappingItem
    return (
      <tr>
        <td>

          <div class='row'>
            <div class='sameWidth'>
              <h4 class='content'>
                {mappingItem.className}</h4>
              <h4 className='subscript'>class</h4>
            </div>
            <div class='sameWidth'>
              <h4 class='content'>{mappingItem.methodName}</h4>
              <h4 class='subscript'>method</h4>
            </div>

          </div>
          <div className='row'>
            <div class='sameWidth'><h4 class='desc'>Event code:</h4></div>
            <div class='sameWidth'><h4 class='desc'>Mark:</h4></div>
            <div class='sameWidth'><h4 class='desc'>Collect detail:</h4><input type='checkbox' disabled checked /></div>

          </div>
          <div >
            <MappingFilterList />

          </div>

        </td>
        <td className='edit'>
          <button className='remove' onClick='remove({mappingItem})'>x</button>
        </td>
      </tr>
    )
  }
}

class MappingList extends Component {
  render () {
    let renderList = null
    if (this.props.list === null) {
      renderList = <Waiting />
    } else if (this.props.list.length === 0) {
      renderList = <Empty />
    } else {
      console.log('goes here')
      let list = this.props.list

      renderList = list.map((mappingItem, index) => {
        return <MappingItem mappingItem={mappingItem} key={mappingItem.className + mappingItem.methodName + index} />
      })
    }
    return (

      <React.Fragment>
        {renderList}
      </React.Fragment>
    )
  }
}

class MappingFilterList extends Component {
  render () {
    return (

      <div class='subRow'>
        <div className='sameWidth'><h4 className='desc'>Filter key:</h4></div>
        <div className='sameWidth'><h4 className='desc'>Content:</h4></div>
        <div className='sameWidth' ><button className='remove' onClick='remove()'>x</button></div>
      </div>

    )
  }
}

class InputNewMapping extends Component {
  render () {
    return (
      <tr >
        <td>
          <div class='row'>
            <h4 class='desc'>Add a new mapping:</h4>
          </div>
          <div class='row'>
            <input type='text' id='className' placeholder='class' />
            <input type='text' id='methodName' placeholder='method' />
          </div>
          <div class='row'>
            <h4 class='desc'>Event code:</h4>
            <input type='text' id='eventCode' placeholder='Event code' />
            <h4 class='desc'>Mark:</h4>
            <input type='text' id='mark' placeholder='Mark' />
            <h4 class='desc'>Collect detail:</h4>
            <input type='checkbox' id='collectDetail' />
          </div>
          <div class='row'>
            <h4 class='desc'>Filter:</h4>
          </div>
          <div class='row,filter' >
            <MappingFilterList />

            <div className='subRow'>
              <div className='sameWidth'><input type='text' id='eventCode' placeholder='Filter key' /></div>
              <div className='sameWidth'><input type='text' id='eventCode' placeholder='Content' /></div>
              <div className='sameWidth'>
                <button className='add' onClick='add()'>+</button>
              </div>

            </div>
          </div>
        </td>
        <td>
          <button class='add' onClick='add()'>+</button>
        </td>
      </tr>
    )
  }
}

class App extends Component {
  constructor (props) {
    super(props)
    this.state = {list: null}
  }

  componentDidMount () {
    this.setState(
      {
        ...this.state,
        list: [
          {className: 'ViewController', methodName: 'viewDidAppear:'},
          {className: 'UIViewController', methodName: 'viewDidAppear:'}
        ]}
    )
  }
  render () {
    let countString = 0
    if (this.state.list !== null) {
      countString = this.state.list.length
    }
    return (

      <div>
        <h1>Monitor</h1>
        <h4> {countString} methods to monitor</h4>
        <table border='0' class='mappingTable'>
          <thead>
            <tr>
              <th>Mapping</th>
              <th class='edit'>Edit</th>
            </tr>
          </thead>
          <tbody>
            <MappingList list={this.state.list} />
            <InputNewMapping />
          </tbody>

        </table>

      </div>
    )
  }
}

export default App
