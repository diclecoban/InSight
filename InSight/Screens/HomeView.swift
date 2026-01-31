//
//  HomeView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 30.01.2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack() {
            Color(#colorLiteral(red: 0.4588235294, green: 0.6431372549, blue: 0.5333333333, alpha: 1))
                .ignoresSafeArea()
            ZStack() {
                RoundedRectangle(cornerRadius: 45)
                    .fill(Color.white)
                    .ignoresSafeArea()
                    .padding(.top, 100)
                
                VStack() {
                    RoundedRectangle(cornerRadius: 17)
                        .fill(Color(#colorLiteral(red: 0.7725490196, green: 0.137254902, blue: 0.2588235294, alpha: 1)))
                        .frame(width: 100, height: 100)
                        
                    
                    Text("Welcome to Your Comfort Place")
                        .font(Font.largeTitle.bold())
                        
                    HStack(spacing: 10) {
                        ZStack() {
                            RoundedRectangle(cornerRadius: 17)
                                .fill(Color(#colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1)))
                                .frame(width: 120, height: 120)
                            
                            Text("Skin Care")
                        }
                        
                        ZStack() {
                            RoundedRectangle(cornerRadius: 17)
                                .fill(Color(#colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1)))
                                .frame(width: 120, height: 120)
                            
                            Text("Food")
                        }
                    }
                    
                    
                    
                    VStack(spacing: 10) {
                        
                        Text("Recommended for You")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ZStack() {
                            RoundedRectangle(cornerRadius: 17)
                                .fill(Color(#colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1)))
                                
                            
                            Text("Ingredient of the Day")
                        }
                        
                        ZStack() {
                            RoundedRectangle(cornerRadius: 17)
                                .fill(Color(#colorLiteral(red: 0.6980392157, green: 0.6980392157, blue: 0.6980392157, alpha: 1)))
                                
                            
                            Text("Why Avoid Palm Oil?")
                        }
                    }
                    .padding(.vertical, 100)
                    .padding(.horizontal, 30)
                    
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
