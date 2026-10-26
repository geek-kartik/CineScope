//
//  PersonalReviewSection.swift
//  CineScope
//

import SwiftUI

public struct PersonalReviewSection: View {
    @Binding public var rating: Double?
    @Binding public var reviewText: String
    public let onSave: (Double?, String) -> Void

    @State private var isSavedFeedback: Bool = false

    public init(
        rating: Binding<Double?>,
        reviewText: Binding<String>,
        onSave: @escaping (Double?, String) -> Void
    ) {
        self._rating = rating
        self._reviewText = reviewText
        self.onSave = onSave
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            Text("Personal Log & Review")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            VStack(alignment: .leading, spacing: CineSpacing.m) {
                // Star Rating
                HStack(spacing: CineSpacing.m) {
                    Text("Your Rating:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(CineColors.textSecondary)

                    HStack(spacing: 8) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                if rating == Double(star) {
                                    rating = nil
                                } else {
                                    rating = Double(star)
                                }
                            } label: {
                                Image(systemName: (rating ?? 0) >= Double(star) ? "star.fill" : "star")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle((rating ?? 0) >= Double(star) ? CineColors.gold : CineColors.textTertiary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let r = rating {
                        Text("\(Int(r))/5")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(CineColors.gold)
                    }
                }

                // Text Notes
                VStack(alignment: .trailing, spacing: CineSpacing.s) {
                    TextField("Write your private review or thoughts...", text: $reviewText, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.system(size: 14))
                        .foregroundStyle(CineColors.textPrimary)
                        .padding(CineSpacing.m)
                        .background(
                            RoundedRectangle(cornerRadius: CineRadius.m)
                                .fill(CineColors.backgroundSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: CineRadius.m)
                                        .stroke(CineColors.surfaceBorder, lineWidth: 1)
                                )
                        )

                    Button {
                        onSave(rating, reviewText)
                        isSavedFeedback = true
                        Task {
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            isSavedFeedback = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if isSavedFeedback {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Saved")
                                    .font(.system(size: 13, weight: .bold))
                            } else {
                                Text("Save Note")
                                    .font(.system(size: 13, weight: .bold))
                            }
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(isSavedFeedback ? CineColors.emerald : CineColors.crimson)
                        .clipShape(Capsule())
                    }
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
        .padding(.horizontal, CineSpacing.l)
    }
}
