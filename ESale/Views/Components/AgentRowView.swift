//
//  AgentRowView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct AgentRowView: View {
    let agent: AgentSummary
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像
            Circle()
                .fill(avatarColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(agent.username.prefix(1).uppercased())
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                )
            
            // 信息
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(agent.username)
                        .font(.headline)
                    
                    if let level = agent.agentLevel {
                        Text("Lv\(level)")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .cornerRadius(4)
                    }
                    
                    statusBadge
                }
                
                if let mobile = agent.mobile, !mobile.isEmpty {
                    Text(mobile)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 16) {
                    Label("\(String(describing: agent.childCount))下级", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(formatDate(agent.createdAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
    
    private var avatarColor: Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .red]
        let index = abs(agent.username.hashValue) % colors.count
        return colors[index]
    }
    
    private var statusBadge: some View {
        Group {
            switch agent.status {
            case 0:
                Text("已禁用")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .foregroundStyle(.gray)
                    .cornerRadius(4)
            case 2:
                Text("待审批")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.2))
                    .foregroundStyle(.orange)
                    .cornerRadius(4)
            case 3:
                Text("已拒绝")
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.2))
                    .foregroundStyle(.red)
                    .cornerRadius(4)
            default:
                EmptyView()
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "yyyy-MM-dd"
        return displayFormatter.string(from: date)
    }
}
