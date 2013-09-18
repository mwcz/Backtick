require [
  "app"
  "actions"
  "lib/extension"
  "lib/handlebars-helpers"
], (App) ->
  window._BACKTICK_LOADED = true
  if chrome.storage
    chrome.storage.local.get App.start.bind(App)
  else
    App.start()

  require(["local-setup"]) if App.env is "development"
