//
//  PurchaseRequest.swift
//  ESale
//
//  Created by wenwu on 11/26/25.
//


import SwiftUI

// MARK: - 采购请求模型（管理员视角）
struct PurchaseRequest: Codable, Identifiable {
    let id: String
    let agentId: String
    let agentName: String
    let agentUsername: String
    let packageId: String?
    let packageName: String?
    let packageCode: String?
    let amountDisplay: Double?
    let status: String
    let createdAt: String
    
    var amountText: String {
        if let amount = amountDisplay {
            return String(format: "¥%.2f", amount)
        }
        return "¥0.00"
    }
}

@MainActor
class PurchaseApprovalViewModel: ObservableObject {
    @Published var pendingRequests: [PurchaseRequest] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - 加载待审批列表
    func loadPendingRequests() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 根据角色选择不同的API
            let list: [PurchaseRequest]
            if AuthService.shared.currentUser?.role == .admin {
                // 管理员：查看所有一级代理的请求
                list = try await APIClient.shared.get(.adminPendingPayments(status: "pending"))
            } else {
                // 代理商：查看下级的请求
                list = try await APIClient.shared.get(.agentPurchasePending(status: "pending"))
            }
            self.pendingRequests = list
            print("📋 加载到 \(list.count) 个待审批采购请求")
        } catch {
            errorMessage = "加载失败: \(error.localizedDescription)"
            print("❌ 加载采购请求失败: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - 确认采购
    func confirmPurchase(sessionId: String, remark: String? = nil) async -> Bool {
        do {
            // 根据角色选择不同的API
            if AuthService.shared.currentUser?.role == .admin {
                let _: SuccessResponse = try await APIClient.shared.post(
                    .adminConfirmPayment(sessionId: sessionId, remark: remark)
                )
            } else {
                let _: SuccessResponse = try await APIClient.shared.post(
                    .agentPurchaseConfirm(sessionId: sessionId, remark: remark)
                )
            }
            print("✅ 采购确认成功")
            await loadPendingRequests()
            return true
        } catch {
            errorMessage = "确认失败: \(error.localizedDescription)"
            print("❌ 确认采购失败: \(error)")
            return false
        }
    }
    
    // MARK: - 拒绝采购
    func rejectPurchase(sessionId: String, remark: String? = nil) async -> Bool {
        do {
            // 根据角色选择不同的API
            if AuthService.shared.currentUser?.role == .admin {
                let _: SuccessResponse = try await APIClient.shared.post(
                    .rejectPayment(sessionId: sessionId, remark: remark)
                )
            } else {
                let _: SuccessResponse = try await APIClient.shared.post(
                    .agentPurchaseReject(sessionId: sessionId, remark: remark)
                )
            }
            print("✅ 采购已拒绝")
            await loadPendingRequests()
            return true
        } catch {
            errorMessage = "拒绝失败: \(error.localizedDescription)"
            print("❌ 拒绝采购失败: \(error)")
            return false
        }
    }
    
}

struct PurchaseApprovalView: View {
    @StateObject private var viewModel = PurchaseApprovalViewModel()
    @State private var showConfirmAlert = false
    @State private var showRejectAlert = false
    @State private var selectedRequest: PurchaseRequest?
    
    var body: some View {
        List {
            if viewModel.pendingRequests.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "暂无待审批请求",
                    systemImage: "checkmark.circle",
                    description: Text("所有采购请求都已处理")
                )
            } else {
                ForEach(viewModel.pendingRequests) { request in
                    PurchaseRequestRow(
                        request: request,
                        onConfirm: {
                            selectedRequest = request
                            showConfirmAlert = true
                        },
                        onReject: {
                            selectedRequest = request
                            showRejectAlert = true
                        }
                    )
                }
            }
        }
        .navigationTitle("采购审批")
        .overlay {
            if viewModel.isLoading && viewModel.pendingRequests.isEmpty {
                ProgressView("加载中...")
            }
        }
        .refreshable {
            await viewModel.loadPendingRequests()
        }
        .task {
            await viewModel.loadPendingRequests()
        }
        .alert("确认采购", isPresented: $showConfirmAlert) {
            Button("取消", role: .cancel) { }
            Button("确认") {
                if let request = selectedRequest {
                    Task {
                        await viewModel.confirmPurchase(sessionId: request.id)
                    }
                }
            }
        } message: {
            Text("确定要批准这笔采购吗？\n\n金额：\(selectedRequest?.amountText ?? "")")
        }
        .alert("拒绝采购", isPresented: $showRejectAlert) {
            Button("取消", role: .cancel) { }
            Button("拒绝", role: .destructive) {
                if let request = selectedRequest {
                    Task {
                        await viewModel.rejectPurchase(sessionId: request.id)
                    }
                }
            }
        } message: {
            Text("确定要拒绝这笔采购吗？")
        }
        .alert("提示", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("确定") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

// MARK: - 采购请求行
struct PurchaseRequestRow: View {
    let request: PurchaseRequest
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.agentName)
                        .font(.headline)
                    
                    Text("@\(request.agentUsername)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(request.amountText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
            
            // 套餐信息
            if let packageName = request.packageName {
                HStack {
                    Image(systemName: "shippingbox.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text(packageName)
                        .font(.subheadline)
                    if let code = request.packageCode {
                        Text("(\(code))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            HStack {
                Text(formatDate(request.createdAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 12) {
                    Button {
                        onReject()
                    } label: {
                        Text("拒绝")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .foregroundStyle(.red)
                            .cornerRadius(8)
                    }
                    
                    Button {
                        onConfirm()
                    } label: {
                        Text("批准")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        if let range = dateString.range(of: "T") {
            let datePart = String(dateString[..<range.lowerBound])
            return datePart
        }
        return dateString
    }
}

#Preview {
    NavigationStack {
        PurchaseApprovalView()
    }
}
