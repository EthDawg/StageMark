# StageMark

A native Mac presentation companion built for Ethan's software demos. Draw over a live application, guide the audience with a cursor highlight, open a saved board, and put a break timer on screen.

Open **StageMark** from Applications. It lives in the menu bar. Click its pencil icon or press **Control–Option–S** for the native quick-controls panel. Right-click the icon for an action menu. There is no subscription, account, server, or network dependency.

## Install

Download `StageMark.zip` from the repository's Releases page, unzip it, and move **StageMark.app** into **Applications**. Quit StageMark before replacing an existing version. Keep the installed app in Applications and remove the unpacked download copy to avoid duplicate app-search results. Settings and saved boards live separately and survive app updates.

## Native quick controls

Version 1.1.1 puts everyday adjustments in a compact menu-bar popover that follows your Mac's appearance:

- **Draw:** tools, colours, line width, text size, activation mode, auto-fade, editable shortcuts and boards.
- **Cursor:** highlight style, size, opacity, colour and visibility.
- **Timer:** duration, presets, message, pause/resume and appearance.
- **General:** launch at login, drawing indicator, pressure and palette preferences.

The menu-bar icon stays accessible above the drawing canvas. Opening quick controls preserves your current board and ink. Choose a tool to continue drawing; **Return to demo** exits the canvas. Closing the popover leaves StageMark running in the menu bar. **All Settings…** opens the larger configuration window. Hold Command and drag the menu-bar icon to reposition it.

Undo, Redo, Clear, Whiteboard and Blackboard each show an editable shortcut directly beneath their button. Click the shortcut to change it. Drawing accepts the first click after activation, including when the canvas does not yet have focus.

## Start with two shortcuts

| Action | Default shortcut |
| --- | --- |
| Hold to draw; release to use your app | Control–Option–D |
| Clear annotations and return to the demo | Control–Option–X |
| Exit a drawing session or board | Escape, or right-click the canvas |
| Arrow | Control–Option–A |
| Highlighter | Control–Option–H |
| Line / rectangle / oval | Control–Option–L / R / O |
| Text / eraser | Control–Option–T / E |
| Undo / redo | Control–Option–Z / Control–Option–Shift–Z |
| Cursor highlight | Control–Option–C |
| Whiteboard / blackboard | Control–Option–W / B |
| Auto-fade | Control–Option–F |
| Break timer | Control–Option–K |
| Colour presets 1–6 | Control–Option–Shift–1 through 6 |

Choose **Toggle** under Draw → Activation for longer sessions or a Stream Deck. A tool clicked in quick controls or the palette always starts a toggle session. Text and boards stay active until you exit. Click a shortcut beside a tool to record a new combination; Escape cancels and Delete disables it. Conflicts are shown explicitly.

Hold **Shift** while drawing shapes for squares, circles and lines at 45-degree angles. Text follows the pointer until you click to place it. Enter commits it; Shift–Enter adds a line. Command–plus/minus changes text size. The eraser removes whole annotations; one eraser drag is one undo step.

**Share your entire display** in Zoom, Teams or Meet for the audience to see the ink. Sharing only an application window excludes overlays belonging to other apps. StageMark draws directly over the live screen and does not capture its contents.

## Boards, pointer and timer

- Separate boards save automatically on this Mac and reopen on the same display. Whiteboard and blackboard share one saved canvas per display. Shared mode uses temporary screen ink instead. Escape hides the board without deleting its drawing. The palette's trash button clears the current canvas; Undo can restore it.
- Ring, Disc, Laser and Spotlight each retain their own colour/size/opacity settings. Pointer visibility can be constant, movement-based or click-only, with optional click ripples. Effects hide while annotating.
- The timer can pause, resume, reset, resize, move, or hide. Closing its window leaves a running countdown in the menu bar. Use Control–Option–K or right-click the menu-bar icon and choose Break timer to bring it back. Reopening a paused timer preserves its remaining time. Its message is editable directly on the timer.
- Launch at login is optional under General. It is off by default.

## Files and privacy

- Installed app: `/Applications/StageMark.app`
- Project and source: `/Users/ethanharley/Documents/StageMark`
- Saved boards: `~/Library/Application Support/StageMark/boards.json`
- Settings: macOS preferences domain `local.ethan.StageMark`
- Portable app archive: `build/StageMark.zip`

The app makes no network requests and asks for no screen-recording or accessibility permission. It uses registered global shortcuts and pointer position/click notifications. Board files contain only your annotations. Board writes are atomic; an unreadable board is preserved and an error is shown instead of replacing it. If that happens, retain the original file for recovery before moving it aside and restarting the app.

## Build and checks

Requires macOS 14 or later, Apple Silicon, and Apple's Command Line Tools. No third-party packages or full Xcode installation are needed.

```sh
cd StageMark
./scripts/test.zsh
./scripts/build.zsh
```

Quit StageMark before running the tests: the integration suite checks exclusive global hotkey registration. The test runner uses temporary preferences and board files, and does not change the installed app's settings or boards. It runs the production rendering, input, storage and window code with a small dependency-free assertion runner because XCTest is not included with Command Line Tools.

The build creates and verifies an ad-hoc signed app and packages it as `build/StageMark.zip`. Its temporary app bundle is removed automatically so repeated builds do not add another app to macOS search. The icon is generated from original native vector drawing code. On an agent with a restricted filesystem sandbox, macOS icon compilation and the native graphics tests may need the standard execution approval; ordinary Terminal builds do not have that restriction.

This is a local personal-use build. Developer ID signing and Apple notarization for general distribution are not included. Remove the app from Applications to uninstall; your settings and saved boards remain available until you choose to remove them.

## Verification limits

See [QA.md](docs/QA.md) for test coverage. Physical iPad/Apple Pencil, Stream Deck, an external display and a remote screen-share participant were not available for end-to-end checks. Pressure input is implemented using AppKit tablet events; Apple Pencil double-tap switching is not implemented. Native macOS Zoom remains a separate system feature.

The functional reference was [DemoPro](https://www.demoproapp.com/) and its [FAQ](https://www.demoproapp.com/faq.html), inspected on 7 September 2026. StageMark has an original name, interface, icon and implementation; it contains no DemoPro code or assets and is not affiliated with its developer.
