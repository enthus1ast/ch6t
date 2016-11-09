window.MAX_HISTORY = 20 # the maximal history lenght for each room


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
    if msg.trim() == ""
      return
    window.sendFunction(msg, state.room)
    privateWindow.querySelector("input").value = ""
    window.appendToRoom(state.room, {who: window.ownUsername, trailer: msg, params: [state.room]})
    window.scrollElement(privateWindow.querySelector(".output"))


    # add to send history
    window.rooms[state.room].history.push(msg)
    if window.rooms[state.room].history.length > MAX_HISTORY # if we are over the maximal history the user wants to save
      window.rooms[state.room].history.shift() # remove the first item
    window.rooms[state.room].actualHistoryPosition = 0 # reset the position on send


  # privateWindow.addEventListener("resize", () ->
    # console.log("resize")
  # )

  # $(privateWindow).resize(() ->
  #   console.log("resize")
  # )

  window.onresize = (event) ->
    window.scrollElement(document.querySelectorAll('.output'))
    return

  privateWindow.querySelector("button").onclick = ->
    console.log(privateWindow)
    # console.log(privateWindow.querySelector(".lm_item"))
    getDataAndClean()

  privateWindow.querySelector("input").onkeyup = (event) ->
    if ( event.which == 13 ) # enter
      getDataAndClean()
    else if ( event.which == 38) # up
      # History for the input line
      if window.rooms[state.room].actualHistoryPosition < window.rooms[state.room].history.length
        window.rooms[state.room].actualHistoryPosition += 1
        historyItem =  window.rooms[state.room].history[ window.rooms[state.room].history.length - window.rooms[state.room].actualHistoryPosition ]
        privateWindow.querySelector("input").value = historyItem
      # console.log("up key pressed", window.rooms[state.room].actualHistoryPosition)
    else if ( event.which == 40) # down
      # History for the input line
      if window.rooms[state.room].actualHistoryPosition > 0
        window.rooms[state.room].actualHistoryPosition -= 1
        historyItem =  window.rooms[state.room].history[ window.rooms[state.room].history.length - window.rooms[state.room].actualHistoryPosition ]
        privateWindow.querySelector("input").value = historyItem or ""
      # console.log("down key pressed", window.rooms[state.room].actualHistoryPosition)
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
      window.main("#{server.value}:#{port.value}", user.value, nick.value, channel.value)
    else
      window.main("#{server.value}:#{port.value}", user.value, nick.value)



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
  if roomname not in rooms and window.goldenLayout.root.getItemsById(roomname).length == 0
    # there is no room widged, create one
    room = new window.Templates.PrivateWindow().AsDict
    room.history = []
    room.id = roomname
    room.title = roomname
    room.componentState.room = roomname
    room.actualHistoryPosition = 0
    rooms[room.title] = room

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


window.goldenLayout.on( "itemDestroyed" , (component,b,c,d) ->
  if component.componentName == "PrivateWindow"
    roomname = component.config.componentState.room
    window.connection.send("PART #{roomname}\n")
    delete(window.rooms[roomname]) # we remove the room from the room list
,null)

window.goldenLayout.on("activeContentItemChanged ", (a,b,c,d) ->
  console.log(a,b,c,d)
,null)
