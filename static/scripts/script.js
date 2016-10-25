// Generated by CoffeeScript 1.11.1
(function() {
  var channelWindow, chatWin, serverWindow, serverWindow2, userlistWin, writeWin;

  writeWin = {
    type: 'component',
    componentName: 'channelWindow',
    isClosable: false,
    reorderEnabled: false,
    showPopoutIcon: false,
    showCloseIcon: false,
    showMaximiseIcon: false,
    componentState: {
      room: 'writeWin'
    }
  };

  chatWin = {
    type: 'component',
    componentName: 'channelWindow',
    showPopoutIcon: false,
    showCloseIcon: false,
    isClosable: false,
    reorderEnabled: true,
    showMaximiseIcon: false,
    componentState: {
      room: 'chatWin'
    }
  };

  window.chatWin2 = {
    id: 'server',
    type: 'component',
    componentName: 'privateWindow',
    showPopoutIcon: false,
    showCloseIcon: false,
    isClosable: false,
    reorderEnabled: true,
    showMaximiseIcon: false,
    componentState: {
      room: 'chatWin'
    }
  };

  userlistWin = {
    type: 'component',
    width: 20,
    componentName: 'channelWindow',
    componentState: {
      room: 'userlistWin'
    }
  };

  serverWindow = {
    type: "column",
    content: [
      {
        type: "column",
        componentName: 'channelWindow',
        content: [
          {
            type: "row",
            content: [chatWin]
          }
        ]
      }
    ]
  };

  serverWindow2 = {
    type: "column",
    content: [
      {
        type: "column",
        content: [
          {
            type: "row",
            content: [chatWin2]
          }
        ]
      }
    ]
  };

  channelWindow = {
    type: "column",
    content: []
  };

  window.menu = {
    type: 'component',
    componentName: 'menu',
    height: 10,
    componentState: {}
  };

  window.config = {
    settings: {
      hasHeaders: true,
      showPopoutIcon: false
    },
    content: [
      {
        type: 'column',
        content: [menu, serverWindow2]
      }
    ]
  };

  window.myLayout = new GoldenLayout(config);

  myLayout.registerComponent('channelWindow', function(container, state) {
    container._config.title = state.room;
    channelWindow = document.querySelector('#templates > .channelWindow').cloneNode(true);
    return container.getElement().html(channelWindow);
  });

  window.openChatWindow = function(roomname) {
    var newRoom;
    if (myLayout.root.getItemsById(roomname).length === 0) {
      newRoom = chatWin2.valueOf();
      newRoom.id = roomname;
      newRoom.title = roomname;
      newRoom.componentState.room = roomname;
      myLayout.root.contentItems[0].addChild(newRoom);
      return myLayout.root.getItemsById(roomname)[0];
    } else {
      return myLayout.root.getItemsById(roomname)[0];
    }
  };

  window.sendFunction = function(msg, room) {
    if (msg.trim().startsWith("/")) {
      return connection.send(msg.slice(1) + "\n");
    } else {
      return connection.send("privmsg " + room + " :" + msg + "\n");
    }
  };

  myLayout.registerComponent('privateWindow', function(container, state) {
    var getDataAndClean, privateWindow;
    container._config.title = state.room;
    privateWindow = document.querySelector('#templates > .privateWindow').cloneNode(true);
    getDataAndClean = function() {
      var div, msg;
      msg = privateWindow.querySelector("input").value;
      sendFunction(msg, state.room);
      privateWindow.querySelector("input").value = "";
      div = document.createElement('div');
      div.innerText = msg;
      privateWindow.querySelector(".output").appendChild(div);
      return privateWindow.querySelector(".output").scrollTop = privateWindow.querySelector(".output").scrollHeight;
    };
    privateWindow.querySelector("button").onclick = function() {
      return getDataAndClean();
    };
    privateWindow.querySelector("input").onkeyup = function(event) {
      if (event.which === 13) {
        return getDataAndClean();
      }
    };
    return container.getElement().html(privateWindow);
  });

  myLayout.registerComponent('menu', function(container, state) {
    console.log(container);
    return container.getElement().html("<div id=\"newTemplateMenu\" class=\"templateMenu\">\n  ch6t\n  <input type=\"text\" placeholder=\"User..\"><!--\n  --><input type=\"text\" placeholder=\"Nick..\"><!--\n  --><button>Connect</button><!--\n  --><input type=\"text\" placeholder=\"Room..\"><!--\n  --><button>Join</button>  \n</div>");
  });

  myLayout.init();

}).call(this);
