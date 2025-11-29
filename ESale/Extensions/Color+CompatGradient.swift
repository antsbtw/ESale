//
//  Color+CompatGradient.swift
//  ESale
//
//  Provides a fallback gradient for iOS versions before the Color.gradient API.
//

import SwiftUI

extension Color {
    /// Gradient replacement that works on iOS 15 and earlier.
    var compatGradient: LinearGradient {
        LinearGradient(
            colors: [self.opacity(0.9), self],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
