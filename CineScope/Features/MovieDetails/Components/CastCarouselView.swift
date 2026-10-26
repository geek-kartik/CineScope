//
//  CastCarouselView.swift
//  CineScope
//

import SwiftUI

public struct CastCarouselView: View {
    public let cast: [CastMember]

    public init(cast: [CastMember]) {
        self.cast = cast
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            Text("Top Cast")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)
                .padding(.horizontal, CineSpacing.l)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: CineSpacing.m) {
                    ForEach(cast.prefix(15)) { member in
                        VStack(spacing: CineSpacing.xs) {
                            CachedAsyncImage(url: member.profileURL(size: "w185"))
                                .frame(width: 72, height: 72)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(CineColors.surfaceBorder, lineWidth: 1))
                                .shadow(color: CineShadow.subtle, radius: 4, x: 0, y: 2)

                            Text(member.name)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(CineColors.textPrimary)
                                .lineLimit(1)
                                .frame(width: 80)

                            if let char = member.character, !char.isEmpty {
                                Text(char)
                                    .font(.system(size: 10, weight: .regular))
                                    .foregroundStyle(CineColors.textTertiary)
                                    .lineLimit(1)
                                    .frame(width: 80)
                            }
                        }
                    }
                }
                .padding(.horizontal, CineSpacing.l)
            }
        }
    }
}
