import SwiftUI

struct VerificationView: View {
    @Environment(AppStateViewModel.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var otpFields = ["", "", "", "", "", ""]
    @FocusState private var focusedField: Int?

    private var theme: AppTheme { appState.selectedTheme }
    private var backgroundColor: Color { theme.brand }
    private var accentColor: Color { theme.accent }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Verification")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .softAppear()

                Text("We sent you an email. Please check your inbox and complete the OTP code.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .softAppear(delay: 0.06)

                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        if index == 3 {
                            Rectangle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 18, height: 2)
                        }

                        TextField("", text: $otpFields[index], prompt: Text("0").foregroundStyle(Color.black.opacity(0.55)))
                            .frame(width: 38, height: 46)
                            .background(Color.white.opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .multilineTextAlignment(.center)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.black)
                            .tint(.black)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: index)
                            .onChange(of: otpFields[index]) { _, newValue in
                                if newValue.count > 1 {
                                    otpFields[index] = String(newValue.last!)
                                }

                                if newValue.count == 1 {
                                    focusedField = index < 5 ? index + 1 : nil
                                }

                                if newValue.isEmpty && index > 0 {
                                    focusedField = index - 1
                                }
                            }
                    }
                }
                .softAppear(delay: 0.12)

                Button {
                    let code = otpFields.joined()
                    Task {
                        await appState.completeVerification(code: code)
                    }
                } label: {
                    Text("Confirm")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .padding(.horizontal, 24)
                .disabled(appState.isLoading)
                .buttonStyle(PressableButtonStyle())
                .softAppear(delay: 0.18)

                if let errorMessage = appState.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                }

                Spacer()

                if appState.isLoading {
                    ProgressView()
                        .tint(.white)
                }

                HStack(spacing: 4) {
                    Text("Already Have Account?")
                        .foregroundStyle(Color.black.opacity(0.7))

                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Sign In")
                            .foregroundStyle(Color(red: 0.988, green: 0.922, blue: 0.353))
                            .fontWeight(.bold)
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.94))
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.bottom, 28)
            }

            VStack {
                HStack {
                    OnboardingBackButton(action: {
                        dismiss()
                    }, tint: theme.deep)

                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)

                Spacer()
            }
            .softAppear()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            focusedField = 0
        }
    }
}

#Preview {
    VerificationView()
        .environment(AppStateViewModel())
}
