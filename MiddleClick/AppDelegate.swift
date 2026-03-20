import Cocoa
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var isEnabled = true
    private var accessibilityTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Crea subito la status item — prima di qualsiasi controllo permessi
        setupStatusItem()
        if AXIsProcessTrusted() {
            MultitouchManager.shared.start()
        } else {
            startAccessibilityPolling()
            openAccessibilitySettings()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        accessibilityTimer?.invalidate()
        MultitouchManager.shared.stop()
    }

    // MARK: - Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem.button else { return }

        // Usa SF Symbol con fallback a testo
        if let img = NSImage(systemSymbolName: "hand.tap.fill", accessibilityDescription: "MiddleClick") {
            img.isTemplate = true
            button.image = img
        } else if let img = NSImage(systemSymbolName: "hand.tap", accessibilityDescription: "MiddleClick") {
            img.isTemplate = true
            button.image = img
        } else {
            button.title = "MC"
        }

        button.toolTip = "MiddleClick — 3 dita = middle click"
        buildMenu()
    }

    private func updateStatusAppearance() {
        guard let button = statusItem.button else { return }
        button.alphaValue = isEnabled ? 1.0 : 0.4
    }

    private func buildMenu() {
        let menu = NSMenu()

        // Stato
        let stateItem = NSMenuItem(
            title: isEnabled ? "Attivo" : "⏸ In pausa",
            action: nil, keyEquivalent: ""
        )
        stateItem.isEnabled = false
        menu.addItem(stateItem)

        menu.addItem(.separator())

        // Toggle
        menu.addItem(NSMenuItem(
            title: isEnabled ? "Disabilita" : "Abilita",
            action: #selector(toggleEnabled),
            keyEquivalent: ""
        ))

        // Permesso Accessibilità
        if !AXIsProcessTrusted() {
            let permItem = NSMenuItem(
                title: "⚠️ Concedi Accessibilità…",
                action: #selector(openAccessibilitySettings),
                keyEquivalent: ""
            )
            menu.addItem(permItem)
        }

        menu.addItem(.separator())

        // Avvio al login
        let launchAtLoginItem = NSMenuItem(
            title: "Avvia al Login",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchAtLoginItem.state = isLaunchAtLoginEnabled() ? .on : .off
        menu.addItem(launchAtLoginItem)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(
            title: "Esci",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
    }

    @objc private func toggleEnabled() {
        isEnabled.toggle()
        if isEnabled {
            if AXIsProcessTrusted() {
                MultitouchManager.shared.start()
            } else {
                isEnabled = false
                openAccessibilitySettings()
            }
        } else {
            MultitouchManager.shared.stop()
        }
        buildMenu()
        updateStatusAppearance()
    }

    // MARK: - Accessibility

    private func startAccessibilityPolling() {
        accessibilityTimer?.invalidate()
        accessibilityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            if AXIsProcessTrusted() {
                timer.invalidate()
                self.accessibilityTimer = nil
                if self.isEnabled {
                    MultitouchManager.shared.start()
                }
                self.buildMenu()
            }
        }
    }

    @objc private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    // MARK: - Launch at Login

    private func isLaunchAtLoginEnabled() -> Bool {
        if #available(macOS 13, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    @objc private func toggleLaunchAtLogin() {
        if #available(macOS 13, *) {
            do {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                } else {
                    try SMAppService.mainApp.register()
                }
            } catch {
                NSLog("Launch at login error: \(error)")
            }
        }
        buildMenu()
    }
}
