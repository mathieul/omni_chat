class OnlineInterface {
  constructor() {
    const node = document.getElementById('elm-main')

    this.app = Elm.Online.embed(node)
  }

  start(config) {
    setTimeout(() => _initApplication(this.app, config), 0)
  }
}

function _initApplication(app, config) {
  app.ports.initApplication.send(config)
  app.ports.scrollLastMessageIntoView.subscribe(_scrollLastMessageIntoView)
}

function _scrollLastMessageIntoView(time) {
  const node = document.getElementById("discussion-messages")
  const lastChild = node && node.children[node.children.length - 1]

  console.log(`_scrollLastMessageIntoView(${time}): node=${node}`)
  if (lastChild) {
    lastChild.scrollIntoView()
  }
}

export default OnlineInterface
