//
//  ContentView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 26.01.2026.
//

import SwiftUI

struct ContentView: View {
    
    @State private var goNext = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(#colorLiteral(red: 0.4588235294, green: 0.6431372549, blue: 0.5333333333, alpha: 1))
                    .ignoresSafeArea()
                VStack(spacing: 15) {
                    RoundedRectangle(cornerRadius: 45)
                        .fill(Color.white)
                        .ignoresSafeArea()
                        .padding(.bottom, 20)
                    
                    NavigationLink {
                        LogInView()
                    } label: {
                        Text("Let's Start")
                        .font(Font.title.bold())
                        .foregroundColor(.white)
                        .padding(20)
                        .padding(.horizontal, 70)
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
    ContentView()
}
