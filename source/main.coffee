# The complete package, runtime + compiler

extend = Object.assign

CoffeeScript = require "coffeescript"
Jadelet = require "./runtime"
Jadelet.compile = require "./compiler"

{jsdom} = require("jsdom/lib/old-api.js")
document = jsdom()
{Event} = window = document.defaultView

{compile, Observable} = Jadelet


extend global,
  document: document
  Jadelet: Jadelet
  Node: window.Node
  Observable: Observable
  Runtime: Jadelet


Jadelet.makeTemplate = (code) ->
  compiled = compile code,
    runtime: "Jadelet"
    compiler: CoffeeScript
    exports: false
    mode: "jade" # TODO: Jadelet will be the only mode

  Function("Jadelet", "return " + compiled)(Jadelet)

module.exports = Jadelet
