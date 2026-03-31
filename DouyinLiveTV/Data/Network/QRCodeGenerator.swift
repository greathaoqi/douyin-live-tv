import CoreImage
import UIKit

public func generateQRCode(from string: String, size: CGSize) -> UIImage? {
    let data = string.data(using: .utf8)
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
        return nil
    }
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")

    guard let outputImage = filter.outputImage else {
        return nil
    }

    let scaleX = size.width / outputImage.extent.size.width
    let scaleY = size.height / outputImage.extent.size.height
    let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
    let scaledImage = outputImage.transformed(by: transform)

    let context = CIContext()
    guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
        return nil
    }

    return UIImage(cgImage: cgImage)
}
