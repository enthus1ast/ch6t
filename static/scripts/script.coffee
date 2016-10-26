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





window.myLayout = new window.GoldenLayout(config)

window.myLayout.registerComponent('ChannelWindow', (container, state) ->
  container._config.title = state.room
  channelWindow = document.querySelector('#templates > [name="channelWindow"]').cloneNode(true)
  container.getElement().html(channelWindow)
)

window.openChannelWindow = (roomname) ->
  ## this creates or returns a handle to the
  ## chat window / channel `roomname`
  if window.myLayout.root.getItemsById(roomname).length == 0
    ## there is no room widged, create one
    room = new window.Templates.PrivateWindow().AsDict
    room.id = roomname
    room.title = roomname
    room.componentState.room = roomname
    window.myLayout.root.contentItems[0].addChild(room)
    return window.myLayout.root.getItemsById(roomname)[0]
    # return room
  else
    ## there is a room name `roomname`
    ## just return the handle
    return window.myLayout.root.getItemsById(roomname)[0]

window.sendFunction = (msg,room) ->
  if msg.trim().startsWith("/")
    window.connection.send(msg[1..] + "\n")
  else
    window.connection.send("privmsg #{room} :#{msg}\n")


window.myLayout.registerComponent('PrivateWindow', (container, state) ->
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

window.myLayout.registerComponent('MenuWindow', (container, state) ->
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
