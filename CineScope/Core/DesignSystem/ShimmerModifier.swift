//
//  ShimmerModifier.swift
//  CineScope
//

import SwiftUI

public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0

    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let size = geo.size
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: size.width * 1.5, height: size.height)
                    .offset(x: phase * size.width * 1.5)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.6)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.0
                }
            }
    }
}

public extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
