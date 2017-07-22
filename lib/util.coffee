module.exports = Util =

  satisfyDependencies: () ->
    meta = require "../package.json"

    require("atom-package-deps").install(meta.name, true)

    for k, v of meta["package-deps"]
      if atom.packages.isPackageDisabled(v)
        console.log "Enabling package '#{v}'" if atom.inDevMode()
        atom.packages.enablePackage(v)

  spawnAsPromised:  ->
    {spawn} = require "child_process"

    args = Array::slice.call(arguments)
    new Promise((resolve, reject) ->
      stdout = ''
      stderr = ''

      cp = spawn.apply(null, args)

      cp.stdout.on 'data', (chunk) ->
        stdout += chunk
        return

      cp.stderr.on 'data', (chunk) ->
        stderr += chunk
        return

      cp.on('error', reject).on 'close', (code) ->
        if code == 0
          resolve stdout
        else
          reject stderr
        return
      return
  )