import SwiftUI

struct VerificationView: View {
    @Binding var isLoggedIn: Bool
    @State private var otpFields = ["", "", "", "", "", ""]
    @FocusState private var focusedField: Int?
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.4588235294, green: 0.6431372549, blue: 0.5333333333, alpha: 1))
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Text("Verification")
                    .font(.title.bold())
                    .foregroundColor(.black)
                
                Text("We Send You Email Please Check Your Email\nAnd Complete Otp Code")
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // OTP kutucukları
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        // Orta çizgi (3. ve 4. kutu arasında)
                        if index == 3 {
                            Rectangle()
                                .frame(width: 20, height: 2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        TextField("0", text: $otpFields[index])
                            .frame(width: 48, height: 56)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .multilineTextAlignment(.center)
                            .font(.title2.bold())
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: index)
                            .onChange(of: otpFields[index]) { oldValue, newValue in
                                // Sadece 1 karakter al
                                if newValue.count > 1 {
                                    otpFields[index] = String(newValue.last!)
                                }
                                // Sayı girilince bir sonraki kutuya geç
                                if newValue.count == 1 {
                                    if index < 5 {
                                        focusedField = index + 1
                                    } else {
                                        focusedField = nil // son kutu, klavyeyi kapat
                                    }
                                }
                                // Silinince bir önceki kutuya geç
                                if newValue.isEmpty && index > 0 {
                                    focusedField = index - 1
                                }
                            }
                    }
                }
                
                // Confirm butonu
                Button {
                    isLoggedIn = true
                } label: {
                    Text("Confirm")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 1, green: 0.176, blue: 0.333))
                        .cornerRadius(30)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Alt yazı
                HStack(spacing: 4) {
                    Text("Already Have Account?")
                        .foregroundColor(.black.opacity(0.7))
                    NavigationLink {
                        LoginView(isLoggedIn: $isLoggedIn)
                    } label: {
                        Text("Sign In")
                            .foregroundColor(.yellow)
                            .bold()
                    }
                }
                .font(.subheadline)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            focusedField = 0 // sayfa açılınca ilk kutuya odaklan
        }
    }
}

#Preview {
    VerificationView(isLoggedIn: .constant(false))
}
