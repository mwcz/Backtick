class Options
  commandLookup: {}
  importedCommands: []
  importedCommandIds: []

  constructor: ->
    chrome.storage.sync.get (sync) =>
      chrome.storage.local.get (local) =>
        @init sync: sync, local: local

  init: (storage) ->
    @$hotkeyInput = $ "#hotkey"
    @$hotkeyInput.val storage.sync.hotkey or "`"

    @importedCommandIds = storage.sync.importedCommandIds or []
    @importedCommands = storage.local.importedCommands or []

    @commandLookup[command.gistID] = command for command in @importedCommands

    @fetchUnimportedCommands()

    @$hotkeyInput.on "keypress", (e) =>
      e.preventDefault()
      return if [13, 32].indexOf(e.which) isnt -1

      char = String.fromCharCode e.which
      @$hotkeyInput.val char
      @setHotkey char

  _setHotkey = (char) -> chrome.storage.sync.set "hotkey": char
  setHotkey: _.debounce _setHotkey, 250

  fetchUnimportedCommands: ->
    for id in @importedCommandIds
      continue if @commandLookup[id]
      @importGist id, error: console.log.bind(console)

  mergeImportedCommands: (command) ->
    if @commandLookup[command.gistID]
      $.extend @commandLookup[command.gistID], command
    else
      @importedCommands.push command
      chrome.storage.local.set "importedCommands": @importedCommands

  importGist: (id, {error}) ->
    $.getJSON("https://api.github.com/gists/#{id}")
      .error(-> error? "Unable to get Gist with id #{id}")
      .success((data) =>
        command = @commandFromGist data
        return error?(command.error) if command.error
        @mergeImportedCommands command
      )

  commandFromGist: (gist) ->
    return { error: "Missing command.js" } unless gist?.files?["command.js"]
    return { error: "Missing command.json" } unless gist?.files?["command.json"]

    try
      json = JSON.parse gist.files["command.json"].content
    catch e
      return { error: "The command.json file is not a valid JSON file" }

    return { error: "Command name missing" } unless json.name
    return { error: "Command description missing" } unless json.description

    {
      gistID: gist.id
      name: json.name
      description: json.description
      icon: json.icon
      link: json.link
      src: gist.files["command.js"].raw_url
    }

new Options