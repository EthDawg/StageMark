import SwiftUI

struct SceneStarterGallery: View {
    @Environment(\.dismiss) private var dismiss
    let choose: (SceneStarter) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Choose a starting point").font(.title2.weight(.semibold))
                    Text("Make it yours with a customer logo and a name.").foregroundStyle(.secondary)
                }
                Spacer()
                Button("Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
            }
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ForEach(["Everyday settings", "Australian sectors"], id: \.self) { group in
                        Text(group).font(.headline)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(SceneStarters.all.filter { $0.group == group }) { starter in
                                SceneStarterCard(starter: starter) { choose(starter) }
                            }
                        }
                    }
                }
            }
            Text("Fictional settings made with AI · Available offline").font(.caption).foregroundStyle(.secondary)
        }.padding(24).frame(width: 680, height: 610)
            .background(Workbench.background).tint(Workbench.accent).workbenchTheme()
    }
}

private struct SceneStarterCard: View {
    let starter: SceneStarter
    let choose: () -> Void
    @State private var thumbnail: NSImage?
    var body: some View {
        Button(action: choose) {
            VStack(alignment: .leading, spacing: 0) {
                if let thumbnail {
                    Image(nsImage: thumbnail).resizable().aspectRatio(contentMode: .fit)
                } else {
                    Rectangle().fill(.quaternary).aspectRatio(16.0 / 9.0, contentMode: .fit)
                        .overlay(Image(systemName: "photo"))
                }
                HStack {
                    Text(starter.name).font(.subheadline.weight(.medium))
                    Spacer(minLength: 4)
                    Image(systemName: "plus.circle.fill").foregroundStyle(Workbench.accent)
                }.padding(12)
            }.background(Workbench.surface, in: RoundedRectangle(cornerRadius: 10))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(.primary.opacity(0.1)))
                .contentShape(Rectangle())
        }.buttonStyle(.plain).disabled(thumbnail == nil)
            .accessibilityLabel("Use \(starter.name)")
            .onAppear { if thumbnail == nil { thumbnail = starter.thumbnail() } }
    }
}
