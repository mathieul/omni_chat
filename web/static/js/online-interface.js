class OnlineInterface {
  constructor() {
    this.node = document.getElementById('elm-main')
    this.app = Elm.Online.embed(this.node)
  }

  start(config) {
    this.observeNodesAdded()
    setTimeout(() => setupPorts(this.app, config), 0)
  }

  observeNodesAdded() {
    const observer = new MutationObserver(function (mutations) {
      for (const mutation of mutations) {
        mutation.addedNodes.forEach(scrollSoLastDiscussionMessageIsVisible)
      }
    })

    observer.observe(this.node, {childList: true, subtree: true})
  }
}

function setupPorts(app, config) {
  app.ports.initApplication.send(config)
}

function scrollSoLastDiscussionMessageIsVisible(node) {
  const containerId = 'discussion-messages'

  if (node.id === containerId || node.parentNode.id == containerId) {
    document.body.scrollTop = document.body.scrollHeight
  }
}

export default OnlineInterface
