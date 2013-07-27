activeTab = null

window.Events = {
  sendTrigger: (eventName, eventData) ->
    chrome.tabs.sendMessage activeTab?.id, { event: eventName, data: eventData }
}

Events.$ = $ Events
chrome.runtime.onMessage.addListener (req) ->
  window.Events.$.trigger(req.event, req.data) if req.event

chrome.browserAction.onClicked.addListener (tab) ->
  activeTab = tab
  chrome.tabs.executeScript null, {
    code: "chrome.runtime.sendMessage({
      event: 'open.app',
      data: window._BACKTICK_LOADED
    });"
  }

Events.$.on
  "open.app": (e, loaded) ->
    if loaded
      Events.sendTrigger "toggleClose"
    else
      chrome.tabs.insertCSS null, file: "styles/main.css"
      chrome.tabs.executeScript null, file: "vendor/requirejs/require.js"
      chrome.tabs.executeScript null, file: "scripts/app.js"

  "ready.app": ->
    CommandStore.init()

  "execute.commands": (e, src) ->
    $.ajax
      url: src
      success: (response) ->
        url = "javascript:#{response}"
        chrome.tabs.update activeTab.id, {url: url}, ->
          Events.sendTrigger "executed.commands"

      error: console.log.bind(console, "error")