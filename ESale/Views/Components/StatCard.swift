//
//  StatCard.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        color: Color = .blue
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部：图标和标题
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color.gradient)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            // 中部：数值
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            // 底部：副标题
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

#Preview {
    VStack {
        StatCard(
            title: "下级代理",
            value: "23",
            subtitle: "本月新增 +8",
            icon: "person.3.fill",
            color: .blue
        )
        
        StatCard(
            title: "最终用户",
            value: "156",
            subtitle: "本月新增 +47",
            icon: "person.2.fill",
            color: .green
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}