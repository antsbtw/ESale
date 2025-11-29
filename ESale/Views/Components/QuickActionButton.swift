//
//  QuickActionButton.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(color.compatGradient)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 12) {
        QuickActionButton(
            title: "审批授权",
            icon: "checkmark.circle.fill",
            color: .blue
        ) {}
        
        QuickActionButton(
            title: "扫码招商",
            icon: "qrcode.viewfinder",
            color: .green
        ) {}
        
        QuickActionButton(
            title: "我的额度",
            icon: "chart.pie.fill",
            color: .orange
        ) {}
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
