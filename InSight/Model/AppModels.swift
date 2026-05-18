//
//  AppModels.swift
//  InSight
//
//  Created by Codex on 20.04.2026.
//

import Foundation
import SwiftUI

struct AuthSession: Equatable {
    let userID: UUID
    let email: String
    let authToken: String
    let refreshToken: String
}

struct UserProfile: Identifiable, Equatable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var age: Int
    var skinType: String
    var condition: String
    var sensitivity: String
    var allergies: [String]

    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

struct Product: Identifiable, Equatable {
    let id: UUID
    var name: String
    var brand: String
    var priceText: String
    var barcode: String
}

enum SafetyLevel: String, Equatable, CaseIterable {
    case safe
    case mostlySafe
    case risky

    var title: String {
        switch self {
        case .safe:
            return "Safe!"
        case .mostlySafe:
            return "Mostly Safe!"
        case .risky:
            return "Risky!"
        }
    }

    var color: Color {
        switch self {
        case .safe:
            return Color(red: 0.255, green: 0.694, blue: 0.427)
        case .mostlySafe:
            return Color(red: 0.953, green: 0.643, blue: 0.286)
        case .risky:
            return Color(red: 0.925, green: 0.302, blue: 0.302)
        }
    }
}

struct IngredientInsight: Identifiable, Equatable {
    let id: UUID
    var name: String
    var detail: String
    var riskNote: String
}

struct ScanResult: Identifiable, Equatable {
    let id: UUID
    var product: Product
    var score: Double
    var safetyLevel: SafetyLevel
    var summary: String
    var ingredients: [IngredientInsight]
    var scannedAt: Date
}

struct SavedReview: Identifiable, Equatable {
    let id: UUID
    var productName: String
    var status: SafetyLevel
    var savedAt: Date
}

struct RecommendationItem: Identifiable, Equatable {
    let id: UUID
    var title: String
    var subtitle: String
}

struct RegistrationDraft: Equatable {
    var email = ""
    var firstName = ""
    var lastName = ""
    var password = ""
    var birthDate = Date()
    var gender = ""
    var skinType = ""
    var allergies = ""
}

struct ProfileUpdateDraft: Equatable {
    var firstName = ""
    var lastName = ""
    var skinType = ""
    var condition = ""
    var sensitivity = ""
    var allergies = ""

    init() {}

    init(profile: UserProfile) {
        firstName = profile.firstName
        lastName = profile.lastName
        skinType = profile.skinType
        condition = profile.condition
        sensitivity = profile.sensitivity
        allergies = profile.allergies.joined(separator: ", ")
    }
}
