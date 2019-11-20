module.exports = Util =
  getPackageManager: ->
    meta = require "../package.json"

    packageManager = atom.config.get("#{meta.name}.packageManager")

    switch packageManager
      when "pnpm" then return { name: "pnpm", bin: Util.getPnpmPath(), args: ["--no-color", "--no-lock"]}
      when "yarn" then return  { name: "yarn", bin: Util.getYarnPath(), args: ["--pure-lockfile"]}
      else return { name: "apm", bin: "apm", args: ["--no-color", "--quiet"]}

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

  spawnAsPromised: ->
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