//
//  CineButton.swift
//  CineScope
//

import SwiftUI

public struct PrimaryCineButton: View {
    public let title: String
    public let icon: String?
    public let action: () -> Void

    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: CineSpacing.s) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .bold))
                }
                Text(title)
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(CineColors.crimsonGradient)
            .clipShape(RoundedRectangle(cornerRadius: CineRadius.m))
            .shadow(color: CineColors.crimson.opacity(0.35), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

public struct SecondaryCineButton: View {
    public let title: String
    public let icon: String?
    public let action: () -> Void

    public init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: CineSpacing.s) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(CineColors.textPrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(CineColors.backgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: CineRadius.m))
            .overlay(
                RoundedRectangle(cornerRadius: CineRadius.m)
                    .stroke(CineColors.surfaceBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

public struct RoundActionButton: View {
    public let icon: String
    public let isFilled: Bool
    public var filledColor: Color = CineColors.crimson
    public var size: CGFloat = 44
    public let action: () -> Void

    public init(
        icon: String,
        isFilled: Bool = false,
        filledColor: Color = CineColors.crimson,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.isFilled = isFilled
        self.filledColor = filledColor
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isFilled ? filledColor.opacity(0.2) : CineColors.backgroundElevated.opacity(0.85))
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .stroke(isFilled ? filledColor : CineColors.surfaceBorder, lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: size * 0.42, weight: .bold))
                    .foregroundStyle(isFilled ? filledColor : CineColors.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}
