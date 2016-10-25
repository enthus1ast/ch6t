# config = {
#   settings: {
#     showPopoutIcon: false,
#   },
#   content: [{
#     type: 'row',
#     content: [
#       # {
#         # type: 'row',
#         # content: [{type:'component', componentName: 'channelWindow', title: "server"},{type:'component', componentName: 'channelWindow' , title: "server"}]
#         # }, {

#         # type: 'row',
#         # content: [{type:'component', componentName: 'channelWindow' , title: "server"}]
#         # },        

#       {
#         type:'component',
#         isClosable: false,
#         componentName: 'channelWindow',
#         title: "server",
#         id: "testoi",
#         componentState: {
#           room: 'server'
#         }
#       }
#       #  ,
#       #   {
#       #   type:'component',
#       #   componentName: 'channelWindow',
#       #   title: "#lobby",
#       #   componentState: { room: '#lobby' }
#       #   },
#       # {
#       #   type:'component',
#       #   componentName: 'channelWindow',
#       #   componentState: { room: '#coden' }
#       #   },
#       # {
#       #   type:'component',
#       #   componentName: 'channelWindow',
#       #   componentState: { room: '#pornos' }
#       #   }
#     ]
#   }]
# }





# config = {
#   content: [{
#     type: 'row',
#     content: [{
#       type: 'component',
#       componentName: 'channelWindow',
#       componentState: { room: 'A' }
#     },{
#       type: 'column',
#       content: [{
#         type: 'component',
#         componentName: 'channelWindow',
#         componentState: { room: 'B' }
#       },{
#         type: 'component',
#         componentName: 'channelWindow',
#         componentState: { room: 'C' }
#       }]
#     }]
#   }]
# }

`window.clone = function (obj) {
    if(obj == null || typeof(obj) != 'object')
        return obj;    
    var temp = new obj.constructor(); 
    for(var key in obj)
        temp[key] = clone(obj[key]);    
    return temp;
}`

writeWin = {
  type: 'component',
  componentName: 'channelWindow',
  isClosable: false
  reorderEnabled:false
  showPopoutIcon: false
  showCloseIcon: false  
  showMaximiseIcon: false
  componentState: { room: 'writeWin' }  
}

chatWin = {
  type: 'component',
  componentName: 'channelWindow',
  showPopoutIcon: false
  showCloseIcon: false
  isClosable: false
  reorderEnabled:true
  showMaximiseIcon: false
  componentState: { room: 'chatWin' }  
}
window.chatWin2 = {
  id: 'server',
  type: 'component',
  componentName: 'privateWindow',
  showPopoutIcon: false
  showCloseIcon: false
  isClosable: false
  reorderEnabled:true
  showMaximiseIcon: false
  componentState: { room: 'chatWin' }  
}

userlistWin = {
  type: 'component'
  width: 20
  componentName: 'channelWindow',
  componentState: { room: 'userlistWin' }  
}


serverWindow = {
  type: "column"
  content:[
    {
      type: "column"
      componentName: 'channelWindow',      
      content: [
        {
          type: "row"
          content: [chatWin]
        },
        # {
        #   type: "row"
        #   height: 20,
        #   content: [writeWin]
        # }
      ]
    }
  ]
}
serverWindow2 = {
  type: "column"
  content:[
    {
      type: "column"
      content: [
        {
          type: "row"
          content: [chatWin2]
        },
        # {
        #   type: "row"
        #   height: 20,
        #   content: [writeWin]
        # }
      ]
    }
  ]
}


channelWindow = {
  type: "column"
  content: []
}


window.menu = {
  type: 'component'
  componentName: 'menu'  
  height: 10
  componentState: { }  

}

window.config = {
  settings: {
      hasHeaders: true
      showPopoutIcon: false
    }       
  content: [
    {
    type: 'column'
    # content: [menu,serverWindow,serverWindow2,serverWindow]
    content: [menu,serverWindow2]
    }
  ]
}

window.myLayout = new GoldenLayout(config)

myLayout.registerComponent('channelWindow', (container, state) ->
  container._config.title = state.room
  channelWindow = document.querySelector('#templates > .channelWindow').cloneNode(true);
  container.getElement().html(channelWindow)
)

window.openChatWindow = (roomname) ->
  ## this creates or returns a handle to the 
  ## chat window / channel `roomname`
  if myLayout.root.getItemsById(roomname).length == 0
    ## there is no room, create one


    # TODO BUG BUG this is not copying by value der hurensohn
    # newRoom = chatWin2.valueOf()  # new copy of private msg TODO atm no channel rooms 
    # how the fucking fuck is one copying a object by value.
    # JSON.stringify and JSON.parse works bug this if fuck as fuck
    newRoom = clone(chatWin2)


    newRoom.id = roomname
    newRoom.title = roomname
    newRoom.componentState.room = roomname
    myLayout.root.contentItems[0].addChild(newRoom)
    return myLayout.root.getItemsById(roomname)[0]
    # return newRoom
  else
    ## there is a room name `roomname`
    ## just return the handle
    return myLayout.root.getItemsById(roomname)[0]

window.sendFunction = (msg,room) ->
  if msg.trim().startsWith("/")
    connection.send(msg[1..] + "\n")
  else
    connection.send("privmsg #{room} :#{msg}\n")


myLayout.registerComponent('privateWindow', (container, state) ->
  container._config.title = state.room
  privateWindow = document.querySelector('#templates > .privateWindow').cloneNode(true);
  
  getDataAndClean = ->
    msg = privateWindow.querySelector("input").value
    sendFunction(msg,state.room)
    privateWindow.querySelector("input").value = ""
    div = document.createElement('div')
    div.innerText = msg
    privateWindow.querySelector(".output").appendChild(div)
    privateWindow.querySelector(".output").scrollTop = privateWindow.querySelector(".output").scrollHeight
    
  privateWindow.querySelector("button").onclick = ->
    getDataAndClean()

  privateWindow.querySelector("input").onkeyup = (event) ->
    if ( event.which == 13 )
      getDataAndClean()
    
  container.getElement().html(privateWindow)
)

myLayout.registerComponent('menu', (container, state) ->
  console.log(container)
  # container._config.title = state.room
  # container.getElement().html()
  # chatWidget = 
  # writeWidget = ""
  # container.getElement().html( '<div>' + state.room + '</div>')
  # template = document.querySelector('#newTemplate');
  # container.getElement().html("ich bins menu")


  container.getElement().html("""<div id="newTemplateMenu" class="templateMenu">
    ch6t
    <input type="text" placeholder="User.."><!--
    --><input type="text" placeholder="Nick.."><!--
    --><button>Connect</button><!--
    --><input type="text" placeholder="Room.."><!--
    --><button>Join</button>  
  </div>""")
)

myLayout.init()

# myLayout.root.addChild(oneWidget)