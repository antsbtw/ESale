//
//  EndUserDetailView.swift
//  ESale
//
//  终端用户详情
//

import SwiftUI

struct EndUserDetailView: View {
    let user: AgentSummary
    @ObservedObject var viewModel: AuthorizationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDeactivateAlert = false
    @State private var isDeactivating = false
    
    var body: some View {
        List {
            // 用户信息卡片
            Section {
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Text(user.username.prefix(1).uppercased())
                                .font(.title)
                                .foregroundColor(.green)
                        )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(user.username)
                                .font(.title2.weight(.bold))
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                        
                        Text("终端用户")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // 基本信息
            Section("基本信息") {
                DetailInfoRow(title: "用户名", value: user.username)
                DetailInfoRow(title: "手机号", value: user.mobile?.isEmpty == false ? user.mobile! : "未填写")
                DetailInfoRow(title: "邮箱", value: user.email?.isEmpty == false ? user.email! : "未填写")
                DetailInfoRow(title: "注册时间", value: formatDate(user.createdAt))
            }

            // 套餐信息
            Section("授权信息") {
                if let productName = user.productName {
                    DetailInfoRow(title: "产品", value: productName)
                }
                if let planName = user.planName {
                    DetailInfoRow(title: "套餐", value: planName)
                }
                DetailInfoRow(title: "状态", value: "已激活", valueColor: .green)
            }
            
            // 操作区域
            Section {
                Button(role: .destructive) {
                    showDeactivateAlert = true
                } label: {
                    HStack {
                        Spacer()
                        if isDeactivating {
                            ProgressView()
                                .padding(.trailing, 8)
                        }
                        Label("停用此用户", systemImage: "person.crop.circle.badge.xmark")
                        Spacer()
                    }
                }
                .disabled(isDeactivating)
            } footer: {
                Text("停用后，该用户将无法继续使用服务。此操作可以撤销。")
            }
        }
        .navigationTitle("用户详情")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确认停用", isPresented: $showDeactivateAlert) {
            Button("取消", role: .cancel) { }
            Button("停用", role: .destructive) {
                Task {
                    await deactivateUser()
                }
            }
        } message: {
            Text("确定要停用用户「\(user.username)」吗？\n\n停用后该用户将无法使用服务。")
        }
    }
    
    private func deactivateUser() async {
        isDeactivating = true
        let success = await viewModel.deactivateEndUser(userId: user.id)
        isDeactivating = false
        
        if success {
            dismiss()
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return displayFormatter.string(from: date)
        }
        
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
}

// MARK: - 信息行组件
struct DetailInfoRow: View {
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
        }
    }
}

