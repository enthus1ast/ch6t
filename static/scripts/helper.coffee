window.computeColor  = (str) ->
  commulated=0;
  for i in [0..str.length-1]
    commulated = commulated + str.charCodeAt(i)
  communist = commulated%235 + 20
  r = communist
  g = Math.pow(communist,2)%255
  b = Math.pow(communist,3)%255
  return "rgb(#{r},#{g},#{b})"


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


window.removeDoubleWhite = (line) ->
  if line.search("  ") != -1
    removeDoubleWhite(line.replace("  "," "))
  else
    return line
