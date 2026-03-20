import Cocoa

// Entry point esplicito — stesso pattern del TestSI che funziona su macOS 26
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
