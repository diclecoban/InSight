//
//  ProductPageOneView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 16.03.2026.
//

import SwiftUI

struct ProductPageOneView: View {
    let score: Double = 0.7
    @State var userName: String = "Susan Clay"
    
    var safetyText: String {
        switch score {
        case 0.8...1.0: return "Safe!"
        case 0.5..<0.8: return "Mostly Safe!"
        default:        return "Avoid!"
        }
    }
    
    var safetyColor: Color {
        switch score {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        default:        return .red
        }
    }
    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.459, green: 0.643, blue: 0.533)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(greeting)
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text(userName)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                    }
                    Spacer()
                    Image(systemName: "bell.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60) // Avatar için boşluk
                ZStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white)
                    
                    VStack(spacing: 10) {
                        Text("Name of the Product")
                            .font(.title.bold())
                            .foregroundColor(.gray)
                        Text("$19.99")
                            .font(.title2.bold())
                            .foregroundColor(.black)
                            .padding(.bottom, 30)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 200, height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                        
                        SafetyBar(score: score)
                    }
                }
            }
        }
    }
}

struct SafetyBar: View {
    let score: Double // 0.0 ile 1.0 arası (0.7 = %70)
    
    var barColor: Color {
        switch score {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .orange
        default:        return .red
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Safety Score")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(score * 100))%")
                    .font(.subheadline.bold())
                    .foregroundColor(barColor)
            }
            .padding(.horizontal, 24)
            
            // Arka plan (gri bar)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    // Dolu kısım (renkli bar)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(barColor)
                        .frame(width: geometry.size.width * score, height: 12)
                }
            }
            .frame(height: 12)
            .padding(.horizontal, 24)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ProductPageOneView()
}
