module.exports =
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
    { satisfy } = require "./dependencies"

    # Events subscribed to in atom"s system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add "atom-workspace", "satisfy-dependencies:all": -> satisfy(true, true)
    @subscriptions.add atom.commands.add "atom-workspace", "satisfy-dependencies:atom-packages": -> satisfy(true, false)
    @subscriptions.add atom.commands.add "atom-workspace", "satisfy-dependencies:node-packages": -> satisfy(false, true)

  deactivate: ->
    @subscriptions?.dispose()
    @subscriptions = null
