import AppKit
import SwiftUI

struct DemoScenesView: View {
    @ObservedObject var model: DemoScenes
    @State private var search = ""
    @State private var rename = ""
    @State private var confirmingRemoval = false
    private var filtered: [DemoScene] {
        model.scenes.filter { search.isEmpty || $0.name.localizedCaseInsensitiveContains(search) }
    }
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                WorkbenchHeader(title: "Demo scenes", subtitle: "A familiar setting. Ready again.", symbol: "iphone.and.landscape")
                TextField("Find a customer or scene", text: $search).textFieldStyle(.roundedBorder)
                    .accessibilityLabel("Find a scene")
                List(selection: $model.selectedID) {
                    ForEach(filtered) { scene in
                        HStack(spacing: 9) {
                            Image(systemName: scene.showsPhone ? "iphone" : "photo").foregroundStyle(Workbench.accent)
                            Text(scene.name).lineLimit(2)
                        }.padding(.vertical, 5).tag(scene.id)
                    }
                }.listStyle(.sidebar)
                Button { model.importImage() } label: { Label("Add backdrop…", systemImage: "plus") }
                    .buttonStyle(.borderedProminent).disabled(model.storageBlocked)
                Text("Images and layouts stay on this Mac.")
                    .font(.caption).foregroundStyle(.secondary)
            }.padding(18).frame(width: 245)
            Divider()
            VStack(alignment: .leading, spacing: 16) {
                if let scene = model.selected {
                    HStack {
                        TextField("Scene name", text: $rename, onCommit: commitName)
                            .font(.title2.weight(.semibold)).textFieldStyle(.plain)
                            .onChange(of: model.selectedID) { _, _ in rename = model.selected?.name ?? "" }
                            .onAppear { rename = scene.name }
                        Button("Rename") { commitName() }.disabled(rename.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || rename == scene.name)
                        Menu {
                            Button("Duplicate scene") { model.duplicate() }
                            Button("Remove scene…", role: .destructive) { confirmingRemoval = true }
                        } label: { Image(systemName: "ellipsis.circle") }.menuStyle(.borderlessButton).fixedSize()
                            .accessibilityLabel("Scene options")
                    }
                    if let image = model.image(for: scene) {
                        SceneCanvas(scene: scene, image: image) { value in model.update(value) }
                            .aspectRatio(model.screenAspect, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.primary.opacity(0.12)))
                            .accessibilityLabel("Scene preview. Drag the phone to position it; drag the background to crop it.")
                        HStack {
                            Text("Drag the phone to position it. Drag the backdrop to crop.")
                            Spacer()
                            Text("Saved automatically").foregroundStyle(Workbench.accent)
                        }.font(.caption).foregroundStyle(.secondary)
                        HStack(spacing: 22) {
                            Toggle("Phone frame", isOn: binding(\.showsPhone)).toggleStyle(.switch)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Phone size").font(.caption).foregroundStyle(.secondary)
                                Slider(value: binding(\.phoneHeight), in: 0.3...0.96).disabled(!scene.showsPhone)
                                    .accessibilityLabel("Phone size")
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Backdrop zoom").font(.caption).foregroundStyle(.secondary)
                                Slider(value: binding(\.zoom), in: 1...3).accessibilityLabel("Backdrop zoom")
                            }
                        }
                        HStack(spacing: 12) {
                            Text("Phone position").foregroundStyle(.secondary)
                            Button("Left") { position(0.12) }.disabled(!scene.showsPhone)
                            Button("Centre") { position(0.5) }.disabled(!scene.showsPhone)
                            Button("Right") { position(0.88) }.disabled(!scene.showsPhone)
                            Spacer()
                            Button("Reset layout") {
                                var reset = scene; reset.backgroundX = 0.5; reset.backgroundY = 0.5; reset.zoom = 1
                                reset.phoneX = 0.5; reset.phoneY = 0.5; reset.phoneHeight = 0.88
                                model.update(reset)
                            }.buttonStyle(.link)
                        }.font(.caption)
                        Divider()
                        HStack {
                            #if !APP_STORE
                            Button("Use as desktop") { model.applyDesktop() }.buttonStyle(.borderedProminent)
                            #endif
                            Button("Export image…") { model.exportPNG() }
                            Spacer()
                            Button("Open QuickTime") {
                                if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.QuickTimePlayerX") {
                                    NSWorkspace.shared.openApplication(at: url, configuration: .init())
                                } else { model.notice = "QuickTime Player could not be found on this Mac." }
                            }
                        }
                        Text("For a live iPhone demo, place QuickTime’s movie window over the phone screen. Positioning is manual.")
                            .font(.caption).foregroundStyle(.secondary)
                    } else {
                        ContentUnavailableView("Backdrop missing", systemImage: "photo.badge.exclamationmark", description: Text("Add the original image again to create a new scene."))
                    }
                } else {
                    VStack(spacing: 14) {
                        Image(systemName: "iphone.and.landscape").font(.system(size: 48)).foregroundStyle(Workbench.accent)
                        Text("Set the scene for your next demo").font(.title2.weight(.semibold))
                        Text("Add a reception, workplace or customer backdrop.\nMove the phone where it fits. It will be here next time.")
                            .multilineTextAlignment(.center).foregroundStyle(.secondary)
                        Button("Add backdrop…") { model.importImage() }.buttonStyle(.borderedProminent).disabled(model.storageBlocked)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Spacer(minLength: 0)
                if let notice = model.notice {
                    HStack(alignment: .top) {
                        Image(systemName: "info.circle")
                        Text(notice).textSelection(.enabled)
                        Spacer()
                        Button { model.notice = nil } label: { Image(systemName: "xmark") }.buttonStyle(.plain).accessibilityLabel("Dismiss notice")
                    }.font(.caption).padding(10).background(Workbench.surface, in: RoundedRectangle(cornerRadius: 8))
                }
                #if !APP_STORE
                if model.hasDesktopSnapshot {
                    HStack {
                        Text("Your previous desktop is saved.").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Button("Restore desktop") { model.restoreDesktop() }
                    }
                }
                #endif
            }.padding(24).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .background(Workbench.background).tint(Workbench.accent).workbenchTheme()
        .alert("Remove this scene?", isPresented: $confirmingRemoval) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) { model.remove() }
        } message: { Text("The saved layout will be removed. The imported picture stays on this Mac.") }
    }
    private func binding<T>(_ key: WritableKeyPath<DemoScene, T>) -> Binding<T> {
        let fallback = model.selected![keyPath: key]
        return Binding(get: { model.selected?[keyPath: key] ?? fallback }, set: { value in
            guard var scene = model.selected else { return }; scene[keyPath: key] = value; model.update(scene)
        })
    }
    private func position(_ x: Double) {
        guard var scene = model.selected else { return }; scene.phoneX = x; model.update(scene)
    }
    private func commitName() {
        guard var scene = model.selected else { return }
        let trimmed = rename.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { rename = scene.name; return }
        scene.name = String(trimmed.prefix(160)); model.update(scene)
    }
}

