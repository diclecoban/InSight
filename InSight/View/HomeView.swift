//
//  HomeView.swift
//  InSight
//
//  Created by Dicle Sara Çoban on 15.03.2026.
//

import SwiftUI

struct HomeView: View {
    @State var userName: String = "Susan Clay"
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
                .padding(.top, 60)
                .padding(.bottom, 60) // Avatar için boşluk
                
                // BEYAZ KART — ana içerik
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color.white)
                    
                    VStack(spacing: 20) {
                        // Avatar — karta taşan kısım
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)
                            .offset(y: -45) // Yeşil alana taşıyor
                            .padding(.bottom, -45)
                        
                        // Rozet ikonu
                        Image(systemName: "medal.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        // Başlık
                        Group {
                            Text("Welcome to your\ncomfort ")
                                .font(.title.bold())
                                .foregroundColor(.black)
                             Text("place")
                                .font(.title.bold())
                                .foregroundColor(Color(red: 0.459, green: 0.643, blue: 0.533))
                        }
                        .multilineTextAlignment(.center)
                        
                        // KATEGORİ KARTLARI
                        HStack(spacing: 12) {
                            CategoryCard(icon: "bag.fill", title: "Skin Care")
                            CategoryCard(icon: "heart.fill", title: "Food")
                        }
                        .padding(.horizontal, 24)
                        
                        // ÖNERİLER
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recommended for You")
                                .font(.headline)
                                .padding(.horizontal, 24)
                            
                            RecommendationCard(
                                title: "Ingredient of the Day",
                                subtitle: "It is you"
                            )
                            RecommendationCard(
                                title: "Why Avoid Palm Oil?",
                                subtitle: "Rosaville"
                            )
                        }
                        
                        Spacer(minLength: 80) // Tab bar için boşluk
                    }
                    .padding(.top, 20)
                }
                .padding(.top, 45) // Avatar overlap için
            }
        }
    }
}

// YARDIMCI COMPONENT: Kategori kartı
struct CategoryCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 110)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

// YARDIMCI COMPONENT: Öneri kartı
struct RecommendationCard: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 24)
    }
}

var greeting: String {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 6..<12:  return "Good Morning"
    case 12..<18: return "Good Afternoon"
    default:      return "Good Evening"
    }
}

#Preview {
    HomeView()
}
