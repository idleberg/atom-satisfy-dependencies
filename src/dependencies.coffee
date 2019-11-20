module.exports = Dependencies =
  satisfy: (installAtomPackages, installNodePackages) ->
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

      Dependencies.installAtom(loadedPackage.name) if installAtomPackages is true and packageMeta.hasOwnProperty("package-deps") is true
      Dependencies.installNode(loadedPackage) if installNodePackages is true

  installAtom: (packageName) ->
    { install } = require "atom-package-deps"
    meta = require "../package.json"

    console.time "#{packageName}: Completed" if atom.config.get("#{meta.name}.verboseMode") is true

    install(packageName, atom.config.get("#{meta.name}.showPrompt"))
    .then ->
      console.log "#{packageName}: Installing Atom package dependencies" if atom.config.get("#{meta.name}.verboseMode") is true
      console.timeEnd "#{packageName}: Completed" if atom.config.get("#{meta.name}.verboseMode") is true
    .catch (error) ->
      console.error error if error

  installNode: (loadedPackage) ->
    { platform } = require "os"
    { getPackageManager, spawnAsPromised } = require "./util"

    cmd = getPackageManager()

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
