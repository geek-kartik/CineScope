//
//  HomeSkeletonView.swift
//  CineScope
//

import SwiftUI

public struct HomeSkeletonView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.xl) {
            // Hero skeleton
            Rectangle()
                .fill(CineColors.backgroundElevated)
                .frame(maxWidth: .infinity)
                .frame(height: 380)
                .shimmering()

            // Row 1
            VStack(alignment: .leading, spacing: CineSpacing.m) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(CineColors.backgroundElevated)
                    .frame(width: 140, height: 22)
                    .padding(.horizontal, CineSpacing.l)
                    .shimmering()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CineSpacing.m) {
                        ForEach(0..<4, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: CineSpacing.xs) {
                                RoundedRectangle(cornerRadius: CineRadius.m)
                                    .fill(CineColors.backgroundElevated)
                                    .frame(width: 140, height: 210)
                                    .shimmering()

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(CineColors.backgroundElevated)
                                    .frame(width: 110, height: 14)
                                    .shimmering()
                            }
                        }
                    }
                    .padding(.horizontal, CineSpacing.l)
                }
            }

            // Row 2
            VStack(alignment: .leading, spacing: CineSpacing.m) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(CineColors.backgroundElevated)
                    .frame(width: 160, height: 22)
                    .padding(.horizontal, CineSpacing.l)
                    .shimmering()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: CineSpacing.m) {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: CineRadius.m)
                                .fill(CineColors.backgroundElevated)
                                .frame(width: 140, height: 210)
                                .shimmering()
                        }
                    }
                    .padding(.horizontal, CineSpacing.l)
                }
            }
        }
    }
}
