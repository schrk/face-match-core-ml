//
//  FaceCaptureView.swift
//  FaceMatch
//
//  Created by Enzo Luigi Schork on 09/04/25.
//


import SwiftUI

struct FaceCaptureView: View {
    // MARK: - Properties
    @StateObject private var viewModel = FaceCaptureViewModel()

    // MARK: - Body
    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.session)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text("📸 Posicione seu rosto")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(.black.opacity(0.6))
                    .clipShape(Capsule())
                    .padding(.bottom, 40)
            }
        }
    }
}
