class OnlineInterface {
  constructor() {
    this.node = document.getElementById('elm-main')
    this.app = Elm.Online.embed(this.node)
  }

  start(config) {
    this.observerNodesAdded()
    setTimeout(() => _setupPorts(this.app, config), 0)
  }

  observerNodesAdded() {
    const observer = new MutationObserver(mutations => {
      for (const mutation of mutations) {
        mutation.addedNodes.forEach(_ensureLastDiscussionMessageIntoView)
      }
    })

    observer.observe(this.node, {childList: true, subtree: true})
  }
}

function _setupPorts(app, config) {
  app.ports.initApplication.send(config)
}

function _ensureLastDiscussionMessageIntoView(node) {
  const containerId = 'discussion-messages'

  if (node.id === containerId || node.parentNode.id == containerId) {
    document.body.scrollTop = document.body.scrollHeight
  }
}

export default OnlineInterface
