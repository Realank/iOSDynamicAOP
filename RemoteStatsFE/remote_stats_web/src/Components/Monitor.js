import React, { Component } from 'react'
import {connect} from 'react-redux'
import InputNewMapping from './InputNewMapping'
import MappingList from './MappingList'

class Monitor extends Component {
  componentDidMount () {
    setTimeout(() => {
      this.props.reload()
    }, 3000)
  }
  render () {
    return (

      <div>
        <h1>Monitor</h1>
        <h4> {this.props.list.length} methods to monitor</h4>
        <table border='0' className='mappingTable'>
          <thead>
            <tr>
              <th>Mapping</th>
              <th className='edit'>Edit</th>
            </tr>
          </thead>
          <tbody>
            <MappingList list={this.props.list} />
          </tbody>
          <tfoot>
            <InputNewMapping />
          </tfoot>
        </table>

      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    list: state.list
  }
}

const mapDispatchToProps = {
  reload: () => ({
    type: 'Reload'
  })
}

export default connect(mapStateToProps, mapDispatchToProps)(Monitor)
