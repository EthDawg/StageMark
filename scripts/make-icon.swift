import AppKit

let directory = URL(fileURLWithPath: "build/AppIcon.iconset")
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
        let transform = NSAffineTransform(); transform.scale(by: CGFloat(pixels) / 1024); transform.concat()
        let base = NSBezierPath(roundedRect: NSRect(x: 34, y: 34, width: 956, height: 956), xRadius: 216, yRadius: 216)
        NSGradient(starting: NSColor(srgbRed: 0.15, green: 0.20, blue: 0.26, alpha: 1), ending: NSColor(srgbRed: 0.035, green: 0.055, blue: 0.09, alpha: 1))!.draw(in: base, angle: -65)
        NSColor.white.withAlphaComponent(0.14).setStroke(); base.lineWidth = 3; base.stroke()
        let ring = NSBezierPath(); ring.appendArc(withCenter: NSPoint(x: 500, y: 520), radius: 275, startAngle: 25, endAngle: 290, clockwise: false)
        NSColor(srgbRed: 0.43, green: 0.89, blue: 0.73, alpha: 1).setStroke(); ring.lineWidth = 62; ring.lineCapStyle = .round; ring.stroke()
        let pen = NSBezierPath(); pen.move(to: NSPoint(x: 400, y: 354)); pen.line(to: NSPoint(x: 638, y: 703)); pen.line(to: NSPoint(x: 731, y: 640)); pen.line(to: NSPoint(x: 493, y: 291)); pen.close()
        NSColor(srgbRed: 0.94, green: 0.98, blue: 0.97, alpha: 1).setFill(); pen.fill()
        let nib = NSBezierPath(); nib.move(to: NSPoint(x: 389, y: 332)); nib.line(to: NSPoint(x: 473, y: 275)); nib.line(to: NSPoint(x: 373, y: 254)); nib.close()
        NSColor(srgbRed: 0.43, green: 0.89, blue: 0.73, alpha: 1).setFill(); nib.fill()
        NSGraphicsContext.restoreGraphicsState()
        let name = "icon_\(size)x\(size)\(scale == 2 ? "@2x" : "").png"
        try bitmap.representation(using: .png, properties: [:])!.write(to: directory.appendingPathComponent(name))
    }
}
