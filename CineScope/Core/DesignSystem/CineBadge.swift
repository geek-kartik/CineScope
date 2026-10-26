//
//  CineBadge.swift
//  CineScope
//

import SwiftUI

public struct RatingBadge: View {
    public let rating: Double
    public var showStar: Bool = true
    public var compact: Bool = false

    public init(rating: Double, showStar: Bool = true, compact: Bool = false) {
        self.rating = rating
        self.showStar = showStar
        self.compact = compact
    }

    public var body: some View {
        HStack(spacing: compact ? 2 : 4) {
            if showStar {
                Image(systemName: "star.fill")
                    .font(.system(size: compact ? 10 : 12, weight: .bold))
                    .foregroundStyle(CineColors.gold)
            }
            Text(rating > 0 ? String(format: "%.1f", rating) : "NR")
                .font(.system(size: compact ? 11 : 13, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)
        }
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 2 : 4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.65))
                .overlay(
                    Capsule()
                        .stroke(CineColors.gold.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}

public struct GenrePill: View {
    public let text: String
    public var isSelected: Bool = false
    public var action: (() -> Void)? = nil

    public init(text: String, isSelected: Bool = false, action: (() -> Void)? = nil) {
        self.text = text
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
    }

    private var content: some View {
        Text(text)
            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
            .foregroundStyle(isSelected ? Color.white : CineColors.textSecondary)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? CineColors.crimson : CineColors.backgroundElevated)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : CineColors.surfaceBorder, lineWidth: 1)
            )
    }
}

public struct RankBadge: View {
    public let rank: Int

    public init(rank: Int) {
        self.rank = rank
    }

    public var body: some View {
        Text("#\(rank)")
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(rank <= 3 ? CineColors.crimson : CineColors.backgroundElevated)
            )
    }
}
