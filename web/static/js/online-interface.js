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
  app.ports.scrollLastChildIntoView.subscribe(_scrollLastChildIntoView)
}

function _scrollLastChildIntoView(id) {
  const node = document.getElementById(id)
  const lastChild = node && node.children[node.children.length - 1]

  if (lastChild) {
    lastChild.scrollIntoView()
  }
}

export default OnlineInterface
