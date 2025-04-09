//
//  CameraPreview.swift
//  FaceMatch
//
//  Created by Enzo Luigi Schork on 09/04/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    // MARK: - Properties
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.setup(session: session)
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.updateVideoOrientation()
    }
}

extension CameraPreview {

    class PreviewView: UIView {
        // MARK: - Properties
        private var previewLayer: AVCaptureVideoPreviewLayer?

        func setup(session: AVCaptureSession) {
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            self.layer.insertSublayer(layer, at: 0)
            previewLayer = layer
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer?.frame = bounds
        }

        func updateVideoOrientation() {
            guard let connection = previewLayer?.connection else { return }
            connection.videoOrientation = .portrait
        }
    }
}
