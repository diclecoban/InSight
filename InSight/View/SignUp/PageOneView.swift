//
//  PageOneView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct PageOneView: View {
    @Binding var isLoggedIn: Bool
    @State var email: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var password = ""
    @State var confirmPassword: String = ""
    
    var body: some View {
        ZStack(alignment: .center) {
            Color(#colorLiteral(red: 0.4588235294, green: 0.6431372549, blue: 0.5333333333, alpha: 1))
                .ignoresSafeArea()
            VStack() {
                Text("Sign Up")
                    .font(Font.largeTitle.bold())
                    .foregroundColor(.black)
                TextField("Email", text: $email)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(10)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(.horizontal, 24)
                HStack(alignment: .center) {
                    TextField("First Name", text: $firstName)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .padding(.leading, 24)
                    TextField("Last Name", text: $lastName)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .padding(.trailing, 24)
                }
                SecureField("Password", text: $password)
                    .padding(16)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding(16)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(10)
                    .padding(.horizontal, 24)
                
                NavigationLink {
                    PageTwoView(isLoggedIn: $isLoggedIn)
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
    PageOneView(isLoggedIn: .constant(false))
}
