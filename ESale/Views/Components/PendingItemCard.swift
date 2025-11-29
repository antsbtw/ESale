//
//  PendingItemCard.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct PendingItemCard: View {
    let item: PendingItem
    let onApprove: () -> Void
    let onReject: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部：类型图标和申请人
            HStack(alignment: .top) {
                Image(systemName: item.iconName)
                    .font(.title3)
                    .foregroundStyle(item.typeColor.compatGradient)
                    .frame(width: 40, height: 40)
                    .background(item.typeColor.opacity(0.1))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.applicantName)
                            .font(.headline)
                        
                        Text(item.typeDisplayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(item.typeColor.opacity(0.1))
                            .foregroundStyle(item.typeColor)
                            .cornerRadius(4)
                    }
                    
                    Text(item.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(item.timeAgo)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
            }
            
            // 底部：操作按钮
            HStack(spacing: 12) {
                if let onReject = onReject {
                    Button(action: onReject) {
                        Text("拒绝")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .foregroundStyle(.primary)
                            .cornerRadius(8)
                    }
                }
                
                Button(action: onApprove) {
                    Text("审批")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(item.typeColor.compatGradient)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

// MARK: - PendingItem Extensions
extension PendingItem {
    var iconName: String {
        switch type {
        case .agentApplication:
            return "person.badge.plus"
        case .licenseRequest:
            return "key.fill"
        case .quotaRequest:
            return "cart.fill"
        }
    }
    
    var typeColor: Color {
        switch type {
        case .agentApplication:
            return .blue
        case .licenseRequest:
            return .orange
        case .quotaRequest:
            return .purple
        }
    }
    
    var typeDisplayName: String {
        switch type {
        case .agentApplication:
            return "代理申请"
        case .licenseRequest:
            return "授权申请"
        case .quotaRequest:
            return "额度申请"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PendingItemCard(
            item: PendingItem(
                id: "1",
                type: .agentApplication,
                applicantName: "李明",
                applicantId: "user_001",
                details: "申请成为下级代理",
                createdAt: "2024-11-24T10:00:00Z",
                metadata: nil
            ),
            onApprove: {},
            onReject: {}
        )
        
        PendingItemCard(
            item: PendingItem(
                id: "2",
                type: .licenseRequest,
                applicantName: "王芳",
                applicantId: "user_002",
                details: "申请授权 VPN套餐A × 5个",
                createdAt: "2024-11-23T15:30:00Z",
                metadata: nil
            ),
            onApprove: {},
            onReject: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
