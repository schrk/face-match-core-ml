//
//  FaceCropper.swift
//  FaceMatch
//
//  Created by Enzo Luigi Schork on 09/04/25.
//

import Vision
import UIKit

class FaceCropper {

    static func cropFace(from image: UIImage) async -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            guard let results = request.results, let face = results.first else {
                print("❌ Nenhum rosto detectado")
                return nil
            }

            let boundingBox = face.boundingBox
            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)

            let rect = CGRect(
                x: boundingBox.origin.x * width,
                y: (1 - boundingBox.origin.y - boundingBox.height) * height,
                width: boundingBox.width * width,
                height: boundingBox.height * height
            )

            if let croppedCgImage = cgImage.cropping(to: rect) {
                return UIImage(cgImage: croppedCgImage)
            } else {
                print("❌ Falha ao recortar o rosto")
                return nil
            }

        } catch {
            print("❌ Erro ao detectar rosto: \(error)")
            return nil
        }
    }
}
