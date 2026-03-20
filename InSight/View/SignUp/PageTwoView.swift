//
//  PageTwoView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct PageTwoView: View {
    @Binding var isLoggedIn: Bool
    @State private var skinType: String = ""
    @State private var Allergie: String = ""
    
    var body: some View {
        ZStack(alignment: .center) {
            Color(#colorLiteral(red: 0.4588235294, green: 0.6431372549, blue: 0.5333333333, alpha: 1))
                .ignoresSafeArea()
            VStack() {
                Text("Sign Up")
                    .font(Font.largeTitle.bold())
                    .foregroundColor(.black)
                TextField("Skin Type", text: $skinType)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 24)
                TextField("Allergies", text: $Allergie)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 24)
                NavigationLink {
                    VerificationView(isLoggedIn: $isLoggedIn)
                } label: {
                    Text("Next")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color(red: 1, green: 0.176, blue: 0.333))
                        .cornerRadius(30)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                }
            }
        }
    }
}

#Preview {
    PageTwoView(isLoggedIn: .constant(false))
}
