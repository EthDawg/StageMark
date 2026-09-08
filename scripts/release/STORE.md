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

## Candidate evidence — 9 September 2026

Version 1.2.1 build 8 (source `5bb85d2`) completed Apple processing after
Transporter delivery. Build 6 failed error 91109 because the downloaded profile
carried a quarantine attribute. The packager now copies bytes and permissions
without downloaded-file metadata, and checks every staged path before signing.
It leaves the downloaded originals untouched. A regression test covers this case.

Build 8 package SHA-256: `813591d834a316ddcecc9541187918e6fdbb8009393d2d7c80f75dfdbc60b364`.

Validation: four release-script checks; full native test suite, 26 tests and
172 assertions, zero failures after quitting the installed app to free its
shortcuts; GitHub Build and test passed. Apple encryption questionnaire answered
none based on the app having no encryption implementations or network stack.

[Processed build](https://appstoreconnect.apple.com/teams/bcc1ba81-38bf-4899-8e2c-38fff873f001/apps/6809807232/testflight/macos/60de949d-246c-460c-b495-37765f698f2e).
The full test harness was also compiled with `APP_STORE` and run inside a signed
App Sandbox bundle: 26 tests, 172 assertions, zero failures. A TestFlight receipt
installation has not yet been exercised. The owner was invited to the internal
test group; no other testers were added.

Version 1.2.1 (8) was submitted to [App Review](https://appstoreconnect.apple.com/apps/6809807232/distribution/reviewsubmissions/details/91dac330-be7a-4f89-9754-ea59b1ccc221)
on 9 September 2026. Apple confirmed one item submitted. Pricing is free,
category Productivity, calculated age rating 4+, with automatic release after
approval. The maintainer is handling the EU trader declaration. Submission is
not approval or public App Store availability.
