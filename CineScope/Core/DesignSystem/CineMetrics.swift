//
//  CineMetrics.swift
//  CineScope
//

import SwiftUI

public enum CineSpacing {
    public static let xxs: CGFloat = 2
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 12
    public static let l: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
    public static let xxxl: CGFloat = 48
}

public enum CineRadius {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 12
    public static let l: CGFloat = 16
    public static let xl: CGFloat = 24
    public static let full: CGFloat = 999
}

public enum CineShadow {
    public static let subtle = Color.black.opacity(0.2)
    public static let medium = Color.black.opacity(0.4)
    public static let deep = Color.black.opacity(0.7)
}
