# Bundled scenes and customer logos

StageMark includes eight fictional photographic settings, all available offline. The two everyday settings use the exact selected Office & professional and Care & service PNGs, including the reception wall artwork and counter card. The six Australian sectors are Higher education campus, Acute healthcare, Aged care, Allied health / NDIS, Financial services and Mining & resources. Operations & field is excluded from the original pack; the independently requested Mining & resources image remains included.

## Asset ownership

`Resources/SceneBackdrops/provenance.json` records the original PNG hashes and generation date. Each original is 1672 × 941. The collection totals 18,215,736 bytes of PNG data. Images are copied unchanged into direct, Preview and future App Store packages. No generated phone, logo, AI service or runtime image dependency is added. Original prompt text is historical provenance only; `default-scene-prompts.md` is superseded by the final selection.

The gallery reads bundled originals. Choosing a starter copies its PNG into a new user scene, so customizations survive updates, source-file removal and repeated use. App launch never seeds, rewrites or recreates deleted customer scenes. Existing BaptistCare and other user-created scenes remain independent of the gallery.

## Branding

Add a PNG, JPEG or HEIC logo. Transparent PNG is preferred. Its image is copied into the scene store, with the same size/type validation as backdrops. Choose one of four corners, change size, and choose light, dark or no backing. Replacement preserves the placement controls. Duplicates share the old imported asset until one is replaced; replacement and removal never delete another scene's image.

A new optional `logo` object preserves decoding of existing version-1 scene archives. The same native renderer draws the editor, PNG export and desktop image. Missing logo files produce a visible warning and block export/apply until replaced or removed. Desktop journaling, asynchronous macOS verification and manual-wallpaper protection retain their existing behavior.

## Verification

- `python3 scripts/check-scene-assets.py` verifies the exact eight filenames, PNG dimensions and SHA-256 hashes. Pass a built ZIP to verify the shipped payload as well.
- `zsh scripts/test.zsh --scenes-only` runs image, persistence, rendering and desktop recovery logic tests without opening windows, acquiring global shortcuts or changing desktop pictures. Use this mode while sharing a Mac.
- Optional `STAGEMARK_SCENE_REVIEW_DIR` writes 48 compositor samples: every starter at 16:9 and 16:10 with left, centre and right phones. These are local QA artifacts, not bundled assets.
- Full interactive tests and actual wallpaper changes require a coordinated hands-off window. Announce when taking input, and explicitly return the keyboard and mouse afterward. Building alone does not require that window.

## Upgrade

Build a signed archive with `zsh scripts/build.zsh --preview`. Install the completed archive using the normal Preview installer after the running Preview has quit. Keep the same app location, bundle identifier and Developer ID signing identity. The production app and its permissions are untouched. A rollback ZIP is retained by the installer; older binaries cannot display the new logo controls.
