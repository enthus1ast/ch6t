# countdown = (num for num in [10..1199])


# class Channels
# class Channel

document.addEventListener('DOMContentLoaded', ->

  server = window.myLayout.root.getItemsById('server')[0]
  serverOutput = server.element[0].querySelector('.output')

  window.removeDoubleWhite = (line) ->
    if line.search("  ") != -1
      window.removeDoubleWhite(line.replace("  "," "))
    else
      return line

  window.parseIncoming = (rawline) ->
    result = {}
    headerPart = ""
    line = rawline.trim()
    if line.startsWith(":")
      line = line[1..]
      result.who = line.split(" ")[0]
      line = line[result.who.len + 1..]

    if line.search(" :") != -1 # Read trailer
			# TODO bug wenn " :" geschrieben wird??
      result.trailer = line.split(" :")[1..].join(" :")
      headerPart = line.split(" :")[0]   # TODO bug wenn " :" geschrieben wird??
    else
      result.trailer = ""
      headerPart = line
    lineParts = window.removeDoubleWhite(headerPart).trim().split(" ")
    result.command = lineParts[1] # todo parse if command is valide
    result.params = lineParts[2..]
    result.raw = rawline
    return result


  window.appendToRoom = (room,ircLineIn) ->
    ## this appends a ircLineIn to a room window,
    ## query the room
    room = ""

    ## generate the line
    recvDateObj = new Date()
    recvTime = "#{recvDateObj.getHours()}:#{recvDateObj.getMinutes()}"
    line = "[#{recvTime}] <#{ircLineIn.who}> #{ircLineIn.trailer}"
    roomDom = window.openChannelWindow(ircLineIn.params[0])

    div = document.createElement('div')
    div.innerText = line

    roomDomOutput = roomDom.element[0].querySelector('.output')
    roomDomOutput.appendChild(div)
    roomDomOutput.scrollTop = roomDomOutput.scrollHeight

    ## append to window

  main = (server, user, nick) ->
    window.connection = new WebSocket('ws://' + server, ['irc'])

    window.connection.onopen = ->
      window.connection.send('USER ' + user + ' * * *\n')
      window.connection.send('NICK ' + nick + '\n')
      window.connection.send('PONG :t\n')
      window.connection.send('join #lobby\n')
      # connection.send('privmsg #lobby :Gude vom web haha!\n')

    window.connection.onmessage = (event) ->
      console.log('Server: ' + event.data)
      ircLineIn = window.parseIncoming(event.data)
      console.log(ircLineIn)

      div = document.createElement('div')
      div.innerText = event.data
      serverOutput.appendChild(div)
      serverOutput.scrollTop = serverOutput.scrollHeight
      # serverOutput.

      # handle ping
      if event.data.startsWith("PING")
        console.log("send pong reply")
        pongReply = "PONG" + event.data.slice(4) + "\n"
        window.connection.send(pongReply)

      if ircLineIn.command == "PRIVMSG"
        ## we have to open a chatwindow
        ## if none was opened yet.
        ## if a corresponding chatwindow was opened
        ## we just append the privmsg to this window
        console.log("we've got privmsg")
        window.appendToRoom(ircLineIn.params[0], ircLineIn)







  main("127.0.0.1:7787","asdfff","astollfff")


)
