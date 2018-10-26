import React, { Component } from 'react'
import {connect} from 'react-redux'

class FilterList extends Component {
  render () {
    console.log('render FilterList')
    const list = this.props.list ? this.props.list : []
    let renderList = list.map((filterItem, index) => {
      let removeButton = <div className='sameWidth' ><button className='remove' onClick={this.props.removeFilter.bind(this, filterItem)}>x</button></div>
      if (this.props.canRemove === false) {
        removeButton = <div className='sameWidth' />
      }
      return (
        <div className='subRow' key={'key' + filterItem.key + index}>
          <div className='sameWidth'>
            <h4 className='desc'>Filter key:</h4>
            <h4 className='content'>{filterItem.key}</h4>
          </div>
          <div className='sameWidth'>
            <h4 className='desc'>Content:</h4>
            <h4 className='content'>{filterItem.content}</h4>
          </div>
          {removeButton}
        </div>
      )
    })
    if (renderList.length === 0) {
      renderList.push(
        <div className='subRow' key={'nofilter'}>
          <h4 className='desc'>No filter</h4>
        </div>
      )
    }

    return (
      <div className='row filter'>
        {renderList}
      </div>
    )
  }
}

const mapDispatchToProps = {
  removeFilter: (filter) => ({
    type: 'RemoveFilter',
    content: filter
  })
}

export default connect(null, mapDispatchToProps)(FilterList)
