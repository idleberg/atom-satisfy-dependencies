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
    verboseMode:
      title: "Verbose Mode"
      description: "Output progress to the console"
      type: "boolean"
      default: false
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
    console.time "#{packageName} package dependencies" if atom.config.get("#{meta.name}.verboseMode") is true
    install(packageName).then ->
      console.timeEnd "#{packageName} package dependencies" if atom.config.get("#{meta.name}.verboseMode") is true

  installNodeDependencies: (loadedPackage) ->
    command = @getYarnPath()
    options = {cwd: loadedPackage.path}
    stdout = ""

    console.time "#{loadedPackage.name} Node dependencies" if atom.config.get("#{meta.name}.verboseMode") is true

    if platform() is "win32"
      yarn = spawn "cmd.exe", ["/c", command, "install", "--production"], options
    else
      yarn = spawn command, ["install", "--production"], options

    yarn.stdout.on 'data', (data) ->
      stdout += "#{data.toString()}\n" if atom.config.get("#{meta.name}.verboseMode") is true and atom.inDevMode()

    yarn.on 'close', ( errorCode ) ->
      if stdout.length > 0
        console.log stdout if atom.config.get("#{meta.name}.verboseMode") is true and atom.inDevMode()
      console.timeEnd "#{loadedPackage.name} Node dependencies" if atom.config.get("#{meta.name}.verboseMode") is true

  getYarnPath: ->
    if platform() is "win32"
      join __dirname, "..", "node_modules", ".bin", "yarn.cmd"
    else
      join __dirname, "..", "node_modules", ".bin", "yarn"
