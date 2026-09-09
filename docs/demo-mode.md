# Demo mode: Preview 1.4

Development handoff, 9 September 2026. Native interaction testing is deliberately
pending the user's next hands-off window. Do not interpret compilation or model
tests as acceptance of USB capture, full-screen transitions or macOS permissions.

## Product flow

1. Choose a saved customer scene or one of the eight existing starter backdrops.
2. Reuse a saved logo or create a simple text wordmark. Adjust the device shape
   only when needed; save a preferred shape for future scenes.
3. Start demo. StageMark hides its editor and opens a native full-screen stage.
   Its public AppKit window gets a full-screen Space; it does not create or
   manipulate ordinary desktops through private APIs.
4. Connect an unlocked, trusted iPhone or iPad by USB. A sole screen source can
   be selected automatically; ambiguous sources require a choice. The selected
   device is remembered. Source switching, disconnect/replug, runtime errors,
   wake and explicit Reconnect all preserve that identity.
5. End demo or Escape stops capture, releases the idle-sleep assertion, closes
   the stage and returns to the editor. The stage never changes wallpaper.

The pointer reveals a small Source / Reconnect / Fit to screen / End toolbar.
Controls fade after three seconds. Only video is connected; there is no recording
output, audio connection, upload or remote control. A stalled feed is hidden
after five seconds without new frames, with recovery controls shown. A locked
device may still emit valid black frames, so there is no claim to detect every
lock or freeze automatically. Capture runs on a serial background queue; the
GPU preview layer displays frames directly, with low-frequency health and size
updates to SwiftUI. Failed connection attempts use bounded backoff.

The active demo prevents idle system/display sleep, not an explicit lock or
security policy. End, close, fullscreen exit and teardown release the assertion.
This cannot keep the connected phone itself unlocked.

## Composition and saved data

The editor, PNG export and live stage share one device geometry. Screen aspect,
border thickness and inner corner radius determine the outer border; no fake
notch or Dynamic Island is drawn. Fit to screen uses live source dimensions;
disabling it retains the saved geometry and letterboxes as needed. Scene layers
are backdrop, optional hand, frame/live viewport and logo, in that order.

Hands are optional, genuine-alpha hand-only PNGs, kept at their original aspect
ratio. Size, position, flip and gentle tonal controls are supported. Raster hands
do not anatomically reshape to every device width; substantially different shapes
may need realignment or a different cutout. No hand image is included in this
release. The user's reference pictures are not bundled assets.

Each image is copied locally. `scenes.json` remains the source of customer layouts.
Optional viewport/hand fields preserve old archive decoding. `my-device.json`
stores the reusable device shape. `saved-logos.json` indexes locally retained logo
files: existing scene logos are adopted once, byte-identical imports deduplicate,
and removing a library entry never removes an existing scene's artwork.
`starter-preferences.json` holds only starter order, aliases and visibility.
Restore defaults cannot reset customer scenes. Corrupt catalog files are preserved
and blocked from writes. No source PNG is altered by gallery organization.

Legacy wallpaper apply/restore remains available. Recovery entries are separate
picture chains rather than a single slot per physical monitor. Applying in a new
Space preserves the former Space's chain; restoring the current picture retains
unmatched chains. macOS readback must confirm a change before it is reported as
successful. Users revisit other affected Spaces themselves; manual wallpaper
changes are not overwritten. Dynamic wallpaper schedules are outside this scope.

## Why this approach

Automating QuickTime device menus, window placement and arbitrary Spaces would
add fragile third-party UI dependencies to the core path. A native full-screen
window and an AVFoundation preview keep the scene and video geometry together.
QuickTime remains a manual fallback, not an automation claimed by this build.

Apple references consulted on 9 September 2026:

- [Native full-screen window lifecycle](https://developer.apple.com/library/archive/documentation/General/Conceptual/MOSXAppProgrammingGuide/FullScreenApp/FullScreenApp.html)
- [QuickTime's documented device-recording workflow](https://support.apple.com/en-au/guide/quicktime-player/qtp356b55534/mac)
- [CoreMediaIO screen-device exposure](https://developer.apple.com/documentation/coremediaio/kcmiohardwarepropertyallowscreencapturedevices)
- [AVFoundation capture setup](https://developer.apple.com/documentation/avfoundation/capture-setup)
- [Capture devices](https://developer.apple.com/documentation/avfoundation/avcapturedevice)

The SharePad author's [design notes](https://github.com/jonyardley/SharePad/blob/main/DESIGN.md)
helped identify USB-screen discovery and sandbox risks. No implementation code
was copied. The direct build uses Apple's public frameworks and a camera
entitlement under hardened runtime. First-use camera authorization is expected;
the absence of an unintended microphone prompt requires hardware verification.

Live capture and desktop switching are hidden in the App Store edition until
its sandbox path is accepted on hardware. Scene editing/export compile with
`APP_STORE`. Android needs a compatible external video source; direct Android
USB mirroring, AirPlay and device control are not implemented. Intel compilation
is verified; physical Intel hardware remains untested.

## Verification and next acceptance session

Background checks on the final source:

- `zsh scripts/test.zsh --scenes-only`: 19 tests, 504 assertions, zero failures;
  plus 11 release/updater tests. Temporary test fixtures only; no live camera,
  desktop change, global hotkey registration or application installation.
- `swift build --scratch-path .build/scene-store-check --disable-sandbox -Xswiftc -DAPP_STORE`:
  successful conditional Store compilation.
- `zsh scripts/build.zsh --preview`: universal arm64/x86_64 Preview ZIP, signed
  with the existing Developer ID. The final extracted artifact passed strict
  signature verification with normal macOS signing access, exact Preview identity,
  camera entitlement, both architecture slices, and eight original PNG hashes.
  This handoff does not install or launch it.

Final package: **1.4.0 build 20260909070304**, `build/Workbench StageMark Preview.zip`
(21,859,421 bytes). SHA-256:
`b9b2c37a9c1171da220d8c50b03f6e6d9cf19443e17aba4544d50b156199f555`.
Installed Preview remains 1.3.0 build 20260909041039; production remains 1.2.0
build 4. No app-data migration was run against the user's live installation.

The next user-authorized UI session should verify:

1. Updating the same Preview preserves customers, logos and device preferences;
   production remains separate. Primary actions stay visible at minimum size.
2. Gallery rename/reorder/hide/reset and customer scene reorder/remove; saved-logo
   adoption, reuse, rename, removal, text logos, all four corners and PNG export.
3. Start/End, Escape, window close and full-screen failure/exit return correctly;
   the existing desktop picture stays unchanged and idle-sleep assertions release.
4. Camera allow/deny paths; no unintended microphone prompt. An already connected
   iPhone is selected correctly. Test an iPad, rotation, source aspect, corner
   clipping, readable non-mirrored video, and branding above the live layer.
5. Repeated cable disconnect/replug, explicit Reconnect, phone lock/unlock, wake,
   another app already using the device, multiple devices and source switching.
   Never substitute another person's feed while waiting for the remembered device.
6. Apply separate phone/tablet wallpapers in two Spaces on the same monitor,
   relaunch, restore each from its Space, and preserve a later manual wallpaper.
7. After the user provides cutouts: true transparency, placement, flip, tones,
   non-stretching device changes and identical branding/hand ordering in export.

Do not promote this candidate to production or describe native capture as
verified until the connected-device acceptance session passes.
