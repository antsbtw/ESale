//
//  AgentTreeRowView.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//


import SwiftUI

struct AgentTreeRowView: View {
    @ObservedObject var node: AgentTreeNode
    let depth: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // 主行
            HStack(spacing: 12) {
                // 缩进
                if depth > 0 {
                    Color.clear
                        .frame(width: CGFloat(depth * 20))
                }
                
                // 展开/折叠图标
                if node.hasChildren {
                    Button {
                        withAnimation {
                            node.isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                    }
                } else {
                    Color.clear.frame(width: 20)
                }
                
                // 头像
                Circle()
                    .fill(agentColor(node.agent.status))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(node.agent.username.prefix(1).uppercased())
                            .font(.headline)
                            .foregroundStyle(.white)
                    )
                
                // 信息
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(node.agent.username)
                            .font(.headline)
                        
                        if node.agent.status != 1 {
                            statusBadge(node.agent.status)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        if node.hasChildren {
                            // ✅ 显示整个子树的总数
                            Label("\(node.totalDescendants)", systemImage: "person.2.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let level = node.agent.agentLevel {
                            Text("Lv\(level)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(formatDate(node.agent.createdAt))
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
            .contentShape(Rectangle())
            
            // 递归渲染子节点
            if node.isExpanded {
                ForEach(node.children) { child in
                    NavigationLink(destination: AgentDetailView(agentId: child.agent.id)) {
                        AgentTreeRowView(node: child, depth: depth + 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private func agentColor(_ status: Int) -> Color {
        switch status {
        case 0: return .gray
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .blue
        }
    }
    
    private func statusBadge(_ status: Int) -> some View {
        Group {
            switch status {
            case 0:
                Text("已禁用").foregroundStyle(.gray)
            case 2:
                Text("待审批").foregroundStyle(.orange)
            case 3:
                Text("已拒绝").foregroundStyle(.red)
            default:
                EmptyView()
            }
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(.systemGray6))
        .cornerRadius(4)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return ""
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MM-dd"
        return displayFormatter.string(from: date)
    }
}
