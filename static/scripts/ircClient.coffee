# countdown = (num for num in [10..1199])


# class Channels
# class Channel

document.addEventListener('DOMContentLoaded', ->

  server = myLayout.root.getItemsById('server')[0]
  serverOutput = server.element[0].querySelector('.output')

  # window.ownUsername = ""

  window.removeDoubleWhite = (line) ->
    if line.search("  ") != -1
      removeDoubleWhite(line.replace("  "," "))
    else
      return line

  window.parseIncoming = (rawline) -> 
    result = {}
    headerPart = ""
    line = rawline.trim()
    if line.startsWith(":")
      line = line[1..]
      result.who = line.split(" ")[0]
      line = line[result.who.len+1..]

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


  window.appendToRoom = (room,ircLineIn) ->
    ## this appends a ircLineIn to a room window,
    ## query the room

    ## generate the line
    recvDateObj = new Date()
    recvTime = "#{recvDateObj.getHours()}:#{recvDateObj.getMinutes()}"
    line = "[#{recvTime}] <#{ircLineIn.who}> #{ircLineIn.trailer}"
    # roomDom = openChatWindow(ircLineIn.params[0])
    roomDom = openChatWindow(room)

    div = document.createElement('div')
    div.innerText = line

    roomDomOutput = roomDom.element[0].querySelector('.output')
    roomDomOutput.appendChild(div)
    roomDomOutput.scrollTop = roomDomOutput.scrollHeight    

    ## append to window

  window.appendStatusMessage = (room,msg) ->
    ## appends a custom status message to the given room.
    ## use this to let the client (ch6t) to inform the user that he has
    ## eg: joined, renamed, left etc etc
    ircLineIn = {
      who: ":ch6t:"
      params: [room]
      trailer: msg
    }
    appendToRoom(room, ircLineIn)

  main = (server, user, nick) -> 
    window.connection = new WebSocket('ws://' + server, ['irc'])

    connection.onopen = ->
      connection.send("USER #{user} * * *\n")
      connection.send('NICK ' + nick + '\n')
      connection.send('PONG :t\n');
      connection.send('join #lobby\n');
      # connection.send('privmsg #lobby :Gude vom web haha!\n');

    connection.onmessage = (event) ->
      console.log('Server: ' + event.data)
      ircLineIn = parseIncoming(event.data)
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
        connection.send(pongReply)

      if ircLineIn.command == "PRIVMSG"
        ## we have to open a chatwindow
        ## if none was opened yet.
        ## if a corresponding chatwindow was opened 
        ## we just append the privmsg to this window
        if ircLineIn.params[0].startsWith("#") or ircLineIn.params[0].startsWith("&")
          # this is a msg to a room
          console.log("msg to room")          
          appendToRoom(ircLineIn.params[0], ircLineIn)
        else
          # this is a message directly to us.
          console.log("private msg")
          appendToRoom(ircLineIn.who,ircLineIn)

      if ircLineIn.command == "JOIN"
        ## server let us join a room
        # appendToRoom(ircLineIn.params[0], ircLineIn)    
        openChatWindow(ircLineIn.params[0])
        # m("quit")
        appendStatusMessage(ircLineIn.params[0], m("join", ircLineIn.who , ircLineIn.params[0]))
        
      if ircLineIn.command == "PART"
        ## we write in the room
        ## that the user has left
        ## :klausuggu PART #lobby
        appendStatusMessage(ircLineIn.params[0], m("part", ircLineIn.who, ircLineIn.params[0]))

      if ircLineIn.command == "NICK"
        ## :ha NICK :sn0re
        ## TODO atm we don't know wich user are in the channels
        ## so we dont know to wich channel we should post this message
        console.log("NICK not implemented yet")

      if ircLineIn.command == "353"
        ## answer to NAMES
        # :ch4t.code0.xyz 353 astoll @ #lobby :dkrause astoll fla
        # appendStatusMessage(ircLineIn.params[2], ircLineIn.trailer ) # m("353", ircLineIn.who, ircLineIn.params[0]))
        appendStatusMessage(ircLineIn.params[2],  m("353", ircLineIn.trailer )) # m("353", ircLineIn.who, ircLineIn.params[0]))

  main("127.0.0.1:7787","asd","astoll")
)
