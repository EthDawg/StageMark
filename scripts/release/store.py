#!/usr/bin/env python3
"""Build a separate sandboxed StageMark candidate; never uploads or publishes."""
import argparse
import datetime
import hashlib
import json
import plistlib
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]
BUNDLE = "local.ethan.StageMark"


def copy_payload(source, destination):
    # Preserve executable permissions, but never inherit downloaded-file xattrs.
    shutil.copy(source, destination)


def check_payload_attributes(app):
    for path in [app, *app.rglob("*")]:
        if "com.apple.quarantine" in run("xattr", str(path), capture=True).decode().splitlines():
            raise RuntimeError(f"Quarantine attribute is not allowed in store payload: {path}")


def run(*args, capture=False):
    return subprocess.run(args, cwd=ROOT, check=True, capture_output=capture).stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--build", type=int, required=True)
    parser.add_argument("--preview", action="store_true", help="Ad-hoc sandbox candidate, unsuitable for upload")
    parser.add_argument("--profile", type=Path)
    parser.add_argument("--team-id")
    parser.add_argument("--app-identity")
    parser.add_argument("--installer-identity")
    args = parser.parse_args()
    if run("git", "status", "--porcelain", capture=True).strip():
        parser.error("Commit the reviewed source before building a candidate")
    info = plistlib.loads((ROOT / "Resources/Info.plist").read_bytes())
    if args.build <= int(info["CFBundleVersion"]):
        parser.error("Use a store build number above the direct-release build")
    entitlements = {"com.apple.security.app-sandbox": True}
    if not args.preview:
        if not all([args.profile, args.team_id, args.app_identity, args.installer_identity]):
            parser.error("Distribution requires profile, team-id, app-identity and installer-identity")
        profile = plistlib.loads(run("security", "cms", "-D", "-i", str(args.profile.resolve()), capture=True))
        claims = profile["Entitlements"]
        if (claims.get("com.apple.application-identifier") != f"{args.team_id}.{BUNDLE}"
                or profile.get("TeamIdentifier") != [args.team_id]
                or profile["ExpirationDate"] <= datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None)
                or profile.get("ProvisionedDevices") or profile.get("ProvisionsAllDevices")
                or claims.get("com.apple.security.get-task-allow")):
            parser.error("Profile is expired or is not this app's store distribution profile")
        fingerprints = {hashlib.sha1(cert).hexdigest().upper() for cert in profile["DeveloperCertificates"]}
        if args.app_identity.upper() not in fingerprints:
            parser.error("Application certificate is not included in the profile")
        entitlements.update({"com.apple.application-identifier": f"{args.team_id}.{BUNDLE}",
                             "com.apple.developer.team-identifier": args.team_id})
    channel = "preview" if args.preview else "distribution"
    output = ROOT / ".build/store" / f"{info['CFBundleShortVersionString']}-{args.build}-{channel}"
    output.mkdir(parents=True, exist_ok=False)
    run("swift", "build", "-c", "release", "--scratch-path", ".build/store-swift", "--disable-sandbox", "-Xswiftc", "-DAPP_STORE")
    app = output / "Workbench StageMark.app"
    resources = app / "Contents/Resources"
    resources.mkdir(parents=True)
    (app / "Contents/MacOS").mkdir()
    copy_payload(ROOT / ".build/store-swift/release/StageMark", app / "Contents/MacOS/StageMark")
    copy_payload(ROOT / "Resources/AppIcon.icns", resources / "AppIcon.icns")
    copy_payload(ROOT / "scripts/release/PrivacyInfo.xcprivacy", resources / "PrivacyInfo.xcprivacy")
    info["CFBundleVersion"] = str(args.build)
    if args.preview:
        # Avoid launching the installed direct edition or sharing its test data.
        info["CFBundleIdentifier"] = BUNDLE + ".StorePreview"
        info["CFBundleDisplayName"] = "StageMark Store Preview"
    else:
        copy_payload(args.profile, app / "Contents/embedded.provisionprofile")
    (app / "Contents/Info.plist").write_bytes(plistlib.dumps(info))
    entitlements_path = output / "entitlements.plist"
    entitlements_path.write_bytes(plistlib.dumps(entitlements))
    check_payload_attributes(app)
    run("codesign", "--force", "--sign", "-" if args.preview else args.app_identity,
        "--entitlements", str(entitlements_path), str(app))
    run("codesign", "--verify", "--deep", "--strict", str(app))
    if not args.preview:
        signature = subprocess.run(["codesign", "-dvv", str(app)], capture_output=True, check=True).stderr.decode()
        if f"TeamIdentifier={args.team_id}" not in signature or not any(
                item in signature for item in ["Authority=3rd Party Mac Developer Application:", "Authority=Apple Distribution:"]):
            raise RuntimeError("Unexpected App Store signing identity")
        package = output / "Workbench.StageMark.pkg"
        run("productbuild", "--component", str(app), "/Applications", "--sign", args.installer_identity, str(package))
        result = run("pkgutil", "--check-signature", str(package), capture=True).decode()
        if f"3rd Party Mac Developer Installer:" not in result or f"({args.team_id})" not in result:
            raise RuntimeError("Unexpected installer signing identity")
        (output / "SHA256SUMS.txt").write_text(hashlib.sha256(package.read_bytes()).hexdigest() + "  " + package.name + "\n")
    (output / "candidate.json").write_text(json.dumps({
        "source": run("git", "rev-parse", "HEAD", capture=True).decode().strip(),
        "version": info["CFBundleShortVersionString"], "build": args.build, "channel": channel,
        "status": "Candidate only; native sandbox acceptance and Apple upload validation remain required"
    }, indent=2) + "\n")
    print(output)


if __name__ == "__main__":
    main()
