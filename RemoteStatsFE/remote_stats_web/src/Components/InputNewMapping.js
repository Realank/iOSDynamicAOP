import React, { Component } from 'react'
import {connect} from 'react-redux'
import FilterList from './FilterList'

class InputNewMapping extends Component {
  handleInputChange (event) {
    const target = event.target
    const value = target.type === 'checkbox' ? target.checked : target.value
    const name = target.name
    this.props.inputTF({name, value})
  }

  reactInput (nameStr, placeholder) {
    let newMapping = this.props.newMapping
    let value = newMapping ? newMapping[nameStr] : ''
    value = value || ''
    return (
      <input type='text' placeholder={placeholder} name={nameStr} value={value} onChange={this.handleInputChange.bind(this)} />
    )
  }

  render () {
    const newMapping = this.props.newMapping
    console.log('render InputNewMapping ' + JSON.stringify(newMapping))
    return (
      <tr >
        <td>
          <div className='row'>
            <h4 className='desc'>Add a new mapping:</h4>
          </div>
          <div className='row'>
            {this.reactInput('className', 'class')}
            {this.reactInput('methodName', 'method')}
          </div>
          <div className='row' style={{ padding: '2px 0px 0px', margin: '0px 10px', backgroundColor: 'white'}} />
          <div className='row'>
            <div className='sameWidth'>
              <h4 className='desc'>Event code:</h4>
              {this.reactInput('eventCode', 'Event code')}
            </div>
            <div className='sameWidth'>
              <h4 className='desc'>Mark:</h4>
              {this.reactInput('mark', 'Mark')}
            </div>
            <div className='sameWidth'>
              <h4 className='desc'>Collect detail:</h4>
              <input type='checkbox' id='collectDetail' name='collectDetail' checked={this.props.newMapping ? this.props.newMapping.collectDetail : false} onChange={this.handleInputChange.bind(this)} />
            </div>

          </div>
          <div className='row'>
            <h4 className='desc'>Filter:</h4>
          </div>
          <div className='row filter' >
            <FilterList canRemove list={newMapping ? newMapping.filterList : []} />

            <div className='subRow'>
              <div className='sameWidth'>{this.reactInput('inputing_filter_key', 'Filter key')} </div>
              <div className='sameWidth'>{this.reactInput('inputing_filter_content', 'Filter content')}</div>

              <div className='sameWidth'>
                <button className='add' onClick={this.props.addNewFilter.bind(this)}>+</button>
              </div>

            </div>
          </div>
        </td>
        <td>
          <button className='add' onClick={this.props.addNewMapping.bind(this)}>+</button>
        </td>
      </tr>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    newMapping: state.newMapping
  }
}

const mapDispatchToProps = {
  addNewMapping: () => ({
    type: 'AddNew'
  }),
  addNewFilter: () => ({
    type: 'AddFilter'
  }),
  inputTF: (item) => ({
    type: 'Input',
    content: item
  })
}

export default connect(mapStateToProps, mapDispatchToProps)(InputNewMapping)
