//
//  GlassCard.swift
//  CineScope
//

import SwiftUI

public struct GlassCard<Content: View>: View {
    private let content: () -> Content
    private let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = CineRadius.l, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content
    }

    public var body: some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(CineColors.surfaceGlass)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.12),
                                        Color.white.opacity(0.03)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

public struct SectionHeaderView: View {
    public let title: String
    public var subtitle: String? = nil
    public var seeAllAction: (() -> Void)? = nil

    public init(title: String, subtitle: String? = nil, seeAllAction: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.seeAllAction = seeAllAction
    }

    public var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: CineSpacing.xxs) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(CineColors.textSecondary)
                }
            }

            Spacer()

            if let seeAllAction = seeAllAction {
                Button(action: seeAllAction) {
                    HStack(spacing: 3) {
                        Text("See All")
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundStyle(CineColors.crimson)
                }
            }
        }
        .padding(.horizontal, CineSpacing.l)
    }
}
