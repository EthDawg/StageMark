# StageMark verification

Build target: Apple Silicon, macOS 14+. Verification machine: macOS 26.5.1, Apple Swift 6.3.3, one attached display. The project uses only Apple frameworks.

## Automated checks

Version 1.1.1 final run on 8 September 2026: **26 tests, 172 assertions, zero failures**. Production build and installed-bundle signature verification passed. Installed executable SHA-256 was compared with the release executable and matched.

The dependency-free runner compiles the production source directly. Tests cover:

- Precise line, rectangle-edge, ellipse-edge and arrowhead eraser hit testing, including zero-length strokes.
- Shift-constrained geometry in all quadrants.
- Undo/redo, branching after undo, bounded history, reversible clear, eraser drag grouping and no-op erasing.
- Fade delay/interpolation/expiry, with expired ink excluded from undo and redo.
- Deadline-based countdown, pause/resume, simulated sleep, reset and hour/minute formatting.
- Board JSON round trips, distinct display identities, atomic replacement, missing files, corrupt files and unsupported archive versions.
- Preference persistence, bounds, corrupt-data recovery, and complete unique shortcut defaults.
- Actual bitmap pixels rendered by all seven annotation tools.
- Native mouse-down/drag/up handlers for pen, highlighter, arrow, line, rectangle and oval, plus native text-view insertion and commit, eraser and undo.
- First stroke after shortcut and quick-panel activation through `NSWindow.sendEvent`, with the canvas initially not key. The test reproduced the missing initial mouse-down before the fix, then passed after enabling first-mouse acceptance for drawing and board modes. Idle overlays continue to pass clicks through. See Apple's [first-mouse documentation](https://developer.apple.com/documentation/appkit/nsview/acceptsfirstmouse(for:)).
- Native NSPanel input capture/release for hold and toggle modes, Escape, board/screen isolation and Clear.
- Paused timer settings edits and hiding/reopening preserve remaining time; Reset adopts the new duration.
- Exclusive global shortcut registration, unregistering and registering again.
- App-local shortcut dispatch, key release after modifier release, and passing unrelated typing through unchanged.
- A persistent status item, canvas below the menu-bar window level, native popover visibility, quick adjustments and shortcut recording without losing board ink, tool selection dismissing the popover, and Clear exiting the drawing session while retaining menu access.

The suite does not synthesize input into other apps. It invokes the actual application's handlers and inspects native window state using disposable data.

## Visual and package checks

- Version 1.1.1 installed app: the first native drag immediately after clicking Freehand increased screen-annotation count from 0 to 1 and produced visible ink. Undo hotkey restored 0, Redo restored 1, and Clear exited the session. The temporary test stroke was removed.
- All five action shortcuts are visible beneath their buttons without scrolling. The Undo shortcut entered recording mode and Escape cancelled without changing it. The installed app retained Toggle activation, the user's mint colour and custom shortcuts; Draw was left open and ready.
- Version 1.1 installed popover visually inspected in the Mac's light appearance: all four Draw, Cursor, Timer and General tabs fit in the compact panel. Native segmented navigation, switches, sliders, colour wells, shortcut buttons and steppers are exposed through accessibility. Settings and saved boards were retained during the update.
- Native menu-bar popover is the primary interface; the larger settings window remains available through All Settings.
- Final installed build: the line-width stepper changed 4 → 5 and back to 4 with immediate readback. The Draw panel was left open with the user's existing mint colour and shortcuts. Initial field focus no longer selects a numeric value when the panel opens.
- Native app launched and control centre visually inspected.
- Default colour shortcut collisions were found on this Mac and corrected to Control–Option–Shift–1…6.
- Whiteboard and screen overlay appeared through the native UI.
- Installed whiteboard tested with a real drag: annotation count increased from 7 to 8, native Undo restored 7, and Escape exited. Existing board contents were preserved.
- Installed launch screen visually inspected at 900 px width with all essential controls visible without scrolling.
- Final installed build: Control–Option–W invoked through native app keyboard control opened the saved board with its 7 existing annotations intact. Escape exited; the control centre was reopened and left ready.
- UI automation intermittently timed out on borderless nonactivating panels; drawing event coverage was additionally verified through the native integration suite.
- All six settings sections are implemented, with sidebar navigation, tooltips and accessibility labels.
- Release executable is a native arm64 Mach-O. App bundle Info.plist validates; ad-hoc code signature verifies. Bundle is approximately 3.2 MB.

## Not verified with physical hardware or remote participants

External-display hot-plug and full-screen Spaces transitions; live pressure data from Sidecar or a tablet; Stream Deck-generated keys; a recipient seeing annotations in Zoom/Teams/Meet; launch-at-login across a reboot. The relevant implementations are present, but these environments were not exercised. Apple Pencil double-tap is not implemented.

No claim is made that a fresh local implementation has the same long-term field history as DemoPro. The focus is a tested personal Mac app for the main solution-consultant presentation workflow.

## Workbench StageMark 1.2.0 — 8 September 2026

The final native regression suite passes: 26 tests, 172 assertions, zero failures. It covers rendering, input, persistence, windows, and exclusive shortcut registration. The installed signed executable matches `build/StageMark.zip` exactly. The Workbench shared shell matches Voice byte-for-byte.

Visually checked the new native Workbench header, menu switcher, retained drawing controls, and shared dark appearance. The shell explicitly resolves System/Light/Dark in SwiftUI to avoid stale popover appearance. StageMark-to-Voice navigation was exercised. Existing bundle identifier, preferences domain, and board path are retained; the installed saved-board file still contains its display data. No drawing/persistence implementation changed.

Spotlight’s index returns the canonical `/Applications/Workbench StageMark.app` and Workbench Voice installation with their new names, with no old app-bundle duplicates. Both advertise the Utilities category. The prior installed StageMark version is retained as a ZIP under build for rollback.
