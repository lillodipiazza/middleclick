# MiddleClick

A lightweight macOS menu bar app that enables **middle click** via a **3-finger tap** on the trackpad.

Tap with three fingers anywhere on the trackpad to simulate a middle mouse button click — perfect for opening links in a new tab, closing tabs, and any other middle-click action.

> Tested on macOS 26 (Tahoe) with Apple Silicon.

---

## Features

- **3-finger tap → middle click** — works system-wide in any app
- Runs silently in the menu bar, no Dock icon
- Enable/disable toggle from the menu bar
- Launch at Login support
- Minimal CPU and memory footprint

---

## Requirements

- macOS 12 or later
- Apple Silicon or Intel Mac
- Accessibility permission (required to post mouse events)

---

## Installation

### Download (easiest)

1. Download `MiddleClick.dmg` from the [Releases](../../releases) page
2. Open the DMG and drag **MiddleClick** to your **Applications** folder
3. Launch MiddleClick from Applications
4. Grant **Accessibility** permission when prompted:
   - Go to **System Settings → Privacy & Security → Accessibility**
   - Enable the toggle next to **MiddleClick**

> On first launch, macOS may warn about an unidentified developer.
> Right-click the app → **Open** to bypass this.

### Build from source

Requirements: Xcode 15+

```bash
git clone https://github.com/yourusername/MiddleClick.git
cd MiddleClick
open MiddleClick.xcodeproj
```

Build and run with **⌘R** in Xcode, or from the command line:

```bash
xcodebuild -project MiddleClick.xcodeproj \
  -scheme MiddleClick \
  -configuration Release \
  -derivedDataPath build \
  build
```

The compiled app will be at `build/Build/Products/Release/MiddleClick.app`.

---

## Usage

1. Launch the app — a hand icon (✋) appears in the menu bar
2. **Tap the trackpad with 3 fingers simultaneously** → middle click fires at the cursor position
3. Click the menu bar icon to enable/disable or configure launch at login

---

## How it works

MiddleClick uses Apple's private `MultitouchSupport.framework` to receive low-level trackpad touch events. When exactly 3 simultaneous finger contacts are detected and then released, it posts a `CGEvent` (`otherMouseDown` + `otherMouseUp`) at the current cursor position via `CGEventPost`.

```
Trackpad → MultitouchSupport (private framework)
         → touch callback (count fingers)
         → 3 fingers lifted → CGEventPost(.otherMouseDown / .otherMouseUp)
```

Key files:

| File | Purpose |
|------|---------|
| `MultitouchSupport.h` | C header for Apple's private multitouch API |
| `MultitouchBridge.m` | Objective-C wrapper that registers touch callbacks |
| `MultitouchManager.swift` | Swift logic to detect the 3-finger tap gesture |
| `ClickSimulator.swift` | Simulates the middle click via CGEvent |
| `AppDelegate.swift` | Menu bar UI, accessibility polling, launch-at-login |

### macOS 26 compatibility note

Starting with macOS 26, the internal layout of the `MTTouch` struct changed, making per-finger state unreliable for touches 2 and 3. MiddleClick works around this by using `numTouches` (provided directly by the framework) for the finger count, and only reading the state of the first touch to filter hover events.

---

## Privacy

MiddleClick requires **Accessibility** permission solely to post `CGEvent` mouse events. It does not collect, transmit, or store any data. No network access is needed or requested.

---

## License

[MIT](LICENSE)
