//
//  SearchBarView.swift
//  CineScope
//

import SwiftUI

public struct SearchBarView: View {
    @Binding public var text: String
    public var placeholder: String = "Search movies, genres, titles..."
    public var onClear: (() -> Void)? = nil

    public init(text: Binding<String>, placeholder: String = "Search movies, genres, titles...", onClear: (() -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onClear = onClear
    }

    public var body: some View {
        HStack(spacing: CineSpacing.m) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(text.isEmpty ? CineColors.textTertiary : CineColors.crimson)

            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundStyle(CineColors.textPrimary)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                    onClear?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(CineColors.textTertiary)
                }
            }
        }
        .padding(.horizontal, CineSpacing.m)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: CineRadius.l)
                .fill(CineColors.backgroundElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.l)
                        .stroke(text.isEmpty ? CineColors.surfaceBorder : CineColors.crimson.opacity(0.5), lineWidth: 1)
                )
        )
    }
}
