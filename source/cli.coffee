fs = require "fs"
npath = require "path"
stdin = require "stdin"
compile = require '../dist/compiler'
# wrench = require "wrench"
klawSync = require "klaw-sync"
CoffeeScript = require "coffeescript"
md5 = require 'md5'


cli = require("commander")
  .version(require('../package.json').version)
  .option("-a, --ast", "Output AST")
  .option("-d, --directory [directory]", "Compile all .jadelet files in the given directory")
  .option("--encoding [encoding]", "Encoding of files being read from --directory (default 'utf-8')")
  .option("-e, --exports [name]", "Export compiled template as (default 'module.exports'")
  .option("-x, --extension [extension]", "Extension to compile")
  .option("-r, --runtime [provider]", "Runtime provider")
  .option("-6, --es6", "ES6")
  .parse(process.argv)

encoding = cli.encoding or "utf-8"
cliJSON = JSON.stringify cli

if cli.extension
  extension = new RegExp "\\.#{cli.extension}$"
else
  extension = /\.jade(let)?$/
es = no
es6 = yes if cli.es6

if (dir = cli.directory)
  # Ensure exactly one trailing slash
  dir = dir.replace /\/*$/, "/"

  files = klawSync(dir)

  files.forEach (ff) ->
    {path} = ff
    # bpath = npath.basename path
    # console.log ff, path, npath.basename path
    inPath = "#{path}" #{}"#{dir}#{bpath}"

    if fs.lstatSync(inPath).isFile()
      if inPath.match(extension)
        basePath = inPath.replace extension, ""
        outPath = "#{basePath}.js"
        md5Path = "#{basePath}.md5"

        # ignore md5 if the output does not exist
        if fs.existsSync(outPath) and fs.existsSync(md5Path)
          prevMD5 = fs.readFileSync md5Path, encoding: encoding

        input = fs.readFileSync inPath,
          encoding: encoding

        # if the options change, the prevMD5 is invalid
        currMD5 = md5(input + cliJSON)
        if currMD5 != prevMD5
          console.log "Compiling #{inPath} to #{outPath}"
          # Replace $file in exports with path
          if cli.exports
            exports = cli.exports.replace("$file", basePath)

          program = compile input,
            runtime: cli.runtime
            exports: exports
            compiler: CoffeeScript
            es6: es6

          fs.writeFileSync(outPath, program)
          fs.writeFileSync(md5Path, currMD5)
        else
          console.log "Skipping #{inPath} (no changes)"

else
  stdin (input) ->

    if cli.ast
      process.stdout.write JSON.stringify(input)

      return

    else
      process.stdout.write compile input,
        mode: cli.mode
        runtime: cli.runtime
        exports: cli.exports
        compiler: CoffeeScript
        es6: es6
