import Foundation
import SwiftUI

final class ExportManager {
    static let shared = ExportManager()
    private init() {}

    @MainActor
    func buildTendiesFile(manifest: TendiesWallpaperManifest, previewImage: UIImage?) throws -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = "ETendies_\(Int(Date().timeIntervalSince1970)).tendies"
        let destinationURL = docs.appendingPathComponent(fileName)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        var payload: [String: Any] = [:]
        let manifestData = try encoder.encode(manifest)
        if let manifestDict = try JSONSerialization.jsonObject(with: manifestData) as? [String: Any] {
            payload["manifest"] = manifestDict
        }

        if let image = previewImage, let pngData = image.pngData() {
            payload["preview_base64"] = pngData.base64EncodedString()
        }

        let finalData = try JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted])
        try finalData.write(to: destinationURL, options: .atomic)
        return destinationURL
    }
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let r, g, b: UInt64
        switch clean.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (20, 20, 25)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: 1.0
        )
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
