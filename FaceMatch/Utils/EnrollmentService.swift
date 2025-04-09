//
//  EnrollmentService.swift
//  FaceMatch
//
//  Created by Enzo Luigi Schork on 09/04/25.
//

import UIKit

class EnrollmentService {
    // MARK: - Properties
    var enrolledEmbeddings: [[Float]] = []

    func enrollNewFace(_ image: UIImage) async {
        guard let cropped = await FaceCropper.cropFace(from: image) else {
            print("❌ Falha ao detectar e recortar rosto")
            return
        }

        guard let embedding = EmbeddingService.shared.generateEmbedding(from: cropped) else {
            print("❌ Falha ao gerar embedding")
            return
        }

        self.enrolledEmbeddings.append(embedding)
        print("✅ Embedding adicionado com sucesso")
    }

    func bestMatch(for inputEmbedding: [Float]) -> Float {
        enrolledEmbeddings.map {
            cosineSimilarity($0, inputEmbedding)
        }.max() ?? 0
    }

    func clear() {
        enrolledEmbeddings.removeAll()
    }
}

// MARK: - Methods
private extension EnrollmentService {

    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count else { return 0 }
        var dot: Float = 0, normA: Float = 0, normB: Float = 0

        for i in 0..<a.count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }

        return dot / (sqrt(normA) * sqrt(normB))
    }
}
