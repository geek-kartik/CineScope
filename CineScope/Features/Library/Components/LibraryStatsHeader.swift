//
//  LibraryStatsHeader.swift
//  CineScope
//

import SwiftUI

public struct LibraryStatsHeader: View {
    public let stats: LibraryStats

    public init(stats: LibraryStats) {
        self.stats = stats
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            Text("Personal Cinema Log")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CineSpacing.m) {
                statCard(
                    icon: "film.stack.fill",
                    color: CineColors.crimson,
                    title: "Watched",
                    value: "\(stats.totalWatched) films"
                )

                statCard(
                    icon: "clock.fill",
                    color: CineColors.cyan,
                    title: "Screen Time",
                    value: stats.formattedWatchTime
                )

                statCard(
                    icon: "star.fill",
                    color: CineColors.gold,
                    title: "Avg Rating",
                    value: stats.averageRating != nil ? String(format: "%.1f ★", stats.averageRating!) : "No ratings"
                )

                statCard(
                    icon: "sparkles",
                    color: CineColors.violet,
                    title: "Top Genre",
                    value: stats.topGenres.first ?? "Varied"
                )
            }
        }
        .padding(.horizontal, CineSpacing.l)
    }

    private func statCard(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(spacing: CineSpacing.m) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(CineColors.textTertiary)
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(CineSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: CineRadius.m)
                .fill(CineColors.backgroundElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.m)
                        .stroke(CineColors.surfaceBorder, lineWidth: 1)
                )
        )
    }
}
