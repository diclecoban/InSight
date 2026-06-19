//
//  AppModels.swift
//  InSight
//
//  Created by Codex on 20.04.2026.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable, Equatable {
    case clinicalWarm
    case premiumSkincare
    case healthTech
    case clinicalNoir
    case premiumNight
    case healthTechDark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clinicalWarm:
            return "Clinical Warm"
        case .premiumSkincare:
            return "Premium Skincare"
        case .healthTech:
            return "Health-Tech"
        case .clinicalNoir:
            return "Clinical Noir"
        case .premiumNight:
            return "Premium Night"
        case .healthTechDark:
            return "Tech Dark"
        }
    }

    var subtitle: String {
        switch self {
        case .clinicalWarm:
            return "Soft green, warm white, calm amber"
        case .premiumSkincare:
            return "Forest green, ivory, champagne gold"
        case .healthTech:
            return "Deep teal, cool mint, clean gray"
        case .clinicalNoir:
            return "Deep sage, charcoal, warm coral"
        case .premiumNight:
            return "Midnight olive, bronze, soft ivory"
        case .healthTechDark:
            return "Ink teal, electric mint, dark glass"
        }
    }

    var isDark: Bool {
        switch self {
        case .clinicalNoir, .premiumNight, .healthTechDark:
            return true
        default:
            return false
        }
    }

    var brand: Color {
        switch self {
        case .clinicalWarm:
            return Color(red: 0.459, green: 0.643, blue: 0.533)
        case .premiumSkincare:
            return Color(red: 0.176, green: 0.286, blue: 0.212)
        case .healthTech:
            return Color(red: 0.078, green: 0.392, blue: 0.420)
        case .clinicalNoir:
            return Color(red: 0.102, green: 0.188, blue: 0.157)
        case .premiumNight:
            return Color(red: 0.067, green: 0.106, blue: 0.082)
        case .healthTechDark:
            return Color(red: 0.027, green: 0.157, blue: 0.184)
        }
    }

    var deep: Color {
        switch self {
        case .clinicalWarm:
            return Color(red: 0.208, green: 0.431, blue: 0.329)
        case .premiumSkincare:
            return Color(red: 0.102, green: 0.188, blue: 0.137)
        case .healthTech:
            return Color(red: 0.035, green: 0.243, blue: 0.282)
        case .clinicalNoir:
            return Color(red: 0.063, green: 0.125, blue: 0.106)
        case .premiumNight:
            return Color(red: 0.035, green: 0.063, blue: 0.047)
        case .healthTechDark:
            return Color(red: 0.016, green: 0.102, blue: 0.122)
        }
    }

    var soft: Color {
        switch self {
        case .clinicalWarm:
            return Color(red: 0.898, green: 0.941, blue: 0.918)
        case .premiumSkincare:
            return Color(red: 0.949, green: 0.918, blue: 0.839)
        case .healthTech:
            return Color(red: 0.875, green: 0.957, blue: 0.949)
        case .clinicalNoir:
            return Color(red: 0.157, green: 0.251, blue: 0.220)
        case .premiumNight:
            return Color(red: 0.180, green: 0.157, blue: 0.110)
        case .healthTechDark:
            return Color(red: 0.102, green: 0.251, blue: 0.282)
        }
    }

    var accent: Color {
        switch self {
        case .clinicalWarm:
            return Color(red: 0.957, green: 0.443, blue: 0.365)
        case .premiumSkincare:
            return Color(red: 0.745, green: 0.612, blue: 0.365)
        case .healthTech:
            return Color(red: 0.216, green: 0.741, blue: 0.745)
        case .clinicalNoir:
            return Color(red: 0.933, green: 0.506, blue: 0.420)
        case .premiumNight:
            return Color(red: 0.741, green: 0.604, blue: 0.365)
        case .healthTechDark:
            return Color(red: 0.302, green: 0.875, blue: 0.804)
        }
    }

    var gold: Color {
        switch self {
        case .clinicalWarm:
            return Color(red: 0.953, green: 0.643, blue: 0.286)
        case .premiumSkincare:
            return Color(red: 0.804, green: 0.686, blue: 0.443)
        case .healthTech:
            return Color(red: 0.341, green: 0.784, blue: 0.710)
        case .clinicalNoir:
            return Color(red: 0.914, green: 0.659, blue: 0.365)
        case .premiumNight:
            return Color(red: 0.820, green: 0.690, blue: 0.443)
        case .healthTechDark:
            return Color(red: 0.416, green: 0.902, blue: 0.808)
        }
    }

    var panel: Color {
        switch self {
        case .clinicalWarm:
            return Color(red: 0.972, green: 0.978, blue: 0.975)
        case .premiumSkincare:
            return Color(red: 0.988, green: 0.969, blue: 0.925)
        case .healthTech:
            return Color(red: 0.945, green: 0.965, blue: 0.969)
        case .clinicalNoir:
            return Color(red: 0.125, green: 0.173, blue: 0.157)
        case .premiumNight:
            return Color(red: 0.133, green: 0.118, blue: 0.086)
        case .healthTechDark:
            return Color(red: 0.078, green: 0.149, blue: 0.169)
        }
    }

    var surface: Color {
        switch self {
        case .clinicalWarm, .premiumSkincare, .healthTech:
            return Color.white
        case .clinicalNoir:
            return Color(red: 0.071, green: 0.102, blue: 0.094)
        case .premiumNight:
            return Color(red: 0.055, green: 0.047, blue: 0.035)
        case .healthTechDark:
            return Color(red: 0.035, green: 0.086, blue: 0.102)
        }
    }

    var card: Color {
        switch self {
        case .clinicalWarm, .premiumSkincare, .healthTech:
            return Color.white
        case .clinicalNoir:
            return Color(red: 0.102, green: 0.141, blue: 0.129)
        case .premiumNight:
            return Color(red: 0.102, green: 0.090, blue: 0.067)
        case .healthTechDark:
            return Color(red: 0.063, green: 0.129, blue: 0.149)
        }
    }

    var textPrimary: Color {
        isDark ? Color(red: 0.955, green: 0.965, blue: 0.950) : Color.black
    }

    var textSecondary: Color {
        isDark ? Color.white.opacity(0.64) : Color.black.opacity(0.58)
    }
}

