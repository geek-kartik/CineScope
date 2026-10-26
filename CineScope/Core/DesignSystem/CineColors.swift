//
//  CineColors.swift
//  CineScope
//

import SwiftUI

public enum CineColors {
    // Backgrounds
    public static let backgroundPrimary = Color(red: 11/255, green: 12/255, blue: 16/255)
    public static let backgroundSecondary = Color(red: 19/255, green: 21/255, blue: 29/255)
    public static let backgroundElevated = Color(red: 28/255, green: 31/255, blue: 43/255)
    public static let surfaceBorder = Color(red: 40/255, green: 44/255, blue: 61/255)
    public static let surfaceGlass = Color(red: 22/255, green: 25/255, blue: 35/255).opacity(0.85)

    // Accents
    public static let crimson = Color(red: 229/255, green: 9/255, blue: 20/255)
    public static let crimsonLight = Color(red: 255/255, green: 65/255, blue: 75/255)
    public static let gold = Color(red: 255/255, green: 184/255, blue: 0/255)
    public static let violet = Color(red: 139/255, green: 92/255, blue: 246/255)
    public static let cyan = Color(red: 6/255, green: 182/255, blue: 212/255)
    public static let emerald = Color(red: 16/255, green: 185/255, blue: 129/255)

    // Text & Content
    public static let textPrimary = Color(red: 248/255, green: 249/255, blue: 250/255)
    public static let textSecondary = Color(red: 148/255, green: 163/255, blue: 184/255)
    public static let textTertiary = Color(red: 100/255, green: 116/255, blue: 139/255)

    // Gradients
    public static let heroGradient = LinearGradient(
        colors: [
            Color.clear,
            backgroundPrimary.opacity(0.3),
            backgroundPrimary.opacity(0.85),
            backgroundPrimary
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    public static let crimsonGradient = LinearGradient(
        colors: [crimsonLight, crimson],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let goldGradient = LinearGradient(
        colors: [Color(red: 255/255, green: 215/255, blue: 0/255), gold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
