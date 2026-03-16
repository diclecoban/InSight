//
//  LogInView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.459, green: 0.643, blue: 0.533)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                Text("Log In")
                    .font(.title.bold())
                    .foregroundColor(.black)
                
                // Email alanı
                TextField("Email", text: $email)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 24)
                
                // Şifre alanı
                SecureField("Password", text: $password)
                    .padding(16)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
                
                // Şifremi unuttum
                HStack {
                    Spacer()
                    Button("Forgot Your Password?") { }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.trailing, 24)
                }
                
                // Login butonu
                Button {
                    isLoggedIn = true
                } label: {
                    Text("Login")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 1, green: 0.176, blue: 0.333))
                        .cornerRadius(30)
                        .padding(.horizontal, 24)
                }
                
                // Or ayırıcı
                HStack {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.black.opacity(0.3))
                    Text("Or")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.6))
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.black.opacity(0.3))
                }
                .padding(.horizontal, 24)
                
                // Sosyal giriş ikonları
                HStack(spacing: 16) {
                    ForEach(["envelope", "link", "f.circle"], id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // Kayıt ol
                HStack(spacing: 4) {
                    Text("Don't Have Account?")
                        .foregroundColor(.black.opacity(0.7))
                    Button("Sign Up") { }
                        .foregroundColor(.yellow)
                        .bold()
                }
                .font(.subheadline)
                .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
