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
    }       
  content: [
    {
    type: 'column'
    content: [menu,serverWindow,serverWindow2,serverWindow]
    }
  ]
}


# config = {
#   content: [  ]
# }



window.myLayout = new GoldenLayout(config)

myLayout.registerComponent('channelWindow', (container, state) ->
  container._config.title = state.room
  channelWindow = document.querySelector('#templates > .channelWindow').cloneNode(true);
  container.getElement().html(channelWindow)
)

myLayout.registerComponent('privateWindow', (container, state) ->
  container._config.title = state.room
  privateWindow = document.querySelector('#templates > .privateWindow').cloneNode(true);
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