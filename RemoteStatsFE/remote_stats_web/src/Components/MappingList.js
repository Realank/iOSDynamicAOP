import React, { Component } from 'react'
import FilterList from './FilterList'
import { connect } from 'react-redux'

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
            <div className='sameWidth'><h4 className='desc'>Event code:</h4><h4 className='content'>{mappingItem.eventCode}</h4></div>
            <div className='sameWidth'><h4 className='desc'>Meta data:</h4><h4 className='content'>{mappingItem.metaData}</h4></div>
            <div className='sameWidth'><h4 className='desc'>Collect detail:</h4><input type='checkbox' disabled checked={mappingItem.collectDetail} /></div>

          </div>
          <FilterList canRemove={false} list={mappingItem.filterList} />

        </td>
        <td className='edit'>
          <button className='remove' onClick={this.props.remove.bind(this, mappingItem)}>x</button>
        </td>
      </tr>
    )
  }
}

const mapDispatchToProps = {
  remove: (mapping) => ({
    type: 'Remove',
    content: mapping
  })
}

const ConnectedMappingItem = connect(null, mapDispatchToProps)(MappingItem)

class MappingList extends Component {
  render () {
    let renderList = null
    if (this.props.loading) {
      renderList = <Waiting />
    } else if (this.props.list.length === 0) {
      renderList = <Empty />
    } else {
      console.log('goes here')
      let list = this.props.list

      renderList = list.map((mappingItem, index) => {
        return <ConnectedMappingItem mappingItem={mappingItem} key={mappingItem.className + mappingItem.methodName + index} />
      })
    }
    return (

      <React.Fragment>
        {renderList}
      </React.Fragment>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    loading: state.loading
  }
}

export default connect(mapStateToProps)(MappingList)
