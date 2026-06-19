import SwiftUI
import AVFoundation

struct ScanView: View {
    @Environment(AppStateViewModel.self) private var appState
    @State private var scanner = BarcodeScanner()
    @State private var scannedCode: String = ""
    @State private var manualBarcode: String = ""
    @State private var goToResult = false
    @State private var isAnalyzingScan = false
    @FocusState private var isManualBarcodeFocused: Bool

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
                    VStack(spacing: 10) {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)

                        Button {
                            resetScanForRetry()
                        } label: {
                            Text("Try Again")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.92))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.925, green: 0.302, blue: 0.302).opacity(0.86))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal, 24)
                } else if isAnalyzingScan {
                    Text("Analyzing \(scannedCode)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.48))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.horizontal, 24)
                }

                manualBarcodeEntry
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)

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
        .contentShape(Rectangle())
        .onTapGesture {
            isManualBarcodeFocused = false
        }
        .compositingGroup()
        .onAppear {
            scannedCode = ""
            manualBarcode = ""
            goToResult = false
            isAnalyzingScan = false
            isManualBarcodeFocused = false
            scanner.resetScan()
            appState.prepareForNewScan()
            scanner.startSession()
        }
        .onDisappear { scanner.stopSession() }
        .navigationDestination(isPresented: $goToResult) {
            ProductPageOneView()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isManualBarcodeFocused = false
                }
            }
        }
    }
        .onChange(of: scanner.scannedCode) { _, newValue in
            if let code = newValue, !isAnalyzingScan {
                submitBarcode(code)
            }
        }
    }

    private var manualBarcodeEntry: some View {
        HStack(spacing: 10) {
            TextField(
                "",
                text: $manualBarcode,
                prompt: Text("Enter barcode manually").foregroundStyle(Color.black.opacity(0.58))
            )
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isManualBarcodeFocused)
            .submitLabel(.go)
            .onSubmit {
                submitBarcode(manualBarcode)
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.black)
            .tint(.black)
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(Color.white.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Button {
                submitBarcode(manualBarcode)
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Color(red: 0.953, green: 0.643, blue: 0.286))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .disabled(manualBarcode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnalyzingScan)
            .opacity(manualBarcode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
        }
    }

    private func submitBarcode(_ rawCode: String) {
        let code = rawCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty, !isAnalyzingScan else { return }

        scannedCode = code
        manualBarcode = code
        isAnalyzingScan = true
        isManualBarcodeFocused = false
        scanner.stopSession()
        appState.prepareForNewScan()

        Task {
            await appState.analyzeBarcode(code)

            if
                appState.errorMessage == nil,
                appState.latestScanResult?.product.barcode == code
            {
                goToResult = true
            } else {
                isAnalyzingScan = false
                scanner.resetScan()
            }
        }
    }

    private func resetScanForRetry() {
        scannedCode = ""
        manualBarcode = ""
        goToResult = false
        isAnalyzingScan = false
        isManualBarcodeFocused = false
        scanner.resetScan()
        appState.prepareForNewScan()
        scanner.startSession()
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
