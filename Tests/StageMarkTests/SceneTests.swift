import AppKit

final class SceneTests {
    func testDesktopRecoverySurvivesInterruptedSwitch() throws {
        let original = URL(fileURLWithPath: "/original.jpg")
        let first = URL(fileURLWithPath: "/scene-a.png")
        let second = URL(fileURLWithPath: "/scene-b.png")
        let journal = DesktopSnapshot(screenID: "display", originalURL: original, appliedURL: first,
                                      pendingURL: second, scaling: nil, clipping: nil, fill: nil)
        let recovered = try JSONDecoder().decode(DesktopSnapshot.self, from: JSONEncoder().encode(journal))
        XCTAssertTrue(recovered.owns(first), "Failed switch must retain recovery of the earlier scene")
        XCTAssertTrue(recovered.owns(second), "Interrupted finalization must still restore the new scene")
        XCTAssertFalse(recovered.owns(original), "Manual wallpaper changes must not be overwritten")
        XCTAssertFalse(recovered.owns(nil))
        XCTAssertEqual(recovered.originalURL, original)
    }
    private func temporary() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("StageMarkSceneTests-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
    func testSceneRoundTripAndBounds() throws {
        let root = try temporary(); defer { try? FileManager.default.removeItem(at: root) }
        var scene = DemoScene(name: "Reception", background: "photo.png")
        scene.phoneX = 3; scene.phoneHeight = -1; scene.zoom = 9
        try SceneStorage.save([scene], to: root.appendingPathComponent("scenes.json"))
        let saved = try SceneStorage.load(root.appendingPathComponent("scenes.json"))
        XCTAssertEqual(saved.count, 1); XCTAssertEqual(saved[0].id, scene.id)
        XCTAssertEqual(saved[0].phoneX, 1); XCTAssertEqual(saved[0].phoneHeight, 0.3); XCTAssertEqual(saved[0].zoom, 3)
    }
    func testUnsafeImagePathsAndNumbersRejected() throws {
        for filename in ["../private.png", "/tmp/image.png", "folder/file.png", "folder\\file.png", ".hidden", ""] {
            XCTAssertThrowsError(try DemoScene(background: filename).validated())
        }
        var scene = DemoScene(background: "valid.png"); scene.phoneX = .infinity
        XCTAssertThrowsError(try scene.validated())
        scene.phoneX = 0.5; scene.name = "   "
        XCTAssertThrowsError(try scene.validated())
    }
    func testCorruptAndFutureArchivesPreserved() throws {
        let root = try temporary(); defer { try? FileManager.default.removeItem(at: root) }
        let url = root.appendingPathComponent("scenes.json")
        for payload in [Data("broken".utf8), Data("{\"version\":9,\"scenes\":[]}".utf8)] {
            try payload.write(to: url)
            let model = DemoScenes(root: root)
            XCTAssertTrue(model.storageBlocked)
            XCTAssertNotNil(model.notice)
            model.update(DemoScene(background: "image.png"))
            XCTAssertEqual(try Data(contentsOf: url), payload)
        }
    }
    func testDuplicateIDsRejected() throws {
        let root = try temporary(); defer { try? FileManager.default.removeItem(at: root) }
        let scene = DemoScene(background: "photo.png")
        let url = root.appendingPathComponent("scenes.json")
        try JSONEncoder().encode(SceneArchive(scenes: [scene, scene])).write(to: url)
        XCTAssertThrowsError(try SceneStorage.load(url))
    }
    func testPhoneStaysWithinWideAndTallDisplays() throws {
        for size in [CGSize(width: 1920, height: 1080), CGSize(width: 1080, height: 1920), CGSize(width: 3440, height: 1440)] {
            for x in [0.0, 0.5, 1.0] {
                var scene = DemoScene(background: "photo.png"); scene.phoneX = x; scene.phoneY = x; scene.phoneHeight = 0.96
                let frame = SceneRenderer.phoneRect(scene, in: size)
                XCTAssertTrue(CGRect(origin: .zero, size: size).contains(frame))
                XCTAssertGreaterThan(frame.width, 0)
            }
        }
    }
    func testRenderAndImportedImageSurviveSourceRemoval() throws {
        let root = try temporary(); defer { try? FileManager.default.removeItem(at: root) }
        let image = NSImage(size: CGSize(width: 80, height: 45), flipped: false) { rect in
            NSColor.red.setFill(); rect.fill(); return true
        }
        let scene = DemoScene(background: "source.png")
        let data = try SceneRenderer.png(scene, image: image, size: CGSize(width: 800, height: 450))
        let bitmap = NSBitmapImageRep(data: data)!
        XCTAssertEqual(bitmap.pixelsWide, 800); XCTAssertEqual(bitmap.pixelsHigh, 450)
        XCTAssertGreaterThan(bitmap.colorAt(x: 5, y: 5)!.redComponent, 0.9)
        let source = root.appendingPathComponent("source.png"); try data.write(to: source)
        let modelRoot = root.appendingPathComponent("store")
        let model = DemoScenes(root: modelRoot)
        try model.addImage(source, name: "Demo reception")
        let imported = model.selected!
        try FileManager.default.removeItem(at: source)
        let reloaded = DemoScenes(root: modelRoot)
        XCTAssertEqual(reloaded.scenes.first?.name, "Demo reception")
        XCTAssertNotNil(reloaded.image(for: imported))
        reloaded.duplicate()
        XCTAssertEqual(reloaded.scenes.count, 2)
        XCTAssertEqual(reloaded.scenes[0].background, reloaded.scenes[1].background)
        reloaded.remove()
        XCTAssertNotNil(reloaded.image(for: imported))
    }
}
