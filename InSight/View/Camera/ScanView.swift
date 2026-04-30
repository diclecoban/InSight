import SwiftUI
import AVFoundation

struct ScanView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var scanner = BarcodeScanner()
    @State private var scannedCode: String = ""
    @State private var showResult = false

    var body: some View {
        ZStack {
            CameraPreview(session: scanner.session)
                .ignoresSafeArea()

            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack {
                HStack {
                    Button {
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }

                    Spacer()

                    VStack(spacing: 3) {
                        Text("Scan a barcode")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Place the code inside the frame")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.78))
                    }

                    Spacer()

                    Color.clear
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal, 24)
                .padding(.top, 14)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.9), lineWidth: 2)
                        .frame(width: 280, height: 380)

                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.clear)
                        .frame(width: 280, height: 380)
                        .blendMode(.destinationOut)

                    VStack {
                        Rectangle()
                            .fill(Color(red: 0.953, green: 0.643, blue: 0.286))
                            .frame(width: 210, height: 3)
                            .shadow(color: Color(red: 0.953, green: 0.643, blue: 0.286).opacity(0.7), radius: 8)

                        Spacer()
                    }
                    .frame(width: 280, height: 330)
                }

                Spacer()

                HStack {
                    ActionIcon(symbol: "photo.on.rectangle.angled")

                    Spacer()

                    Button {
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 82, height: 82)

                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 68, height: 68)

                            Circle()
                                .fill(Color.white)
                                .frame(width: 56, height: 56)
                        }
                    }

                    Spacer()

                    Button {
                        scanner.toggleFlash()
                    } label: {
                        ActionIcon(symbol: scanner.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                    }
                }
                .padding(.horizontal, 34)
                .padding(.bottom, 34)
            }
        }
        .compositingGroup()
        .onAppear { scanner.startSession() }
        .onDisappear { scanner.stopSession() }
        .alert("Barkod Okundu", isPresented: $showResult) {
            Button("Tamam") {
            }
        } message: {
            Text(scannedCode)
        }
        .onChange(of: scanner.scannedCode) { _, newValue in
            if let code = newValue {
                scannedCode = code
                showResult = true
                Task {
                    await appState.analyzeBarcode(code)
                }
            }
        }
    }
}

private struct ActionIcon: View {
    let symbol: String

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
    }
}

#Preview {
    ScanView()
        .environment(AppStateViewModel())
}
