//
//  ProfileView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showingChangePassword: Bool = false
    @State private var showingLogoutAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                // 用户信息卡片
                userInfoSection
                
                // 账号管理
                Section("账号管理") {
                    NavigationLink {
                        MyQRCodesView()
                    } label: {
                        Label("我的二维码", systemImage: "qrcode")
                    }
                    Button {
                        print("✅ 点击了修改密码")  // 调试日志
                        showingChangePassword = true
                    } label: {
                        HStack {
                            Label("修改密码", systemImage: "key.fill")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    NavigationLink {
                        EditProfileView()
                    } label: {
                        Label("个人信息", systemImage: "person.fill")
                    }
                }
                
                // 管理中心（仅管理员可见）
                if authService.currentUser?.role == .admin {
                    Section("管理中心") {
                        NavigationLink {
                            PurchaseApprovalView()
                        } label: {
                            Label("采购审批", systemImage: "doc.text.magnifyingglass")
                        }
                        
                        NavigationLink {
                            ProductManagementView()
                        } label: {
                            Label("产品管理", systemImage: "cube.box.fill")
                        }
                        
                        NavigationLink {
                            PackageManagementView()
                        } label: {
                            Label("套餐管理", systemImage: "shippingbox.fill")
                        }
                    }
                }
                
                // 通用设置
                Section("通用设置") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("通知设置", systemImage: "bell.fill")
                    }
                    
                    HStack {
                        Label("语言", systemImage: "globe")
                        Spacer()
                        Text("简体中文")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 关于
                Section("关于") {
                    HStack {
                        Label("应用版本", systemImage: "info.circle.fill")
                        Spacer()
                        Text("v1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("隐私政策", systemImage: "hand.raised.fill")
                    }
                    
                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        Label("用户协议", systemImage: "doc.text.fill")
                    }
                }
                
                // 退出登录
                Section {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("退出登录", systemImage: "rectangle.portrait.and.arrow.right")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("我的")
        }
        .sheet(isPresented: $showingChangePassword) {
            ChangePasswordView(isPresented: $showingChangePassword)
        }
        .alert("退出登录", isPresented: $showingLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("确认退出", role: .destructive) {
                Task {
                    await authService.logout()
                }
            }
        } message: {
            Text("确认要退出登录吗？")
        }
    }
    
    // MARK: - 用户信息卡片
    private var userInfoSection: some View {
        Section {
            HStack(spacing: 16) {
                // 头像
                Circle()
                    .fill(Color.blue.gradient)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Text(authService.currentUser?.username.prefix(1).uppercased() ?? "U")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(authService.currentUser?.username ?? "未登录")
                        .font(.title3.weight(.bold))
                    
                    Text(authService.currentUser?.roleDisplayName ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if let mobile = authService.currentUser?.mobile {
                        Text(mobile)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService.shared)
}
