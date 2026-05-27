import SwiftUI
import AVFoundation

struct ScanView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var scanner = BarcodeScanner()
    @State private var scannedCode: String = ""
    @State private var showResult = false
    @State private var goToResult = false

    var body: some View {
        NavigationStack {
        ZStack {
            CameraPreview(session: scanner.session)
                .ignoresSafeArea()

            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack {
                HStack {
                    VStack(spacing: 3) {
                        Text("Scan a barcode")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Place the code inside the frame")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.78))
                    }
                    .frame(maxWidth: .infinity)
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

                if let errorMessage = scanner.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.45))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 24)
                }

                if let errorMessage = appState.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.925, green: 0.302, blue: 0.302).opacity(0.82))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 24)
                }

                HStack {
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
        .navigationDestination(isPresented: $goToResult) {
            ProductPageOneView()
        }
    }
        .alert("Barcode Scanned", isPresented: $showResult) {
            Button("OK") {
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

                    if appState.errorMessage == nil {
                        goToResult = true
                    }
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
