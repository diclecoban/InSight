//
//  BarcodeScanner.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 20.03.2026.
//

import AVFoundation
import SwiftUI

@Observable
class BarcodeScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var scannedCode: String?
    var isFlashOn = false
    
    let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        self.device = device
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        
        // Barkod tipleri
        output.metadataObjectTypes = [
            .ean8, .ean13, .qr, .upce, .code128
        ]
    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func toggleFlash() {
        guard let device = device, device.hasTorch else { return }
        try? device.lockForConfiguration()
        isFlashOn.toggle()
        device.torchMode = isFlashOn ? .on : .off
        device.unlockForConfiguration()
    }
    
    // Barkod okunduğunda çağrılır
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput objects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let object = objects.first as? AVMetadataMachineReadableCodeObject {
            scannedCode = object.stringValue
            stopSession()
        }
    }
}
