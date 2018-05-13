# The complete package, runtime + compiler

Jadelet = require "./runtime"
Jadelet.compile = require "./compiler"
{compile} = Jadelet
CoffeeScript = require "coffeescript"

{jsdom} = require("jsdom/lib/old-api.js")

document = jsdom()

Jadelet.makeTemplate = (code) ->
    compiled = compile code,
      runtime: "Runtime"
      compiler: CoffeeScript
      exports: false
      document: document
      mode: "jade" # TODO: Jadelet will be the only mode

    Function("Runtime", "return " + compiled)(Jadelet)


module.exports = Jadelet
