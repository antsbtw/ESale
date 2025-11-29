//
//  View+AdaptiveWidth.swift
//  ESale
//
//  Provides a simple way to center content and limit width on iPad while leaving iPhone layouts unchanged.
//

import SwiftUI

private struct AdaptiveWidthModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    let maxWidth: CGFloat
    
    func body(content: Content) -> some View {
        let isRegular = hSizeClass == .regular
        
        return content
            .frame(maxWidth: isRegular ? maxWidth : .infinity, alignment: .center)
            .padding(.horizontal, isRegular ? 24 : 0)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

extension View {
    /// Constrains width on iPad/regular width while keeping iPhone full width.
    func adaptiveMaxWidth(_ maxWidth: CGFloat = 720) -> some View {
        modifier(AdaptiveWidthModifier(maxWidth: maxWidth))
    }
}
