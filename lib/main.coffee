meta = require "../package.json"

module.exports = SatisfyDependencies =
  config:
    packageManager:
      title: "Package Manager"
      description: "Pick your preferred package manager for installing"
      type: "string",
      default: "yarn",
      enum: [
        "apm",
        "pnpm",
        "yarn"
      ],
      order: 0
    showPrompt:
      title: "Show Prompt"
      description: "Displays an prompt before installing Atom packages"
      type: "boolean"
      default: false
      order: 1
    verboseMode:
      title: "Verbose Mode"
      description: "Output progress to the console"
      type: "boolean"
      default: false
      order: 2
    manageDependencies:
      title: "Manage Dependencies"
      description: "When enabled, third-party dependencies will be installed automatically"
      type: "boolean"
      default: true
      order: 3
  subscriptions: null

  activate: ->
    { CompositeDisposable } = require "atom"
    { satisfyDependencies } = require "./util"

    # Events subscribed to in atom"s system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add "atom-workspace", "satisfy-dependencies:all": => @satisfyDependencies(true, true)
    @subscriptions.add atom.commands.add "atom-workspace", "satisfy-dependencies:atom-packages": => @satisfyDependencies(true, false)
    @subscriptions.add atom.commands.add "atom-workspace", "satisfy-dependencies:node-packages": => @satisfyDependencies(false, true)

    satisfyDependencies() if atom.config.get("language-nsis.manageDependencies") is true

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null

  satisfyDependencies: (installAtomPackages, installNodePackages) ->
    { join } = require "path"

    loadedPackages = atom.packages.getLoadedPackages()

    for loadedPackage in loadedPackages
      continue if atom.packages.isBundledPackage loadedPackage.name

      packageJson = join loadedPackage.path, "package.json"

      try
        packageMeta = require packageJson
      catch
        console.log "[#{loadedPackage.name}] Missing package manifest, skipping..."
        continue

      @installNodeDependencies(loadedPackage) if installNodePackages is true
      @installAtomDependencies(loadedPackage.name) if installAtomPackages is true and packageMeta.hasOwnProperty("package-deps") is true

  installAtomDependencies: (packageName) ->
    { install } = require "atom-package-deps"

    console.time "#{packageName}: Completed" if atom.config.get("#{meta.name}.verboseMode") is true

    install(packageName, atom.config.get("#{meta.name}.showPrompt"))
    .then ->
      console.log "#{packageName}: Installing Atom package dependencies" if atom.config.get("#{meta.name}.verboseMode") is true
      console.timeEnd "#{packageName}: Completed" if atom.config.get("#{meta.name}.verboseMode") is true
    .catch (error) ->
      console.error error if error

  installNodeDependencies: (loadedPackage) ->
    { platform } = require "os"
    { spawnAsPromised } = require "./util"

    cmd = @getPackageManager()

    if platform() is "win32"
      defaultArgs = [
        "/c"
        cmd.bin
        "install"
        "--production"
      ]
      cmd.bin = "cmd.exe"
    else
      defaultArgs = [
        "install"
        "--production"
      ]

    args = defaultArgs.concat(cmd.args)
    options = {cwd: loadedPackage.path}

    spawnAsPromised(cmd.bin, args, options)
    .then (stdio) ->
      console.info "Spawning #{cmd.name} in '#{loadedPackage.name}' directory"
      console.log stdio
    .catch (error) ->
      console.error error if error

  getPackageManager: ->
    packageManager = atom.config.get("#{meta.name}.packageManager")

    switch packageManager
      when "pnpm" then return { name: "pnpm", bin: @getPnpmPath(), args: ["--no-color", "--no-lock"]}
      when "yarn" then return  { name: "yarn", bin: @getYarnPath(), args: ["--pure-lockfile"]}
      else return { name: "apm", bin: "apm", args: ["--no-color", "--quiet"]}

    return @getPnpmPath() if packageManager is 'pnpm'

  getPnpmPath: ->
    { join } = require "path"
    { platform } = require "os"

    if platform() is "win32"
      return join __dirname, "..", "node_modules", ".bin", "pnpm.cmd"
    else
      return join __dirname, "..", "node_modules", ".bin", "pnpm"

  getYarnPath: ->
    { join } = require "path"
    { platform } = require "os"

    if platform() is "win32"
      return join __dirname, "..", "node_modules", ".bin", "yarn.cmd"
    else
      return join __dirname, "..", "node_modules", ".bin", "yarn"
