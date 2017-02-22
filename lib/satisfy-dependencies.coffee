
# Dependencies
{CompositeDisposable} = require "atom"
{install} = require "atom-package-deps"
{join} = require "path"

module.exports = SatisfyDependencies =
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

    for loadedPackage in loadedPackages
      continue if atom.packages.isBundledPackage loadedPackage.name

      packageJson = path.join loadedPackage.path, "package.json"

      try
        packageMeta = require packageJson
      catch
        continue

      @installDependencies(loadedPackage.name) if packageMeta.hasOwnProperty("package-deps") is true

  installDependencies: (packageName) ->
    install packageName