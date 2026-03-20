//
//  CameraPreview.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 20.03.2026.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> CameraView {
        let view = CameraView()
        view.session = session
        return view
    }
    
    func updateUIView(_ uiView: CameraView, context: Context) {}
}

class CameraView: UIView {
    var session: AVCaptureSession?
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = bounds // bounds artık doğru boyutta
    }
}

#Preview {
    CameraPreview(session: .init())
}
