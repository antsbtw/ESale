//
//  PackageCardView.swift
//  ESale
//
//  套餐卡片组件
//

import SwiftUI
import Combine

struct PackageCardView: View {
    let package: AgentPackage
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // 标题和价格
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(package.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(package.code)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(package.priceText)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("批发价")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // 配额信息
                if let quotas = package.productQuotas, !quotas.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("包含配额")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(quotas.prefix(3)) { quota in
                                QuotaBadge(
                                    name: quota.productName ?? quota.productId,
                                    count: quota.quota
                                )
                            }
                            
                            if quotas.count > 3 {
                                Text("+\(quotas.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } else {
                    Text(package.packageDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 有效期
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("有效期: \(package.durationText)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if package.isActive {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "pause.circle.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            PackageDetailView(package: package)
        }
    }
}

struct QuotaBadge: View {
    let name: String
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text(name)
            Text("\(count)")
                .fontWeight(.semibold)
        }
        .font(.caption2)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .cornerRadius(4)
    }
}

// MARK: - 套餐详情页面
struct PackageDetailView: View {
    let package: AgentPackage
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AuthorizationViewModel()
    
    @State private var showPurchaseAlert = false
    @State private var showSuccessAlert = false
    @State private var isPurchasing = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 套餐基本信息
                    VStack(alignment: .leading, spacing: 12) {
                        Text(package.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(package.code)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        HStack {
                            Text("批发价")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(package.priceText)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("有效期")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(package.durationText)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("状态")
                                .foregroundColor(.secondary)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: package.isActive ? "checkmark.circle.fill" : "pause.circle.fill")
                                Text(package.isActive ? "启用中" : "已停用")
                            }
                            .foregroundColor(package.isActive ? .green : .gray)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // 配额详情
                    if let quotas = package.productQuotas, !quotas.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("配额详情")
                                .font(.headline)
                            
                            ForEach(quotas) { quota in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(quota.productName ?? "未知产品")
                                            .font(.subheadline)
                                        
                                        if let code = quota.productCode {
                                            Text(code)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(quota.quota)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    Text("个")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    
                    // 采购说明
                    VStack(alignment: .leading, spacing: 12) {
                        Text("采购说明")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(icon: "1.circle.fill", text: "联系管理员获取收款方式")
                            InfoRow(icon: "2.circle.fill", text: "完成付款后截图保存")
                            InfoRow(icon: "3.circle.fill", text: "等待管理员确认并激活")
                            InfoRow(icon: "4.circle.fill", text: "激活后配额自动到账")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // 采购按钮
                    Button(action: {
                        showPurchaseAlert = true
                    }) {
                        HStack {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isPurchasing ? "提交中..." : "联系管理员采购")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(package.isActive && !isPurchasing ? Color.blue : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!package.isActive || isPurchasing)
                }
                .padding()
            }
            .navigationTitle("套餐详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("确认采购", isPresented: $showPurchaseAlert) {
                Button("取消", role: .cancel) { }
                Button("确认") {
                    Task {
                        await handlePurchase()
                    }
                }
            } message: {
                Text("确定要采购「\(package.name)」套餐吗？\n\n价格：\(package.priceText)\n\n提交后请联系管理员完成付款。")
            }
            .alert("采购成功", isPresented: $showSuccessAlert) {
                Button("知道了") {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("您的采购请求已提交！\n\n请联系管理员完成付款，管理员确认后配额将自动到账。")
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
    
    private func handlePurchase() async {
        isPurchasing = true
        let success = await viewModel.purchasePackage(package: package)
        isPurchasing = false
        
        if success {
            showSuccessAlert = true
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - 全部套餐列表
struct AllPackagesView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.packages) { package in
                    PackageCardView(package: package)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .navigationTitle("套餐列表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .refreshable {
                await viewModel.loadPackages()
            }
        }
    }
}

#Preview {
    PackageCardView(package: AgentPackage(
        id: "1",
        name: "专业套餐",
        code: "PRO",
        price: 199.00,
        durationDays: 30,
        isActive: true,
        createdAt: "",
        updatedAt: "",
        productQuotas: [
            PackageProductQuota(
                id: "1",
                packageId: "1",
                productId: "p1",
                quota: 500,
                createdAt: "",
                updatedAt: "",
                productName: "VPN",
                productCode: "VPN"
            ),
            PackageProductQuota(
                id: "2",
                packageId: "1",
                productId: "p2",
                quota: 200,
                createdAt: "",
                updatedAt: "",
                productName: "OCR",
                productCode: "OCR"
            )
        ]
    ))
}
