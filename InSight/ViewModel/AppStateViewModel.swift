//
//  AppStateViewModel.swift
//  InSight
//
//  Created by Codex on 20.04.2026.
//

import Foundation
import Observation

@Observable
final class AppStateViewModel {
    var session: AuthSession?
    var userProfile: UserProfile?
    var savedReviews: [SavedReview]
    var recommendations: [RecommendationItem]
    var latestScanResult: ScanResult?

    init(
        session: AuthSession? = nil,
        userProfile: UserProfile? = AppStateViewModel.mockProfile,
        savedReviews: [SavedReview] = AppStateViewModel.mockSavedReviews,
        recommendations: [RecommendationItem] = AppStateViewModel.mockRecommendations,
        latestScanResult: ScanResult? = AppStateViewModel.mockScanResult
    ) {
        self.session = session
        self.userProfile = userProfile
        self.savedReviews = savedReviews
        self.recommendations = recommendations
        self.latestScanResult = latestScanResult
    }

    var isLoggedIn: Bool {
        session != nil
    }

    var displayName: String {
        userProfile?.fullName ?? "Guest User"
    }

    var firstName: String {
        userProfile?.firstName ?? "Guest"
    }

    func signIn(email: String, password: String) {
        let normalizedEmail = email.isEmpty ? Self.mockProfile.email : email
        session = AuthSession(
            userID: Self.mockProfile.id,
            email: normalizedEmail,
            authToken: "mock-auth-token",
            refreshToken: "mock-refresh-token"
        )
    }

    func completeVerification() {
        session = AuthSession(
            userID: Self.mockProfile.id,
            email: Self.mockProfile.email,
            authToken: "mock-auth-token",
            refreshToken: "mock-refresh-token"
        )
    }

    func signOut() {
        session = nil
    }
}

extension AppStateViewModel {
    static let mockProfile = UserProfile(
        id: UUID(),
        firstName: "Susan",
        lastName: "Clay",
        email: "susan@insight.app",
        age: 19,
        skinType: "Dry",
        condition: "Sensitive Skin",
        sensitivity: "High",
        allergies: ["Fragrance"]
    )

    static let mockRecommendations = [
        RecommendationItem(id: UUID(), title: "Ingredient of the Day", subtitle: "It is you"),
        RecommendationItem(id: UUID(), title: "Why Avoid Palm Oil?", subtitle: "Rosaville")
    ]

    static let mockSavedReviews = [
        SavedReview(id: UUID(), productName: "Hydrating Cleanser", status: .mostlySafe, savedAt: .now),
        SavedReview(id: UUID(), productName: "Vitamin C Serum", status: .safe, savedAt: .now),
        SavedReview(id: UUID(), productName: "Fragrance Mist", status: .risky, savedAt: .now)
    ]

    static let mockScanResult = ScanResult(
        id: UUID(),
        product: Product(
            id: UUID(),
            name: "CERAVE Cleanser",
            brand: "CeraVe",
            priceText: "$19.99",
            barcode: "8691234567890"
        ),
        score: 0.7,
        safetyLevel: .mostlySafe,
        summary: "The product is 70% safe.",
        ingredients: [
            IngredientInsight(
                id: UUID(),
                name: "Glycerin",
                detail: "A humectant that supports hydration.",
                riskNote: "Low risk for most skin types."
            ),
            IngredientInsight(
                id: UUID(),
                name: "Fragrance",
                detail: "Used to adjust the scent profile.",
                riskNote: "Can trigger irritation in sensitive skin."
            )
        ],
        scannedAt: .now
    )
}
