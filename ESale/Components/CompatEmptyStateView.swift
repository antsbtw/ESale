//
//  CompatEmptyStateView.swift
//  ESale
//
//  Cross-version empty state view that falls back when ContentUnavailableView is unavailable.
//

import SwiftUI

struct CompatEmptyStateView: View {
    let title: String
    let systemImage: String
    let description: String?
    
    init(title: String, systemImage: String, description: String? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.description = description
    }
    
    var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView(
                title,
                systemImage: systemImage,
                description: description.map(Text.init)
            )
        } else {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.headline)
                if let description = description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
        }
    }
}
