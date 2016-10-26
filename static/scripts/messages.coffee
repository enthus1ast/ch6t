window.lang = "en"
window.messages = {}


window.m = (msg, param1, param2) ->
	messages.en = 
		"join": "#{param1} have joined channel #{param2}"
		"part": "#{param1} have left channel #{param2}"
		"nick": "'#{param1}' is now know as '#{param2}'"
		"quit": "Connection to server lost"

	# messages.de = 
	# 	"join": "Raum #{param1} betreten"
	# 	"part": "Raum #{param1} verlassen"
	# 	"nick": "'#{param1}' ist nun bekannt als '#{param2}'"
	# 	"quit": "Verbindung zu Server verloren"

	return messages[lang]?[msg]

