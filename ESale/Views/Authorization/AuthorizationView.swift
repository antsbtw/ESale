//
//  AuthorizationView.swift
//  ESale
//
//  授权管理主页面
//

import SwiftUI

struct AuthorizationView: View {
    @StateObject private var viewModel = AuthorizationViewModel()
    @EnvironmentObject var authService: AuthService
    @State private var showQuotaDetail = false
    @State private var showAllPackages = false
    @State private var showTrialQRCodeGenerator = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 配额概览区域
                    quotaSection
                    
                    // 管理员试用二维码入口
                    if authService.currentUser?.role == .admin {
                        trialQRCodeSection
                    }
                    
                    // 待激活终端用户区域（仅代理可见）
                    if authService.currentUser?.role != .admin {
                        
                        qrCodeSection
                        
                        pendingEndUsersSection
                        
                        // 用户列表区域（仅代理可见）
                        activeEndUsersSection
                    }
                    
                    // 套餐列表区域
                    packagesSection
                }
                .padding()
            }
            .navigationTitle("授权管理")
            .onAppear {
                Task {
                    await viewModel.loadAll()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .alert("提示", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("确定") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    // MARK: - 配额概览区域
    private var quotaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📦 我的授权库存")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showQuotaDetail = true
                }) {
                    Text("查看详情")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if viewModel.isLoadingQuota {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let summary = viewModel.quotaSummary {
                QuotaCardView(summary: summary)
            } else {
                Text("暂无配额数据")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        .sheet(isPresented: $showQuotaDetail) {
            QuotaDetailView(viewModel: viewModel)
        }
    }
    
    // MARK: - 试用二维码入口（管理员专用）
    
    
    private var trialQRCodeSection: some View {
        Button {
            showTrialQRCodeGenerator = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "gift.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .frame(width: 44, height: 44)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("试用二维码")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("生成试用码，用户扫码自动激活")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showTrialQRCodeGenerator) {
            QRCodeGeneratorView(isPresented: $showTrialQRCodeGenerator)
                .environmentObject(authService)
        }
    }
    
    // MARK: - 招募二维码入口
    private var qrCodeSection: some View {
        NavigationLink(destination: ProductQRCodesView()) {
            HStack(spacing: 12) {
                Image(systemName: "qrcode")
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 44, height: 44)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("招募二维码")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("生成二维码邀请终端用户注册")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 待激活终端用户区域
    private var pendingEndUsersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🔔 待激活用户")
                    .font(.headline)
                
                if viewModel.pendingEndUserCount > 0 {
                    Text("\(viewModel.pendingEndUserCount)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            
            if viewModel.isLoadingEndUsers {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.pendingEndUsers.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("暂无待激活用户")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.pendingEndUsers) { user in
                        EndUserActivationRow(
                            user: user,
                            onActivate: {
                                Task {
                                    await viewModel.activateEndUser(userId: user.id)
                                }
                            },
                            onReject: {
                                Task {
                                    await viewModel.rejectEndUser(userId: user.id)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
    
    // MARK: - 用户列表入口
    private var activeEndUsersSection: some View {
        NavigationLink(destination: EndUserListView(viewModel: viewModel)) {
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("用户列表")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("管理已激活的终端用户")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if viewModel.activeEndUserCount > 0 {
                    Text("\(viewModel.activeEndUserCount)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 套餐列表区域
    private var packagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("📋 套餐采购")
                    .font(.headline)
                
                Spacer()
                
                Text("向平台进货")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.isLoadingPackages {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.packages.isEmpty {
                Text("暂无可用套餐")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.packages.prefix(3)) { package in
                        PackageCardView(package: package)
                    }
                }
                
                if viewModel.packages.count > 3 {
                    Button(action: {
                        showAllPackages = true
                    }) {
                        Text("查看全部套餐")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }
            
            Text("💡 提示：采购后请联系管理员付款")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        .sheet(isPresented: $showAllPackages) {
            AllPackagesView(viewModel: viewModel)
        }
    }
}

// MARK: - 终端用户激活行组件
struct EndUserActivationRow: View {
    let user: AgentSummary
    let onActivate: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // 头像
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(user.username.prefix(1).uppercased())
                            .font(.headline)
                            .foregroundColor(.purple)
                    )
                
                // 用户信息
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(user.username)
                            .font(.headline)
                        
                        Text("待激活")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                    
                    // 套餐信息
                    if let productName = user.productName, let planName = user.planName {
                        HStack(spacing: 4) {
                            Image(systemName: "cube.box.fill")
                                .font(.caption)
                            Text("\(productName) - \(planName)")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            
            // 操作按钮
            HStack(spacing: 12) {
                Button(action: onReject) {
                    Text("拒绝")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Button(action: onActivate) {
                    Text("激活")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    AuthorizationView()
        .environmentObject(AuthService.shared)
}
