import Foundation
import QuartzCore

final class MultitouchManager {

    static let shared = MultitouchManager()
    private init() {}

    private var threeFingerActive = false
    private var tooManyFingers = false
    private var lastClickTime: CFTimeInterval = 0
    private let clickCooldown: CFTimeInterval = 0.5

    func start() {
        MultitouchBridge.shared().start { [weak self] count in
            self?.handleTouchCount(Int(count))
        }
    }

    func stop() {
        MultitouchBridge.shared().stop()
        threeFingerActive = false
        tooManyFingers = false
    }

    private func handleTouchCount(_ count: Int) {
        if count > 3 {
            tooManyFingers = true
        } else if count == 3 && !tooManyFingers {
            threeFingerActive = true
        } else if count == 0 {
            if threeFingerActive && !tooManyFingers {
                let now = CACurrentMediaTime()
                if now - lastClickTime >= clickCooldown {
                    lastClickTime = now
                    DispatchQueue.main.async {
                        ClickSimulator.performMiddleClick()
                    }
                }
            }
            threeFingerActive = false
            tooManyFingers = false
        }
    }
}
