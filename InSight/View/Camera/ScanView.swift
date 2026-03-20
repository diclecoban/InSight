//
//  ScanView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 20.03.2026.
//

import SwiftUI
import AVFoundation

struct ScanView: View {
    @State private var scanner = BarcodeScanner()
    @State private var scannedCode: String = ""
    @State private var showResult = false
    
    var body: some View {
        ZStack {
            // Kamera önizlemesi
            CameraPreview(session: scanner.session)
                .ignoresSafeArea()
            
            // Koyu arka plan (kamera alanı dışı)
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            // Kamera görüş alanı (ortadaki açık alan)
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 280, height: 400)
                .blendMode(.destinationOut)
            
            // Alt toolbar
            VStack {
                Spacer()
                HStack {
                    // Galeri butonu
                    Button {
                        // galeri açma
                    } label: {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                    }
                    
                    Spacer()
                    
                    // Fotoğraf butonu
                    Button {
                        // çekim
                    } label: {
                        Image(systemName: "camera.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Flaş butonu
                    Button {
                        scanner.toggleFlash()
                    } label: {
                        Image(systemName: scanner.isFlashOn ? "bolt.fill" : "bolt.slash")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .background(Color.black.opacity(0.6))
            }
        }
        .compositingGroup()
        .onAppear { scanner.startSession() }
        .onDisappear { scanner.stopSession() }
        .alert("Barkod Okundu", isPresented: $showResult) {
            Button("Tamam") { }
        } message: {
            Text(scannedCode)
        }
        .onChange(of: scanner.scannedCode) { oldValue, newValue in
            if let code = newValue {
                scannedCode = code
                showResult = true
            }
        }
    }
}

#Preview {
    ScanView()
}
