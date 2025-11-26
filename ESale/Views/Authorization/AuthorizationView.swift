//
//  AuthorizationView.swift
//  ESale
//
//  授权管理主页面
//

import SwiftUI

struct AuthorizationView: View {
    @StateObject private var viewModel = AuthorizationViewModel()
    @State private var showQuotaDetail = false
    @State private var showAllRequests = false
    @State private var showAllPackages = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 配额概览区域
                    quotaSection
                    
                    // 待激活请求区域
                    activationRequestsSection
                    
                    // 套餐列表区域
                    packagesSection
                }
                .padding()
            }
            .navigationTitle("授权管理")
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
    
    // MARK: - 待激活请求区域
    private var activationRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🔔 待激活请求")
                    .font(.headline)
                
                if viewModel.pendingCount > 0 {
                    Text("\(viewModel.pendingCount)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                if viewModel.pendingCount > 3 {
                    Button(action: {
                        showAllRequests = true
                    }) {
                        Text("查看全部")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if viewModel.isLoadingRequests {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.pendingRequests.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("暂无待处理请求")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.pendingRequests.prefix(3)) { request in
                        ActivationRequestRow(
                            request: request,
                            onConfirm: {
                                Task {
                                    await handleConfirm(request)
                                }
                            },
                            onReject: {
                                Task {
                                    await handleReject(request)
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
        .sheet(isPresented: $showAllRequests) {
            AllActivationRequestsView(viewModel: viewModel)
        }
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
    
    // MARK: - Actions
    private func handleConfirm(_ request: ActivationRequest) async {
        let success = await viewModel.confirmActivation(requestId: request.id)
        if success {
            // 显示成功提示
        }
    }
    
    private func handleReject(_ request: ActivationRequest) async {
        let success = await viewModel.rejectActivation(requestId: request.id)
        if success {
            // 显示成功提示
        }
    }
}

#Preview {
    AuthorizationView()
}
