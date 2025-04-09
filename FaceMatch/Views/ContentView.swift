//
//  ContentView.swift
//  FaceMatch
//
//  Created by Enzo Luigi Schork on 09/04/25.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var viewModel = FaceCaptureViewModel()

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            Text("🔍 Similaridade: \(String(format: "%.2f", viewModel.similarityScore))")
                .font(.title2)

            Text(viewModel.detectionStatus)
                .font(.headline)
                .foregroundColor(.blue)

            CameraPreview(session: viewModel.session)
                .frame(height: 300)
                .cornerRadius(12)

            Text(viewModel.statusLog)
                .font(.callout)
                .foregroundColor(.gray)

            Button("Registrar rosto") {
                viewModel.isRegistering = true
                viewModel.detectionStatus = "📸 Capturando rosto..."
            }

            Button("Limpar registros") {
                viewModel.clearEnrollments()
                viewModel.detectionStatus = "🗑 Rosto removido"
            }
        }
        .padding()
        .onAppear {
            viewModel.startSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}
