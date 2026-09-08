"""Regression checks for release rejection and nested signing order."""
import importlib.util
import os
import sys
from pathlib import Path
import plistlib
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

spec = importlib.util.spec_from_file_location("workbench_release", Path(__file__).with_name("release.py"))
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)
store_spec = importlib.util.spec_from_file_location("workbench_store", Path(__file__).with_name("store.py"))
store = importlib.util.module_from_spec(store_spec)
store_spec.loader.exec_module(store)


class ReleaseTests(unittest.TestCase):
    @unittest.skipUnless(sys.platform == "darwin", "macOS downloaded-file attributes")
    def test_downloaded_profile_attributes_do_not_enter_store_payload(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            source = root / "downloaded.provisionprofile"
            source.write_bytes(b"profile content")
            source.chmod(0o755)
            os.setxattr(source, "com.apple.quarantine", b"0081;test;Chrome;")
            app = root / "Example.app"
            app.mkdir()
            target = app / "embedded.provisionprofile"
            store.copy_payload(source, target)
            self.assertEqual(target.read_bytes(), source.read_bytes())
            self.assertEqual(target.stat().st_mode & 0o777, 0o755)
            self.assertIn("com.apple.quarantine", os.listxattr(source))
            store.check_payload_attributes(app)
            os.setxattr(target, "com.apple.quarantine", b"0081;test;Chrome;")
            with self.assertRaises(RuntimeError):
                store.check_payload_attributes(app)

    def test_only_explicit_acceptance_passes(self):
        for result in [{}, {"status": "Invalid"}, {"status": "In Progress"}, {"status": "Rejected"}]:
            with self.subTest(result=result), self.assertRaises(RuntimeError):
                release.require_accepted(result)
        release.require_accepted({"status": "Accepted"})

    def test_reject_wrong_team_or_weakened_signature(self):
        valid = "Authority=Developer ID Application: Example\nTeamIdentifier=ABCDEFGHIJ\nflags=0x10000(runtime)\nTimestamp=Sep 8, 2026\n"
        for missing in ["Authority=Developer ID Application:", "TeamIdentifier=ABCDEFGHIJ", "runtime", "Timestamp="]:
            with self.subTest(missing=missing), patch.object(release, "run", return_value=SimpleNamespace(stderr=valid.replace(missing, ""))):
                with self.assertRaises(RuntimeError):
                    release.check_signature(Path("Example.app"), "ABCDEFGHIJ")

    def test_nested_code_precedes_its_enclosing_bundle(self):
        with tempfile.TemporaryDirectory() as temp:
            app = Path(temp) / "Example.app"
            helper = app / "Contents/XPCServices/Helper.xpc"
            executable = helper / "Contents/MacOS/Helper"
            executable.parent.mkdir(parents=True)
            executable.write_bytes(bytes.fromhex("cffaedfe") + b"test")
            (helper / "Contents/Info.plist").write_bytes(plistlib.dumps({"CFBundleExecutable": "Helper"}))
            resource = app / "Contents/Resources/Data.bundle"
            resource.mkdir(parents=True)
            (resource / "Info.plist").write_bytes(plistlib.dumps({"CFBundleIdentifier": "test.resources"}))
            alias = executable.with_name("Alias")
            alias.symlink_to(executable)
            targets = release.signing_targets(app)
            self.assertEqual(targets, [executable, helper, app])


if __name__ == "__main__":
    unittest.main()
