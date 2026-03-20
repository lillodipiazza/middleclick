import CoreGraphics
import AppKit

enum ClickSimulator {

    static func performMiddleClick() {
        let position = mousePosition()

        guard
            let down = CGEvent(
                mouseEventSource: nil,
                mouseType: .otherMouseDown,
                mouseCursorPosition: position,
                mouseButton: .center
            ),
            let up = CGEvent(
                mouseEventSource: nil,
                mouseType: .otherMouseUp,
                mouseCursorPosition: position,
                mouseButton: .center
            )
        else { return }

        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }

    private static func mousePosition() -> CGPoint {
        // NSEvent.mouseLocation: origine in basso a sinistra dello schermo PRIMARIO, y cresce verso l'alto.
        // CGEvent: origine in alto a sinistra dello schermo PRIMARIO, y cresce verso il basso.
        // La conversione usa SEMPRE l'altezza dello schermo primario (screens[0]),
        // indipendentemente da quale schermo contiene il cursore.
        let loc = NSEvent.mouseLocation
        let primaryHeight = NSScreen.screens.first?.frame.height ?? 0
        return CGPoint(x: loc.x, y: primaryHeight - loc.y)
    }
}
