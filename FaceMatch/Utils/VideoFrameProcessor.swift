//
//  VideoFrameProcessor.swift
//  FaceMatch
//
//  Created by Enzo Luigi Schork on 09/04/25.
//

import UIKit
import AVFoundation

class VideoFrameProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Properties
    private let context = CIContext()
    private let onFrameCaptured: (UIImage) -> Void

    // MARK: - Inits
    init(onFrameCaptured: @escaping (UIImage) -> Void) {
        self.onFrameCaptured = onFrameCaptured
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        let image = UIImage(cgImage: cgImage)

        Task {
            self.onFrameCaptured(image)
        }
    }
}
