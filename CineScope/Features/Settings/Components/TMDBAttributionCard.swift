//
//  TMDBAttributionCard.swift
//  CineScope
//

import SwiftUI

public struct TMDBAttributionCard: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            HStack(spacing: CineSpacing.s) {
                // TMDB pill badge
                Text("TMDB")
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 144/255, green: 206/255, blue: 161/255), Color(red: 1/255, green: 180/255, blue: 228/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Text("Data & Attribution")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)
            }

            Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                .font(.system(size: 13))
                .foregroundStyle(CineColors.textSecondary)
                .lineSpacing(2)

            Link(destination: URL(string: "https://www.themoviedb.org")!) {
                HStack(spacing: 4) {
                    Text("Visit themoviedb.org")
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(CineColors.cyan)
            }
        }
        .padding(CineSpacing.l)
        .background(
            RoundedRectangle(cornerRadius: CineRadius.l)
                .fill(CineColors.backgroundElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.l)
                        .stroke(CineColors.surfaceBorder, lineWidth: 1)
                )
        )
    }
}
