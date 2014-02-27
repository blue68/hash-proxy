events = require 'events'

class HashProxy extends events.EventEmitter
  constructor: () ->
    @preObj = null
    @hashObj = @getHashWithUrl()
    @timer = null
    @events = {}

    window.addEventListener 'hashchange', () =>
      @preObj = @hashObj
      @hashObj = @getHashWithUrl()
      obj =
        pre : @preObj
        cur : @hashObj
      @emit 'hashchange', obj
    @

  #insert
  add : (key, value) ->
    if @has(key)
      return @_error('this key already exists')
    else
      @hashObj[key] = value

      @_change()
    @
  #replace
  set : (key, value) ->
    @hashObj[key] = value
    @_change()
    @
  #update
  update : (key, value) ->
    if @has(key)
      @hashObj[key] = value
      @_change()
    else
      return @_error('The current key does not exist')
    @
  #delete #key | key1,key2
  delete : () ->
    self = @
    if arguments.length is 0
      return self._error('key can not be empty')
    else if arguments.length is 1
      args = arguments[0]
      if self.has(args)
        delete self.hashObj[args]
        self._change(false)
      else
        return self._error('The current key does not exist')
    else
      errkeys = []
      keys = []
      for key in arguments
        if self.has(key)
          keys.push(key)
        else
          errkeys.push(key)
      if errkeys.length > 0
        return self._error("No need to remove the key found: #{errkeys.join(',')}")
      else
        for item in keys
          delete self.hashObj[item]
        self._change(false)

  _error : (msg) ->
    error = new Error(msg)
    console.log error

    return error

  has : (key) ->
    if @hashObj.hasOwnProperty(key)
      return true
    return false

  getValueWithString : (key) ->
    values = {}
    if @has(key)
      values[key] = @hashObj[key]
    else
      values[key] = null

    return values

  getValueWithArray : (args) ->
    self = @
    values = {}
    if args.length > 0
      for key, i in args
        if self.has(key)
          values[key] = self.hashObj[key]
        else
          values[key] = null

    return values
  getValueWithObject : (args) ->
    values = {}
    for key, value of args
      if @has(value)
        values[key] = @hashObj[value]
      else
        values[key] = null

    return values
  #select :key | key1,key2,key3 | [key1,key2,key3] | {n1:key1,n2:key2}
  get : () ->
    self = @
    toString = Object.prototype.toString
    if arguments.length is 0
      returnValue = self.hashObj
    else if arguments.length is 1
      args = arguments[0]
      type = toString.call(args)
      switch type
        when "[object String]", "[object Number]" then  returnValue = self.getValueWithString(args)
        when "[object Array]"  then  returnValue = self.getValueWithArray(args)
        when "[object Object]" then  returnValue = self.getValueWithObject(args)
    else
      returnValue = {}
      for key, i in arguments
        if self.has(key)
          returnValue[key] = self.hashObj[key]
        else
          returnValue[key] = null

    return returnValue
  #hash str
  generateHash : (flag=true) ->
    hashStr = '#'
    args = [];
    #add, set, update时获取下当前url中的hash值 与 @hashObj 合并后生成最终结果
    if flag
      _curHash = @getHashWithUrl()
      for key, value of _curHash
        if not @hashObj.hasOwnProperty(key)
          @hashObj[key] = value
    for key, value of @hashObj
      args.push(key + ':' + encodeURIComponent(value))

    hashStr += args.join('|')

    return hashStr
  #hash Object
  getHashWithUrl : () ->
    hash = window.location.hash.split("#")[1] or ""
    hashInfo = @_parsing(hash)

    return hashInfo

  # cid:50016349|sid:33780312|start:2012-02-02|end:2012-02-08|dt:1|rid:hot_product
  _parsing : (str) ->
    res = {}
    return res if not str
    arr = []
    tmp = []
    arr = str.split('|')
    for item, i in arr
      tmp = item.split(':')
      if typeof tmp[1] is 'undefined'
        res[tmp[0]] = 'undefined'
      else
        try
          res[tmp[0]] = decodeURIComponent(tmp[1])
        catch e
          console.log "#{item}:#{e}"

    return res
  #hash change
  _change : (flag) ->
    if @timer
      clearTimeout(@timer)

    @timer = setTimeout () =>
      window.location.hash = @generateHash(flag)
    , 10

module.exports = new HashProxy()