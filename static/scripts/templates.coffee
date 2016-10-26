Templates = {}

class Templates.BaseWindow
  constructor: ->
    Object.defineProperty(@, 'AsDict',
      get: ->
        dict = {}
        for key in Object.keys(@)
          dict[key] = @[key]
        return dict
    )

class Templates.ChannelWindow extends Templates.BaseWindow
  constructor: ->
    super()
    @type = 'component'
    @componentName = 'ChannelWindow'

    @showPopoutIcon = false
    @showCloseIcon = false
    @isClosable = false
    @reorderEnabled = true
    @showMaximiseIcon = false
    @componentState =
      room: "#{@componentName}Room"


class Templates.PrivateWindow extends Templates.BaseWindow
  constructor: ->
    super()
    @type = 'component'
    @componentName = 'PrivateWindow'

    @id = 'server'
    @showPopoutIcon = false
    @showCloseIcon = true
    @isClosable = true
    @reorderEnabled = true
    @showMaximiseIcon = true
    @componentState =
      room: "#{@.name}Room"


class Templates.MenuWindow extends Templates.BaseWindow
  constructor: ->
    super()
    @type = 'component'
    @componentName = 'MenuWindow'
    @height = 10
    @componentState = {}


class Templates.ServerWindow extends Templates.BaseWindow
  constructor: ->
    super()
    @type = 'column'
    @content = [{
      type: 'column'
      componentName: 'PrivateWindow',
      content: [{
        type: 'row'
        content: [new Templates.PrivateWindow().AsDict]
      }]
    }]





window.config =
  settings:
    hasHeaders: true
    showPopoutIcon: false
    showExitIcon: true
  content: [{
    type: 'stack'
    # content: [menu,serverWindow,serverWindow2,serverWindow]
    content: [new Templates.MenuWindow().AsDict, new Templates.ServerWindow().AsDict]
  }]
