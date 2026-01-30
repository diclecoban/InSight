//
//  LogInView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 30.01.2026.
//

import SwiftUI

struct LogInView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(#colorLiteral(red: 0.4588235294, green: 0.6431372549, blue: 0.5333333333, alpha: 1))
                    .ignoresSafeArea()
                VStack() {
                    Text("Log In")
                        .font(.largeTitle)
                        .bold(true)
                        
                    TextField("Email", text: $email)
                        .padding(.vertical)
                        .padding(.horizontal, 24)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    SecureField("Password", text: $password)
                        .padding(.vertical)
                        .padding(.horizontal, 24)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    
                    NavigationLink() {
                        
                    } label: {
                        Text("Forgot Your Password")
                            .font(.caption)
                            .foregroundColor(Color(#colorLiteral(red: 0.09412650019, green: 0.1988208294, blue: 1, alpha: 1)))
                            .underline()
                    }
                    
                    NavigationLink() {
                        HomeView()
                    } label: {
                        Text("Login")
                            .font(Font.title3.bold())
                            .foregroundColor(.white)
                            .padding(20)
                            .padding(.horizontal, 120)
                            .background(Color(#colorLiteral(red: 1, green: 0.1764705882, blue: 0.3333333333, alpha: 1)))
                            .cornerRadius(10)
                            .padding(10)
                    }
                }
            }
        }
    }
}

#Preview {
    LogInView()
}