struct AuthSession: Codable, Equatable {
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
    var gender: String
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
    var imageURL: URL?
    var barcode: String
}

enum SafetyLevel: String, Equatable, CaseIterable {
    case safe
    case mostlySafe
    case risky

    var title: String {
        switch self {
        case .safe:
            return String(localized: "Safe!")
        case .mostlySafe:
            return String(localized: "Mostly Safe!")
        case .risky:
            return String(localized: "Risky!")
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
    var riskLevel: String
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
    var productID: UUID
    var productName: String
    var brand: String
    var imageURL: URL?
    var barcode: String
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
    var age = 18
    var gender = ""
    var skinType = ""
    var allergies = ""

    var fullName: String? {
        let name = [firstName, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return name.isEmpty ? nil : name
    }

    var firstNameIfAvailable: String? {
        let name = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? nil : name
    }
}

struct ProfileUpdateDraft: Equatable {
    var firstName = ""
    var lastName = ""
    var email = ""
    var age = 18
    var gender = ""
    var skinType = ""
    var condition = ""
    var sensitivity = ""
    var allergies = ""

    init() {}

    init(profile: UserProfile) {
        firstName = profile.firstName
        lastName = profile.lastName
        email = profile.email
        age = profile.age
        gender = profile.gender
        skinType = profile.skinType
        condition = profile.condition
        sensitivity = profile.sensitivity
        allergies = profile.allergies.joined(separator: ", ")
    }
}