private struct SceneCanvas: NSViewRepresentable {
    let scene: DemoScene
    let image: NSImage
    let update: (DemoScene) -> Void
    func makeNSView(context: Context) -> SceneCanvasView { SceneCanvasView() }
    func updateNSView(_ view: SceneCanvasView, context: Context) {
        view.scene = scene; view.image = image; view.update = update; view.needsDisplay = true
    }
}

private final class SceneCanvasView: NSView {
    var scene: DemoScene?
    var image: NSImage?
    var update: ((DemoScene) -> Void)?
    private var origin = CGPoint.zero
    private var initial: DemoScene?
    private var movingPhone = false
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
    override func draw(_ dirtyRect: NSRect) {
        guard let scene, let image else { return }
        SceneRenderer.draw(scene, image: image, size: bounds.size)
    }
    override func mouseDown(with event: NSEvent) {
        origin = convert(event.locationInWindow, from: nil); initial = scene
        if let scene { movingPhone = scene.showsPhone && SceneRenderer.phoneRect(scene, in: bounds.size).contains(origin) }
    }
    override func mouseDragged(with event: NSEvent) {
        guard var draft = initial, let image else { return }
        let point = convert(event.locationInWindow, from: nil)
        let delta = CGPoint(x: point.x - origin.x, y: point.y - origin.y)
        if movingPhone {
            let frame = SceneRenderer.phoneRect(draft, in: bounds.size)
            draft.phoneX += delta.x / max(1, bounds.width - frame.width)
            draft.phoneY += delta.y / max(1, bounds.height - frame.height)
        } else {
            let scale = max(bounds.width / image.size.width, bounds.height / image.size.height) * draft.zoom
            let overflowX = image.size.width * scale - bounds.width
            let overflowY = image.size.height * scale - bounds.height
            if overflowX > 1 { draft.backgroundX -= delta.x / overflowX }
            if overflowY > 1 { draft.backgroundY -= delta.y / overflowY }
        }
        if let value = try? draft.validated() { update?(value) }
    }
}
