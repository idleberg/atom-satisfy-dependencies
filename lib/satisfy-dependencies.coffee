
# Dependencies
{CompositeDisposable} = require "atom"
{install} = require "atom-package-deps"
{join} = require "path"
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
      description: "Satisfies `dependencies` specified in a package manifest"
      type: "boolean"
      default: false
      order: 1
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

    atomPackageDependencies = atom.config.get("satisfy-dependencies.atomPackageDependencies")
    nodeDependencies = atom.config.get("satisfy-dependencies.nodeDependencies")

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
    install packageName

  installNodeDependencies: (loadedPackage) ->
    command = @getYarnPath()
    options = {cwd: loadedPackage.path}
    stdout = ""

    console.time "#{loadedPackage.name} upgraded"

    yarn = spawn command, ["upgrade", "--production"], options

    yarn.stdout.on 'data', (data) ->
      stdout += "#{data.toString()}\n" if atom.inDevMode()

    yarn.on 'close', ( errorCode ) ->
      if stdout.length > 0
        console.log stdout if atom.inDevMode()
      console.timeEnd "#{loadedPackage.name} upgraded"

  getYarnPath: ->
      join __dirname, "../node_modules/.bin/yarn"
