class OnlineInterface {
  constructor() {
    this.node = document.getElementById('elm-main')
    this.app = Elm.Online.embed(this.node)
  }

  start(config) {
    setTimeout(() => setupPorts(this.app, config), 0)
  }
}

function setupPorts(app, config) {
  app.ports.initApplication.send(config)
}

export default OnlineInterface
