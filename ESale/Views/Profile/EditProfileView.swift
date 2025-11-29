//
//  EditProfileView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    @State private var mobile: String = ""
    @State private var email: String = ""
    @State private var isSaving = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    var body: some View {
        Form {
            // 基本信息（不可编辑）
            Section {
                HStack {
                    // 头像
                    Circle()
                        .fill(Color.blue.gradient)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(authService.currentUser?.username.prefix(1).uppercased() ?? "U")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authService.currentUser?.username ?? "")
                            .font(.title3.weight(.bold))
                        
                        Text(authService.currentUser?.roleDisplayName ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
            
            // 账户信息（不可编辑）
            Section {
                UserInfoRow(title: "用户名", value: authService.currentUser?.username ?? "-")
                UserInfoRow(title: "用户ID", value: String(authService.currentUser?.id.prefix(8) ?? "-") + "...")
                UserInfoRow(title: "注册时间", value: formatDate(authService.currentUser?.createdAt ?? ""))
            } header: {
                Text("账户信息")
            } footer: {
                Text("用户名和ID不可修改")
            }
            
            // 可编辑信息
            Section("联系方式") {
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    
                    TextField("手机号码", text: $mobile)
                        .keyboardType(.phonePad)
                }
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    
                    TextField("电子邮箱", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            
            // 代理信息
            if authService.currentUser?.role == .agent {
                Section("代理信息") {
                    UserInfoRow(title: "代理等级", value: levelDisplayText)
                    UserInfoRow(title: "账户状态", value: statusDisplayText)
                }
            }
            
            // 错误提示
            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("个人信息")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") {
                    Task {
                        await saveProfile()
                    }
                }
                .disabled(isSaving || !hasChanges)
            }
        }
        .onAppear {
            loadCurrentData()
        }
        .overlay {
            if isSaving {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView("保存中...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
        .alert("保存成功", isPresented: $showSuccess) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("个人信息已更新")
        }
    }
    
    // MARK: - Computed Properties
    
    private var levelDisplayText: String {
        if let level = authService.currentUser?.agentLevel, level > 0 {
            return "\(level)级代理"
        }
        return "普通代理"
    }
    
    private var statusDisplayText: String {
        switch authService.currentUser?.status {
        case 0: return "已禁用"
        case 1: return "正常"
        case 2: return "待审批"
        case 3: return "已拒绝"
        default: return "未知"
        }
    }
    
    private var hasChanges: Bool {
        let currentMobile = authService.currentUser?.mobile ?? ""
        let currentEmail = authService.currentUser?.email ?? ""
        return mobile != currentMobile || email != currentEmail
    }
    
    // MARK: - Methods
    
    private func loadCurrentData() {
        mobile = authService.currentUser?.mobile ?? ""
        email = authService.currentUser?.email ?? ""
    }
    
    private func saveProfile() async {
        isSaving = true
        errorMessage = nil
        
        do {
            struct UpdateProfileResponse: Codable {
                let message: String
            }
            
            let _: UpdateProfileResponse = try await APIClient.shared.post(
                .updateProfile(mobile: mobile, email: email)
            )
            
            // 刷新用户信息
            await authService.fetchCurrentUser()
            
            showSuccess = true
        } catch {
            errorMessage = "保存失败，请重试"
            print("❌ 更新个人信息失败: \(error)")
        }
        
        isSaving = false
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd"
            return displayFormatter.string(from: date)
        }
        
        // 尝试不带毫秒解析
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd"
            return displayFormatter.string(from: date)
        }
        
        return String(dateString.prefix(10))
    }
}

// MARK: - 信息行组件
struct UserInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileView()
            .environmentObject(AuthService.shared)
    }
}
