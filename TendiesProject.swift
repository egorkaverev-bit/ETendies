import Foundation
import SwiftUI

struct TendiesLayer: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var type: LayerType
    var text: String
    var colorHex: String
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var rotationDegrees: Double
    var fontSize: CGFloat

    enum LayerType: String, Codable {
        case text
        case badge
        case gradientOrb
    }
}

struct TendiesWallpaperManifest: Codable {
    var version: String = "1.0"
    var appName: String = "ETendies Mobile"
    var createdAt: Date = Date()
    var backgroundHex: String
    var secondaryBackgroundHex: String
    var useGradientBackground: Bool
    var layers: [TendiesLayer]
}
