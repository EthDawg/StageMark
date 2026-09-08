# Mac App Store candidate

This is a separate distribution target. Building a package is not App Store
approval. The Developer ID downloads remain the available early-access channel.

`store.py` compiles with `APP_STORE` in its own Swift build directory, enables
App Sandbox and includes a privacy manifest. Store appearance preferences are
stored in the app's own container. System appearance comes from AppKit rather
than a system-owned UserDefaults key. Existing direct-release behaviour is
unchanged. Do not promise shared preferences or automatic board migration
between the direct and store editions.

Commit reviewed source, then create a local sandbox preview:

```sh
python3 scripts/release/store.py --build 6 --preview
```

Quit other StageMark copies before testing global shortcuts. The preview has a
separate bundle identifier and data container. Verify controls, drawing, undo,
saved boards after restart, light/dark/system appearance, pointer/click effects,
global shortcuts and display changes. Preview signing is ad-hoc and cannot be
uploaded. Never publish this preview as a replacement for a notarised release.

After native acceptance, use a valid Mac App Store distribution profile whose
application certificate matches the Keychain fingerprint:

```sh
python3 scripts/release/store.py --build 6 \
  --profile /path/to/StageMark.provisionprofile \
  --team-id APPLE_TEAM_ID \
  --app-identity APP_DISTRIBUTION_CERTIFICATE_SHA1 \
  --installer-identity INSTALLER_DISTRIBUTION_CERTIFICATE_SHA1
```

The script checks the profile's app, team, expiry, distribution type and signing
certificate, signs the app, embeds the profile and creates a signed installer
package. It verifies the package signature and records source provenance.
Existing outputs are never overwritten. Keep profiles and signing credentials
outside Git. Outputs are ignored under `.build/store/`.

Use Apple's Transporter to validate the package before delivery. Resolve every
upload error. Then inspect the processed build in App Store Connect, complete
screenshots, category, age rating, pricing (free), availability, review contact
and any required legal declarations. Use TestFlight to check the actual store
container/receipt before final review. Do not represent a draft listing or
successful upload as a published app.

The App Store privacy declaration is Data Not Collected; StageMark has no
networking or third-party SDK dependencies. The privacy manifest's CA92.1 reason
covers only this store edition's own local preferences. Reassess both statements
if functionality or dependencies change.

References: [Apple signing guidance](https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac/),
[required API reasons](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype),
[upload tools](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds).
