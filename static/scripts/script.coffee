window.clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date(obj.getTime()) 

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global?
    flags += 'i' if obj.ignoreCase?
    flags += 'm' if obj.multiline?
    flags += 'y' if obj.sticky?
    return new RegExp(obj.source, flags) 

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance


writeWin = {
  type: 'component',
  componentName: 'channelWindow',
  isClosable: false
  reorderEnabled: false
  showPopoutIcon: false
  showCloseIcon: false
  showMaximiseIcon: false
  componentState: { room: 'writeWin' }
}

chatWin = {
  type: 'component',
  componentName: 'channelWindow',
  showPopoutIcon: false
  showCloseIcon: false
  isClosable: false
  reorderEnabled: true
  showMaximiseIcon: false
  componentState: { room: 'chatWin' }
}
window.chatWin2 = {
  id: 'server',
  type: 'component',
  componentName: 'privateWindow',
  showPopoutIcon: false
  showCloseIcon: true
  isClosable: true
  reorderEnabled: true
  showMaximiseIcon: true
  componentState: { room: 'chatWin' }
}

userlistWin = {
  type: 'component'
  width: 20
  componentName: 'channelWindow',
  componentState: { room: 'userlistWin' }
}


serverWindow = {
  type: "column"
  content: [{
    type: "column"
    componentName: 'channelWindow',
    content: [{
      type: "row"
      content: [chatWin]
    }]
  }]
}
serverWindow2 = {
  type: "column"
  content: [{
    type: "column"
    content: [{
      type: "row"
      content: [window.chatWin2]
    }]
  }]
}


channelWindow = {
  type: "column"
  content: []
}


window.menu = {
  type: 'component'
  componentName: 'menu'
  height: 10
  componentState: { }
}

window.config = {
  settings: {
    hasHeaders: true
    showPopoutIcon: false
    showExitIcon: true
  }
  content: [{
    type: 'stack'
    # content: [menu,serverWindow,serverWindow2,serverWindow]
    content: [window.menu,serverWindow2]
  }]
}

window.myLayout = new window.GoldenLayout(config)

window.myLayout.registerComponent('channelWindow', (container, state) ->
  container._config.title = state.room
  channelWindow = document.querySelector('#templates > [name="channelWindow"]').cloneNode(true)
  container.getElement().html(channelWindow)
)

window.openChatWindow = (roomname) ->
  ## this creates or returns a handle to the
  ## chat window / channel `roomname`
  if window.myLayout.root.getItemsById(roomname).length == 0
    ## there is no room widged, create one
    newRoom = clone(window.chatWin2)
    newRoom.id = roomname
    newRoom.title = roomname
    newRoom.componentState.room = roomname
    window.myLayout.root.contentItems[0].addChild(newRoom)
    return window.myLayout.root.getItemsById(roomname)[0]
    # return newRoom
  else
    ## there is a room name `roomname`
    ## just return the handle
    return window.myLayout.root.getItemsById(roomname)[0]

window.sendFunction = (msg,room) ->
  if msg.trim().startsWith("/")
    window.connection.send(msg[1..] + "\n")
  else
    window.connection.send("privmsg #{room} :#{msg}\n")


window.myLayout.registerComponent('privateWindow', (container, state) ->
  container._config.title = state.room
  privateWindow = document.querySelector('#templates > [name="privateWindow"]').cloneNode(true)

  getDataAndClean = ->
    msg = privateWindow.querySelector("input").value
    window.sendFunction(msg, state.room)
    privateWindow.querySelector("input").value = ""

    appendToRoom(state.room, {who:"", trailer: msg, params: [state.room]})
    #div = document.createElement('div')
    #div.innerText = msg
    #privateWindow.querySelector(".output").appendChild(div)

    privateWindow.querySelector(".output").scrollTop = privateWindow.querySelector(".output").scrollHeight

  privateWindow.querySelector("button").onclick = ->
    getDataAndClean()

  privateWindow.querySelector("input").onkeyup = (event) ->
    if ( event.which == 13 )
      getDataAndClean()

  container.getElement().html(privateWindow)
)

window.myLayout.registerComponent('menu', (container, state) ->
  console.log(container)
  # container._config.title = state.room
  # container.getElement().html()
  # chatWidget =
  # writeWidget = ""
  # container.getElement().html( '<div>' + state.room + '</div>')
  # template = document.querySelector('#newTemplate');

  # container.getElement().html("ich bins menu")

  #menu
  menu = document.querySelector('#templates > [name="menu"]').cloneNode(true)
  container.getElement().html(menu)
  container.getElement()[0].querySelector('button[name="connect"]').onclick = ->
    alert "Connect"

  container.getElement()[0].querySelector('button[name="join"]').onclick = ->
    roomToJoin = container.getElement()[0].querySelector('input[name="room"]')
    sendFunction("/join " + roomToJoin.value)
    roomToJoin.value = ""
)

window.myLayout.init()

# myLayout.root.addChild(oneWidget)
