//
//  StoryQRScannerView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/13/25.
//

import AVFoundation
import SwiftUI
import Vision

struct StoryQRScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var alerter = AlertManager.shared
    
    private let captureSession = AVCaptureSession()
    
    var body: some View {
        ZStack {
            CameraPreview(session: captureSession) { qrCode in
                guard let storyDto = qrCode.decode(as: StoryDTO.self) else { return }
                captureSession.stopRunning()
                alerter.presentImportStoryAlert(for: storyDto)
                dismiss()
            }
            .ignoresSafeArea()
            
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .imageScale(.large)
                .foregroundStyle(.orange.gradient)
        }
        .overlay(alignment: .topTrailing) {
            Button("Dismiss", systemImage: "xmark") {
                dismiss()
            }
            .font(.headline.bold())
            .imageScale(.large)
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
            .padding(24)
        }
    }
}

#Preview {
    StoryQRScannerView()
}

private struct CameraPreview: UIViewControllerRepresentable {
    var session: AVCaptureSession?
    var onQRCodeDetected: (QRCode) -> Void
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIViewController()
        let session = session ?? AVCaptureSession()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(videoInput) else { return controller }
        
        session.beginConfiguration()
        
        session.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "com.nozhana.Novelty.CameraPreview.videoOutputQueue"))
            session.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = controller.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        controller.view.layer.addSublayer(previewLayer)
        
        session.commitConfiguration()
        
        session.startRunning()
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension CameraPreview {
    final class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let parent: CameraPreview
        
        init(parent: CameraPreview) {
            self.parent = parent
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let request = VNDetectBarcodesRequest()
            request.symbologies = [.qr]
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
            
            do {
                try handler.perform([request])
                if let result = request.results?.first,
                   let payloadString = result.payloadStringValue,
                   let payload = payloadString.data(using: .utf8) {
                    let qrCode = QRCode(payload: payload, bounds: result.boundingBox)
                    DispatchQueue.main.async { [weak self] in
                        self?.parent.onQRCodeDetected(qrCode)
                    }
                }
            } catch {
                print("Failed to detect QR codes. \(error)")
            }
        }
    }
}

struct QRCode {
    var payload: Data
    var bounds: CGRect
    
    func decode<T>(as type: T.Type = T.self) -> T? where T: Decodable {
        guard let decoded = try? JSONDecoder().decode(type, from: payload) else { return nil }
        return decoded
    }
}
