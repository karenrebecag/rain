import AppKit
import SpriteKit

final class Raindrop: SKSpriteNode {
    var velocity: CGVector = .zero
}

// Everything is drawn white so sprites tint it with `color` + `colorBlendFactor`. Textures are
// rendered at 2x and shared app-wide, so hundreds of sprites cost a single draw call.
enum RainTextures {
    static let streakSize = CGSize(width: 1, height: 22)
    static let glowSize = CGSize(width: 12, height: 12)
    static let discSize = CGSize(width: 8, height: 8)
    private static let scale: CGFloat = 2

    static let streak = SKTexture(cgImage: streakImage())
    static let glow = SKTexture(cgImage: glowImage())
    static let disc = SKTexture(cgImage: discImage())

    static func streakImage() -> CGImage {
        render(streakSize) { context, rect in
            let colors = [white(alpha: 0), white(alpha: 0.55), white(alpha: 1)] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.7, 1])!
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: rect.maxY), end: CGPoint(x: 0, y: rect.minY), options: [])
        }
    }

    // Gaussian-like falloff: a hard radial gradient reads as a disc, not light.
    static func glowImage() -> CGImage {
        render(glowSize) { context, rect in
            let colors = [white(alpha: 1), white(alpha: 0.6), white(alpha: 0.22), white(alpha: 0.05), white(alpha: 0)] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.3, 0.6, 0.85, 1])!
            let center = CGPoint(x: rect.midX, y: rect.midY)
            context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: rect.width / 2, options: [])
        }
    }

    static func discImage() -> CGImage {
        render(discSize) { context, rect in
            context.setFillColor(white(alpha: 1))
            context.fillEllipse(in: rect.insetBy(dx: 0.5, dy: 0.5))
        }
    }

    private static func white(alpha: CGFloat) -> CGColor {
        CGColor(red: 1, green: 1, blue: 1, alpha: alpha)
    }

    private static func render(_ size: CGSize, draw: (CGContext, CGRect) -> Void) -> CGImage {
        let width = Int(size.width * scale), height = Int(size.height * scale)
        let context = CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setShouldAntialias(true)
        draw(context, CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()!
    }
}
