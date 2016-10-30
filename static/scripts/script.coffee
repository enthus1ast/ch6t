## CONFIG/DECLARE GoldenLayout
config =
  settings:
    hasHeaders: true
    showPopoutIcon: false
    showExitIcon: true
  content: [{
    type: 'stack'
    # content: [menu,serverWindow,serverWindow2,serverWindow]
    content: [new Templates.MenuWindow().AsDict, new Templates.ServerWindow().AsDict]
  }]


window.goldenLayout = new window.GoldenLayout(config)
## CONFIG/DECLARE END



## REGISTER GoldenLayout Components
window.goldenLayout.registerComponent('ChannelWindow', (container, state) ->
  container._config.title = state.room
  channelWindow = document.querySelector('#templates > [name="channelWindow"]').cloneNode(true)
  container.getElement().html(channelWindow)
)


window.goldenLayout.registerComponent('PrivateWindow', (container, state) ->
  container._config.title = state.room
  privateWindow = document.querySelector('#templates > [name="privateWindow"]').cloneNode(true)
  container.getElement().html(privateWindow)

  getDataAndClean = ->
    msg = privateWindow.querySelector("input").value
    window.sendFunction(msg, state.room)
    privateWindow.querySelector("input").value = ""

    window.appendToRoom(state.room, {who: "", trailer: msg, params: [state.room]})

    privateWindow.querySelector(".output").scrollTop = privateWindow.querySelector(".output").scrollHeight

  privateWindow.querySelector("button").onclick = ->
    getDataAndClean()

  privateWindow.querySelector("input").onkeyup = (event) ->
    if ( event.which == 13 )
      getDataAndClean()

)


window.goldenLayout.registerComponent('MenuWindow', (container, state) ->
  menu = document.querySelector('#templates > [name="menu"]').cloneNode(true)
  container.getElement().html(menu)

  server = container.getElement()[0].querySelector('input[name="server"]')
  port = container.getElement()[0].querySelector('input[name="port"]')
  user = container.getElement()[0].querySelector('input[name="user"]')
  nick = container.getElement()[0].querySelector('input[name="nick"]')
  channel = container.getElement()[0].querySelector('input[name="channel"]')
  joinOnConnect = container.getElement()[0].querySelector('input[name="joinOnConnect"]')

  container.getElement()[0].querySelector('button[name="connect"]').onclick = ->
    if joinOnConnect.checked
      main("#{server.value}:#{port.value}", user.value, nick.value, channel.value)
    else
      main("#{server.value}:#{port.value}", user.value, nick.value)



  container.getElement()[0].querySelector('button[name="join"]').onclick = ->
    sendFunction("/join #{channel.value}")
    channel.value = ""
)
## REGISTER END



## INIT GoldenLayout
window.goldenLayout.init()
## INIT END



## FUNCTIONS ch6t
window.openChannelWindow = (roomname) ->
  ###
  this creates or returns a handle to the
  chat window / channel `roomname`
  ###
  if window.goldenLayout.root.getItemsById(roomname).length == 0
    # there is no room widged, create one
    room = new window.Templates.PrivateWindow().AsDict
    room.id = roomname
    room.title = roomname
    room.componentState.room = roomname
    window.goldenLayout.root.contentItems[0].addChild(room)
    return window.goldenLayout.root.getItemsById(roomname)[0]
  else
    # there is a room name `roomname`
    # just return the handle
    return window.goldenLayout.root.getItemsById(roomname)[0]

window.sendFunction = (msg, room) ->
  if msg.trim().startsWith("/")
    window.connection.send(msg[1..] + "\n")
  else
    window.connection.send("privmsg #{room} :#{msg}\n")
## FUNCTIONS END
