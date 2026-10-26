//
//  MovieMetaGridView.swift
//  CineScope
//

import SwiftUI

public struct MovieMetaGridView: View {
    public let detail: MovieDetail

    public init(detail: MovieDetail) {
        self.detail = detail
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            Text("Movie Facts")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CineSpacing.m) {
                if let director = detail.director?.name {
                    factCard(title: "Director", value: director)
                }
                if let status = detail.status {
                    factCard(title: "Status", value: status)
                }
                if let lang = detail.originalLanguage?.uppercased() {
                    factCard(title: "Original Language", value: lang)
                }
                if detail.formattedBudget != "N/A" {
                    factCard(title: "Budget", value: detail.formattedBudget)
                }
                if detail.formattedRevenue != "N/A" {
                    factCard(title: "Box Office", value: detail.formattedRevenue)
                }
                if let companies = detail.productionCompanies, !companies.isEmpty {
                    factCard(title: "Studio", value: companies.prefix(2).map(\.name).joined(separator: ", "))
                }
            }
        }
        .padding(.horizontal, CineSpacing.l)
    }

    private func factCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(CineColors.textTertiary)
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CineColors.textPrimary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CineSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: CineRadius.m)
                .fill(CineColors.backgroundElevated)
                .overlay(RoundedRectangle(cornerRadius: CineRadius.m).stroke(CineColors.surfaceBorder, lineWidth: 1))
        )
    }
}
