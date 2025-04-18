//
//  FaceCaptureViewModel.swift
//  FaceMatch
//
//  Created by Enzo Luigi Schork on 09/04/25.
//

import AVFoundation
import UIKit
import Combine

final class FaceCaptureViewModel: NSObject, ObservableObject {
    // MARK: - Properties
    let session = AVCaptureSession()
    private let context = CIContext()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var cancellables = Set<AnyCancellable>()
    private var frameProcessor: VideoFrameProcessor?
    private let enrollmentService = EnrollmentService()

    @Published var currentFrame: UIImage?
    @Published var similarityScore: Float = 0
    @Published var detectionStatus: String = ""
    @Published var statusLog: String = ""
    @Published var isRegistering: Bool = false
    @Published var isVerifying: Bool = false

    // MARK: - Properties
    override init() {
        super.init()
        setupSession()
        observeFrames()
    }

    func startSession() {
        session.startRunning()
    }

    func stopSession() {
        session.stopRunning()
    }

    func clearEnrollments() {
        enrollmentService.clear()
        similarityScore = 0
    }
}

// MARK: - Methods
private extension FaceCaptureViewModel {

    func observeFrames() {
        $currentFrame
            .compactMap { $0 }
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] image in
                Task { @MainActor in
                    await self?.handleFrame(image)
                }
            }
            .store(in: &cancellables)
    }

    func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("❌ Erro ao configurar a câmera")
            return
        }

        session.addInput(input)

        frameProcessor = VideoFrameProcessor { [weak self] frame in
            Task { @MainActor in
                self?.currentFrame = frame
            }
        }

        videoOutput.setSampleBufferDelegate(frameProcessor, queue: DispatchQueue(label: "frame.queue"))

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()
    }

    func handleFrame(_ image: UIImage) async {
        if isRegistering {
            await processRegistration(image)
            return
        }

        if isVerifying {
            await processVerification(image)
        }
    }

    func processRegistration(_ image: UIImage) async {
        guard let cropped = await FaceCropper.cropFace(from: image) else {
            Task { @MainActor in
                self.statusLog = "❌ Falha ao registrar rosto"
                self.isRegistering = false
            }
            return
        }

        await enrollmentService.enrollNewFace(cropped)

        Task { @MainActor in
            self.statusLog = "✅ Rosto registrado com sucesso!"
            self.detectionStatus = "🔍 Iniciando verificação..."
            self.isRegistering = false
            self.isVerifying = true
        }
    }

    func processVerification(_ image: UIImage) async {
        guard !enrollmentService.enrolledEmbeddings.isEmpty else {
            Task { @MainActor in
                detectionStatus = "⏳ Aguardando cadastro de rosto..."
            }
            return
        }

        guard let cropped = await FaceCropper.cropFace(from: image),
              let embedding = EmbeddingService.shared.generateEmbedding(from: cropped) else {
            Task { @MainActor in
                detectionStatus = "❌ Rosto não reconhecido"
            }
            return
        }

        let score = enrollmentService.bestMatch(for: embedding)

        Task { @MainActor in
            similarityScore = score
            detectionStatus = score > 0.93 ? "✅ Rosto reconhecido!" : "⚠️ Não corresponde"
        }
    }
    
}
