import React, { Component } from 'react'
import './App.css'

class Waiting extends Component {
  render () {
    return (
      <tr>
        <td className='empty'>loading...</td>
        <td className='empty' />
      </tr>
    )
  }
}

class Empty extends Component {
  render () {
    return (
      <tr>
        <td className='empty'>empty</td>
        <td className='empty' />
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

          <div className='row'>
            <div className='sameWidth'>
              <h4 className='content'>
                {mappingItem.className}</h4>
              <h4 className='subscript'>class</h4>
            </div>
            <div className='sameWidth'>
              <h4 className='content'>{mappingItem.methodName}</h4>
              <h4 className='subscript'>method</h4>
            </div>

          </div>
          <div className='row'>
            <div className='sameWidth'><h4 className='desc'>Event code:</h4></div>
            <div className='sameWidth'><h4 className='desc'>Mark:</h4></div>
            <div className='sameWidth'><h4 className='desc'>Collect detail:</h4><input type='checkbox' disabled checked /></div>

          </div>
          <div className='row filter'>
            <MappingFilterList canRemove={false} />

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
    let removeButton = <div className='sameWidth' ><button className='remove' onClick='remove()'>x</button></div>
    if (this.props.canRemove === false) {
      removeButton = <div className='sameWidth' />
    }
    return (

      <div className='subRow'>
        <div className='sameWidth'><h4 className='desc'>Filter key:</h4></div>
        <div className='sameWidth'><h4 className='desc'>Content:</h4></div>
        {removeButton}
      </div>

    )
  }
}

class InputNewMapping extends Component {
  render () {
    return (
      <tr >
        <td>
          <div className='row'>
            <h4 className='desc'>Add a new mapping:</h4>
          </div>
          <div className='row'>
            <input type='text' id='className' placeholder='class' />
            <input type='text' id='methodName' placeholder='method' />
          </div>
          <div className='row' style={{ padding: '2px 0px 0px', margin: '0px 10px', backgroundColor: 'white'}} />
          <div className='row'>
            <div className='sameWidth'>
              <h4 className='desc'>Event code:</h4>
              <input type='text' id='eventCode' placeholder='Event code' />
            </div>
            <div className='sameWidth'>
              <h4 className='desc'>Mark:</h4>
              <input type='text' id='mark' placeholder='Mark' />
            </div>
            <div className='sameWidth'>
              <h4 className='desc'>Collect detail:</h4>
              <input type='checkbox' id='collectDetail' />
            </div>

          </div>
          <div className='row'>
            <h4 className='desc'>Filter:</h4>
          </div>
          <div className='row filter' >
            <MappingFilterList canRemove />

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
          <button className='add' onClick='add()'>+</button>
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
    setTimeout(function () {
      this.setState(
        {
          ...this.state,
          list: [
            {className: 'ViewController', methodName: 'viewDidAppear:'},
            {className: 'UIViewController', methodName: 'viewDidAppear:'}
          ]}
      )
    }.bind(this), 1000)
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
        <table border='0' className='mappingTable'>
          <thead>
            <tr>
              <th>Mapping</th>
              <th className='edit'>Edit</th>
            </tr>
          </thead>
          <tbody>
            <MappingList list={this.state.list} />

          </tbody>
          <tfoot>
            <InputNewMapping />
          </tfoot>
        </table>

      </div>
    )
  }
}

export default App
