define [
  "app"
  "views/console"
], (App, ConsoleView) ->
  class ConsoleActions
    constructor: ->
      App.on "action:displayConsole", @displayConsole.bind(this)

    displayConsole: ->
      setTimeout ( ->
        cw = new ConsoleView().render().in() #.focus()
        setTimeout (->
          setTimeout (-> $(".settings").addClass("in")), 750
          setTimeout (-> cw.focus() ), 1250
          $(".spinner").addClass("out")
        ), 2500
      ), 10000

  new ConsoleActions
