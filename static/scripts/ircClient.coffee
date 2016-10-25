# countdown = (num for num in [10..1199])


# class Channels
# class Channel

document.addEventListener('DOMContentLoaded', ->

	server = myLayout.root.getItemsById('server')[0]
	serverOutput = server.element[0].querySelector('.output')

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
		  result.trailer = line.split(" :")[1..].join(" :") # TODO bug wenn " :" geschrieben wird??
		  headerPart = line.split(" :")[0]	 # TODO bug wenn " :" geschrieben wird??
		else
		  result.trailer = ""
		  headerPart = line	
		lineParts = removeDoubleWhite(headerPart).trim().split(" ")
		result.command = lineParts[1] # todo parse if command is valide
		result.params = lineParts[2..]
		result.raw = rawline
		return result


	main = (server, user, nick) -> 
		window.connection = new WebSocket('ws://' + server, ['irc'])
		# alert("foo")

		connection.onopen = ->
			connection.send('USER ' + user + ' * * *\n')
			connection.send('NICK ' + nick + '\n')
			connection.send('PONG :t\n');
			connection.send('join #lobby\n');
			# connection.send('privmsg #lobby :Gude vom web haha!\n');

		connection.onmessage = (event) ->
			console.log('Server: ' + event.data)
			console.log(parseIncoming(event.data))

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
			


	main("127.0.0.1:7787","asd","astoll")
	

)

