
window.lastSentPing = 0
window.lastSeenPong = 0
window.PING_INTERVAL = 60 * 1000
window.PING_TIMEOUT = window.PING_INTERVAL * 2 # seconds

# new Date().getTime()

window.reconnectOnPingTimeout = ->
  setTimeout(->
    if new Date().getTime() - window.lastSeenPong > PING_INTERVAL
      window.connection.send("PING :ch6t_#{new Date().getTime()}\n")
    if new Date().getTime() - window.lastSeenPong > PING_TIMEOUT
      console.log("WE HAVE TIMEOUTEDD!!!!!!!!")
    window.reconnectOnPingTimeout()
  ,
  window.PING_INTERVAL)


## FUNCTIONS IRC
window.parseIncoming = (rawline) ->
  result = {}
  headerPart = ""
  line = rawline.trim()
  if line.startsWith(":")
    line = line[1..]
    result.who = line.split(" ")[0]
    line = line[result.who.len + 1..]

  if line.search(" :") != -1 # Read trailer
    result.trailer = line.split(" :")[1..].join(" :")
    headerPart = line.split(" :")[0]   # TODO bug wenn " :" geschrieben wird??
  else
    result.trailer = ""
    headerPart = line
  lineParts = removeDoubleWhite(headerPart).trim().split(" ")
  result.command = lineParts[1] # todo parse if command is valide
  result.params = lineParts[2..]
  result.raw = rawline
  return result

window.splitUser = (who) ->
  if "!" in who
    parts = who.split("!")
    nick = parts[0]
    moreInfo = parts[1]
    return {
      nick: nick
      moreInfo: moreInfo
    }
  else
    return {
      nick: who
      moreInfo: ""
    }


window.appendStatusMessage = (room, msg) ->
  ###
  appends a custom status message to the given room.
  use this to let the client (ch6t) to inform the user that he has
  eg: joined, renamed, left etc etc
  ###
  ircLineIn = {
    who: ":ch6t:"
    params: [room]
    trailer: msg
  }
  window.appendToRoom(room, ircLineIn)


window.appendToRoom = (room, ircLineIn) ->
  ###
  this appends a ircLineIn to a room window,
  query the room
  ###

  # generate the line
  recvDateObj = new Date()
  nickname = splitUser(ircLineIn.who).nick
  recvTime = "#{pad(recvDateObj.getHours(), 2)}:#{pad(recvDateObj.getMinutes(), 2)}"
  line = "[#{recvTime}] <#{nickname}> #{ircLineIn.trailer}"
  roomDom = window.openChannelWindow(room)

  div = document.createElement('div')
  # div.innerText = line.autoLink()
  div.innerHTML = escapeHtml(line).autoLink(
    callback: (url) ->
      url = decodeURI(url)
      if /\.(gif|png|jpe?g)$/i.test(url)
        return '<img src="' + url + '">'

      if /\.(mp4|avi|webm|flv|mkv)$/i.test(url)
        return '<video src="' + url + '" controls>'

      if /\.(mp3|wav|ogg|opus)$/i.test(url)
        return '<audio src="' + url + '" controls>'
  )

  #if we where mentioned in a message we highlight it
  console.log(ircLineIn.trailer)
  if ircLineIn.trailer.search(window.ownUsername) != -1
    # alert("mentioned")
    div.style.backgroundColor = computeColor(nickname)
    div.style.color = "#101919"
  else
    div.style.color = computeColor(nickname)

  roomDomOutput = roomDom.element[0].querySelector('.output')
  roomDomOutput.appendChild(div)
  window.scrollElement(roomDomOutput)
  return
  # roomDomOutput.scrollTop = roomDomOutput.scrollHeight
## FUNCTIONS END

## MAIN Function
window.main = (server, user, nick, channel) ->
  serverWindow = goldenLayout.root.getItemsById('server')
  serverWindowOutput = serverWindow[0].element[0].querySelector('.output')
  window.connection = new WebSocket("ws://#{server}", ['irc'])
  window.ownUsername = "" # this is our username, we try to change this value on T001 and on TNick
  window.rooms = {
    name: {
      users: [],   # this is just an example
      history: []     # this is just an example
    }
  }

  window.connection.onopen = ->
    window.connection.send("USER #{user} * * *\n")
    window.connection.send("NICK #{nick}\n")
    window.connection.send('PONG :t\n')
    if channel?
      console.log "JOIN #{channel}\n"
      window.connection.send("JOIN #{channel}\n")
    window.reconnectOnPingTimeout()

  window.connection.onmessage = (event) ->
    console.log('Server: ' + event.data)
    ircLineIn = parseIncoming(event.data)
    console.log(ircLineIn)

    div = document.createElement('div')
    div.innerText = event.data
    serverWindowOutput.appendChild(div)
    window.scrollElement(serverWindowOutput)

    # handle ping
    if event.data.startsWith("PING")
      console.log("send pong reply")
      pongReply = "PONG" + event.data.slice(4) + "\n"
      window.connection.send(pongReply)

    if ircLineIn.command == "PRIVMSG"
      # we have to open a chat if none was opened yet.
      # if a corresponding chatwindow was opened
      # we just append the privmsg to this window
      bing("msg")
      window.lastSeenPong = new Date().getTime()
      console.log("Reset lastSeenPong to: #{window.lastSeenPong}")
      if ircLineIn.params[0].startsWith("#") or ircLineIn.params[0].startsWith("&")
        # this is a msg to a room
        console.log("msg to room")
        appendToRoom(ircLineIn.params[0], ircLineIn)
      else
        # this is a message directly to us.
        console.log("private msg")
        appendToRoom(splitUser(ircLineIn.who).nick,ircLineIn)

    if ircLineIn.command == "JOIN"
      # server let us join a room
      openChannelWindow(ircLineIn.params[0])
      appendStatusMessage(ircLineIn.params[0], m("join", ircLineIn.who , ircLineIn.params[0]))
      bing("join")

    if ircLineIn.command == "PART"
      # we write in the room
      # that the user has left
      # :klausuggu PART #lobby
      appendStatusMessage(ircLineIn.params[0], m("part", ircLineIn.who, ircLineIn.params[0]))
      bing("leave")

    if ircLineIn.command == "NICK"
      # :ha NICK :sn0re
      # TODO atm we don't know wich user are in the channels
      # so we dont know to wich channel we should post this message
      if ircLineIn.who == ownUsername
        # we have change our name
        window.ownUsername = ircLineIn.trailer
      else
        console.log("someone changed his nick")

    if ircLineIn.command == "353"
      # answer to NAMES
      # make every username colorfull
      # for name in ircLineIn.trailer.split(" ")
      #   span = document.createElement("span")
      #   span.style.color = computeColor(name)
      #   span.innerText = name
      #   appendStatusMessage(ircLineIn.params[2], m("353", span.toString() ))
      appendStatusMessage(ircLineIn.params[2], m("353", ircLineIn.trailer ))

    if ircLineIn.command == "001"
      # normally the first param should be our username
      # if ircLineIn.paras.length > 0
      window.ownUsername = ircLineIn.params[0]
      window.lastSeenPong = new Date().getTime()

    if ircLineIn.command == "PONG" #or ircLineIn.command == "PING"
      # we receive a pong reply from the server
      # this means we have sent a ping before
      window.lastSeenPong = new Date().getTime()

## MAIN END
