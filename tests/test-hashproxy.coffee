require './env'
e         = require 'expect.js'
hashProxy = require '../lib/hashproxy'

describe 'HashProxy', ->

  it 'add', () ->
    hashProxy.add('a', 124).add('b', 456)
    hashObj =
      a: 124
      b: 456
    e(hashProxy.add('a', 3432).message).to.be('this key already exists')
    e(hashObj).to.eql(hashProxy.hashObj)
    hashProxy.delete('a','b')

  it 'get', () ->
    e(hashProxy.delete('e').message).to.be('The current key does not exist')
    hashProxy.add('c', 124)
    obj =
      '1': 765
      c: 124
    hashProxy.add(1, 765)
    e(hashProxy.get()).to.eql(obj)
    e(hashProxy.get(1)).to.eql({'1': 765})
    e(hashProxy.get('a')).to.eql({a: null})
    e(hashProxy.get('a', 'b', 'q')).to.eql({a: null, b: null, q: null })
    hashProxy.set('a', 1).set('b', 2).set('q', 3)

    e(hashProxy.get(['a', 'b', 'q'])).to.eql({a: 1, b: 2, q: 3})
    e(hashProxy.get({'key': 'a', 'key1': 'b', 'key2' : 'q'})).to.eql({key: 1, key1: 2, key2: 3})
    hashProxy.delete('a', 'b', 'q', 'c', '1', 'c')
  it 'update', () ->
    hashProxy.set('a', 345)
    e(hashProxy.get('a')).to.eql({'a' : 345})
    hashProxy.update('a', 5544)
    hashProxy.delete('a')

  it 'set', () ->
    hashProxy.set 'ff', '753252'
    obj =
      'ff': '753252'
    e(hashProxy.get('ff')).to.eql({'ff' : 753252})

  it 'delete', () ->
    e(hashProxy.get()).to.eql({'ff' : 753252})
    e(hashProxy.delete('1').message).to.be('The current key does not exist')
    e(hashProxy.get('1')).to.eql({'1': null})
    e(hashProxy.delete().message).to.be('key can not be empty')
    e(hashProxy.delete('ff', 'f', 'a').message).to.be('No need to remove the key found: f,a')

  it 'getHashWithUrl', () ->
    window.location.hash = '#a:1|b:2|c:3'
    e(hashProxy.getHashWithUrl()).to.eql({ a: '1', b: '2', c: '3' })
    e(hashProxy.generateHash()).to.be('#ff:753252|a:1|b:2|c:3')

  it 'add -> emit change', (done) ->
    hashProxy.delete('c', 'e')
    hashProxy.add('c')

    hashProxy.on 'hashchange', (data) ->
      e(data.cur).to.eql({ a: '1', b: '2', c: '3'})
      done()

    evt = document.createEvent("HTMLEvents")
    evt.initEvent "hashchange", false, false
    window.dispatchEvent(evt)
