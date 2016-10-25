# countdown = (num for num in [10..1199])


# class Channels
# class Channel

document.addEventListener('DOMContentLoaded', ->

	server = myLayout.root.getItemsById('server')[0]
	serverOutput = server.element[0].querySelector('.output')

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

			div = document.createElement('div')
			div.innerText = event.data
			serverOutput.appendChild(div)
			# serverOutput.

			# handle ping 
			if event.data.startsWith("PING")
				console.log("send pong reply")
				pongReply = "PONG" + event.data.slice(4) + "\n"
				connection.send(pongReply)
			


	main("127.0.0.1:7787","asd","astoll")
	

)

