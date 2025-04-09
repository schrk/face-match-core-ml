//
//  EmbeddingService.swift
//  FaceMatch
//
//  Created by Enzo Luigi Schork on 09/04/25.
//

import CoreML
import UIKit

class EmbeddingService {
    // MARK: - Properties
    static let shared = EmbeddingService()
    private let model: FastViT

    // MARK: - Inits
    private init() {
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndGPU
        self.model = try! FastViT(configuration: config)
    }

    func generateEmbedding(from image: UIImage) -> [Float]? {
        let resized = image.resized(to: CGSize(width: 256, height: 256))
        guard let buffer = resized.toCVPixelBuffer(),
              let output = try? model.prediction(image: buffer) else {
            return nil
        }

        return output.imageFeaturesShapedArray.scalars
    }
}
