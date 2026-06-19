import AVFoundation
import SwiftUI

@Observable
class BarcodeScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var scannedCode: String?
    var isFlashOn = false
    var errorMessage: String?
    
    let session = AVCaptureSession()
    private var device: AVCaptureDevice?
    private var didConfigureSession = false
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func setupCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureSession()
                        self?.startSession()
                    } else {
                        self?.errorMessage = String(localized: "Camera access is required to scan barcodes.")
                    }
                }
            }
        case .denied, .restricted:
            errorMessage = String(localized: "Camera access is required to scan barcodes.")
        @unknown default:
            errorMessage = String(localized: "Camera access could not be verified.")
        }
    }

    private func configureSession() {
        guard !didConfigureSession else { return }
        guard let device = AVCaptureDevice.default(for: .video) else {
            errorMessage = String(localized: "No camera was found on this device.")
            return
        }

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            errorMessage = String(localized: "The camera could not be started.")
            return
        }

        self.device = device

        guard session.canAddInput(input) else {
            errorMessage = String(localized: "The camera input could not be added.")
            return
        }
        session.addInput(input)
        
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            errorMessage = String(localized: "The barcode scanner could not be started.")
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        
        // Barcode types
        output.metadataObjectTypes = [
            .ean8, .ean13, .qr, .upce, .code128
        ]

        didConfigureSession = true
    }
    
    func startSession() {
        guard didConfigureSession else { return }
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        session.stopRunning()
    }

    func resetScan() {
        scannedCode = nil
    }
    
    func toggleFlash() {
        guard let device = device, device.hasTorch else { return }
        try? device.lockForConfiguration()
        isFlashOn.toggle()
        device.torchMode = isFlashOn ? .on : .off
        device.unlockForConfiguration()
    }
    
    // Called when a barcode is scanned
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput objects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let object = objects.first as? AVMetadataMachineReadableCodeObject,
           let code = object.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
           !code.isEmpty {
            scannedCode = code
            stopSession()
        }
    }
}
