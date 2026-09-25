import CoreGraphics
import Testing
@testable import Rain

// Renders a CGImage into a known RGBA buffer; row 0 is the top of the image.
private func alphaSampler(_ image: CGImage) -> (_ x: Int, _ y: Int) -> Double {
    let width = image.width, height = image.height
    var pixels = [UInt8](repeating: 0, count: width * height * 4)
    pixels.withUnsafeMutableBytes { buffer in
        let context = CGContext(
            data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    return { x, y in Double(pixels[(y * width + x) * 4 + 3]) / 255 }
}

struct RainTexturesTests {
    @Test func texturesAreRenderedAtRetinaScale() {
        #expect(RainTextures.streakImage().width == Int(RainTextures.streakSize.width * 2))
        #expect(RainTextures.streakImage().height == Int(RainTextures.streakSize.height * 2))
        #expect(RainTextures.glowImage().width == Int(RainTextures.glowSize.width * 2))
        #expect(RainTextures.discImage().width == Int(RainTextures.discSize.width * 2))
    }

    @Test func streakIsThinAndLong() {
        #expect(RainTextures.streakSize.width <= 1)
        #expect(RainTextures.streakSize.height >= 18)
    }

    // The leading (bottom) end of a falling streak is solid and the tail fades out.
    @Test func streakFadesTowardsTheTail() {
        let image = RainTextures.streakImage()
        let alpha = alphaSampler(image)
        #expect(alpha(0, image.height - 1) > 0.8)
        #expect(alpha(0, 0) < 0.15)
        #expect(alpha(0, image.height / 2) > alpha(0, 0))
    }

    @Test func glowIsSoftAndRound() {
        let image = RainTextures.glowImage()
        let alpha = alphaSampler(image)
        let center = image.width / 2
        #expect(alpha(center, center) > 0.85)
        #expect(alpha(0, 0) < 0.01)
        let halfway = alpha(center + image.width / 4, center)
        #expect(halfway > 0.1 && halfway < 0.8)
    }

    @Test func discIsSolidWithAClearCorner() {
        let image = RainTextures.discImage()
        let alpha = alphaSampler(image)
        #expect(alpha(image.width / 2, image.height / 2) > 0.95)
        #expect(alpha(0, 0) < 0.01)
    }
}
