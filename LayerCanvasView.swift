import SwiftUI

struct LayerCanvasView: View {
    @Binding var layer: TendiesLayer
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        Group {
            switch layer.type {
            case .text:
                Text(layer.text)
                    .font(.system(size: layer.fontSize, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: layer.colorHex))
                    .padding(8)

            case .badge:
                Text(layer.text)
                    .font(.system(size: layer.fontSize, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color(hex: layer.colorHex).opacity(0.85))
                    .clipShape(Capsule())

            case .gradientOrb:
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: layer.colorHex), Color(hex: layer.colorHex).opacity(0.0)],
                            center: .center,
                            startRadius: 5,
                            endRadius: 90
                        )
                    )
                    .frame(width: 180, height: 180)
                    .blur(radius: 12)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.cyan : Color.clear, lineWidth: 1.5)
        )
        .scaleEffect(layer.scale)
        .rotationEffect(.degrees(layer.rotationDegrees))
        .offset(x: layer.x + dragOffset.width, y: layer.y + dragOffset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    onSelect()
                    dragOffset = value.translation
                }
                .onEnded { value in
                    layer.x += value.translation.width
                    layer.y += value.translation.height
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            onSelect()
        }
    }
}
