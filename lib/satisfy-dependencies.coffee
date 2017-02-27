meta = require "../package.json"

# Dependencies
{CompositeDisposable} = require "atom"
{install} = require "atom-package-deps"
{join} = require "path"
{platform} = require "os"
{spawn} = require "child_process"

module.exports = SatisfyDependencies =
  config:
    atomPackageDependencies:
      title: "Atom Package Dependencies"
      description: "Satisfies `atom-package-deps` specified in a package manifest"
      type: "boolean"
      default: true
      order: 0
    nodeDependencies:
      title: "Node Dependencies"
      description: "*Experimental* &mdash; Satisfies `dependencies` specified in a package manifest"
      type: "boolean"
      default: false
      order: 1
    showPrompt:
      title: "Show Prompt"
      description: "Displays an prompt before installing packages"
      type: "boolean"
      default: false
      order: 2
    verboseMode:
      title: "Verbose Mode"
      description: "Output progress to the console"
      type: "boolean"
      default: false
      order: 3
  subscriptions: null

  activate: ->
    # Events subscribed to in atom"s system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add "atom-workspace", "satisfy-dependencies:all": => @satisfyDependencies()

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  satisfyDependencies: ->
    loadedPackages = atom.packages.getLoadedPackages()

    atomPackageDependencies = atom.config.get("#{meta.name}.atomPackageDependencies")
    nodeDependencies = atom.config.get("#{meta.name}.nodeDependencies")

    for loadedPackage in loadedPackages
      continue if atom.packages.isBundledPackage loadedPackage.name

      packageJson = join loadedPackage.path, "package.json"

      try
        packageMeta = require packageJson
      catch
        continue

      @installNodeDependencies(loadedPackage) if nodeDependencies
      @installAtomDependencies(loadedPackage.name) if atomPackageDependencies and packageMeta.hasOwnProperty("package-deps") is true

  installAtomDependencies: (packageName) ->
    console.time "[#{packageName}] install()" if atom.config.get("#{meta.name}.verboseMode") is true
    showPrompt = atom.config.get("#{meta.name}.showPrompt")
    install(packageName, showPrompt).then ->
      console.timeEnd "[#{packageName}] install()" if atom.config.get("#{meta.name}.verboseMode") is true

  installNodeDependencies: (loadedPackage) ->
    command = @getYarnPath()
    options = {cwd: loadedPackage.path}
    stdout = ""

    if platform() is "win32"
      yarn = spawn "cmd.exe", ["/c", command, "install", "--production", "--pure-lockfile"], options
    else
      yarn = spawn( command, ["install", "--production", "--pure-lockfile"], options)

    yarn.stdout.on 'data', (data) ->
      stdout += "#{data.toString()}\n" if atom.config.get("#{meta.name}.verboseMode") is true

    yarn.on 'close', ( errorCode ) ->
      if stdout.length > 0
        underline = "=".repeat loadedPackage.name.length
        console.log "#{loadedPackage.name}\n#{underline}\n#{stdout}" if atom.config.get("#{meta.name}.verboseMode") is true

  getYarnPath: ->
    if platform() is "win32"
      join __dirname, "..", "node_modules", ".bin", "yarn.cmd"
    else
      join __dirname, "..", "node_modules", ".bin", "yarn"
