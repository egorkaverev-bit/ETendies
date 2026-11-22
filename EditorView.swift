import SwiftUI

struct EditorView: View {
    @State private var bgColor: Color = Color(hex: "#0D0F18")
    @State private var bgSecondaryColor: Color = Color(hex: "#1E2642")
    @State private var useGradient: Bool = true
    @State private var layers: [TendiesLayer] = [
        TendiesLayer(
            type: .gradientOrb,
            text: "",
            colorHex: "#3B82F6",
            x: -60,
            y: -110,
            scale: 1.2,
            rotationDegrees: 0,
            fontSize: 24
        ),
        TendiesLayer(
            type: .text,
            text: "ETendies",
            colorHex: "#FFFFFF",
            x: 0,
            y: 0,
            scale: 1.0,
            rotationDegrees: 0,
            fontSize: 34
        )
    ]
    @State private var selectedID: UUID?
    @State private var exportedURL: URL?
    @State private var statusMessage: String = "Готово к сборке .tendies"

    private var selectedIndex: Int? {
        layers.firstIndex { $0.id == selectedID }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                canvasView
                    .frame(width: 240, height: 480)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                    )
                    .shadow(radius: 12)

                controlsPanel

                HStack(spacing: 10) {
                    Button("Экспорт .tendies") {
                        exportTendies()
                    }
                    .buttonStyle(.borderedProminent)

                    if let url = exportedURL {
                        ShareLink(item: url) {
                            Label("Поделиться", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Text(statusMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .navigationTitle("ETendies Mobile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var canvasView: some View {
        ZStack {
            if useGradient {
                LinearGradient(
                    colors: [bgColor, bgSecondaryColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                bgColor
            }

            ForEach($layers) { $layer in
                LayerCanvasView(
                    layer: $layer,
                    isSelected: layer.id == selectedID,
                    onSelect: { selectedID = layer.id }
                )
            }
        }
    }

    private var controlsPanel: some View {
        VStack(spacing: 10) {
            HStack {
                ColorPicker("Фон 1", selection: $bgColor)
                if useGradient {
                    ColorPicker("Фон 2", selection: $bgSecondaryColor)
                }
                Toggle("Градиент", isOn: $useGradient)
                    .labelsHidden()
            }

            HStack(spacing: 8) {
                Button("+ Текст") {
                    let item = TendiesLayer(
                        type: .text,
                        text: "Новый текст",
                        colorHex: "#FFFFFF",
                        x: 0,
                        y: 40,
                        scale: 1.0,
                        rotationDegrees: 0,
                        fontSize: 26
                    )
                    layers.append(item)
                    selectedID = item.id
                }
                .buttonStyle(.bordered)

                Button("+ Бейдж") {
                    let item = TendiesLayer(
                        type: .badge,
                        text: "IOS",
                        colorHex: "#6366F1",
                        x: 0,
                        y: 90,
                        scale: 1.0,
                        rotationDegrees: 0,
                        fontSize: 16
                    )
                    layers.append(item)
                    selectedID = item.id
                }
                .buttonStyle(.bordered)

                Button("+ Сфера") {
                    let item = TendiesLayer(
                        type: .gradientOrb,
                        text: "",
                        colorHex: "#EC4899",
                        x: 50,
                        y: -50,
                        scale: 1.0,
                        rotationDegrees: 0,
                        fontSize: 20
                    )
                    layers.append(item)
                    selectedID = item.id
                }
                .buttonStyle(.bordered)
            }

            if let idx = selectedIndex {
                VStack(spacing: 6) {
                    if layers[idx].type != .gradientOrb {
                        TextField("Текст слоя", text: $layers[idx].text)
                            .textFieldStyle(.roundedBorder)
                    }

                    HStack {
                        Text("Масштаб")
                            .font(.caption)
                        Slider(value: $layers[idx].scale, in: 0.4...2.5)

                        Button(role: .destructive) {
                            let idToRemove = layers[idx].id
                            layers.removeAll { $0.id == idToRemove }
                            selectedID = nil
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
            }
        }
    }

    @MainActor
    private func exportTendies() {
        let renderer = ImageRenderer(content: canvasView.frame(width: 1179, height: 2556))
        renderer.scale = 1.0
        let uiImage = renderer.uiImage

        let manifest = TendiesWallpaperManifest(
            backgroundHex: bgColor.toHex(),
            secondaryBackgroundHex: bgSecondaryColor.toHex(),
            useGradientBackground: useGradient,
            layers: layers
        )

        do {
            let url = try ExportManager.shared.buildTendiesFile(manifest: manifest, previewImage: uiImage)
            exportedURL = url
            statusMessage = "Сохранено: \(url.lastPathComponent)"
        } catch {
            statusMessage = "Ошибка: \(error.localizedDescription)"
        }
    }
}
