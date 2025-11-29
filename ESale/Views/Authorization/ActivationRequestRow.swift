//
//  ActivationRequestRow.swift
//  ESale
//
//  激活请求行组件
//

import SwiftUI
import Combine

// 单行激活请求
struct ActivationRequestRow: View {
    let request: ActivationRequest
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    @State private var showConfirmAlert = false
    @State private var showRejectAlert = false
    @State private var isProcessing = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 12) {
                // 请求类型和时间
                HStack {
                    // 请求类型标签
                    Text(request.requestType)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(request.packageId != nil ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                        .foregroundStyle(request.packageId != nil ? .blue : .green)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Spacer()
                    
                    Text(request.timeAgo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // 金额信息
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("采购金额")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(request.amountText)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                    
                    // 状态
                    Text(request.statusText)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .foregroundStyle(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                // 操作按钮
                HStack(spacing: 12) {
                    Button {
                        showRejectAlert = true
                    } label: {
                        Text("拒绝")
                            .font(.system(size: 15, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.red.opacity(0.08))
                            .foregroundStyle(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessing)
                    
                    Button {
                        showConfirmAlert = true
                    } label: {
                        HStack(spacing: 6) {
                            if isProcessing {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text("确认收款")
                        }
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isProcessing ? Color.gray : Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessing)
                }
            }
            .padding(14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .alert("确认收款", isPresented: $showConfirmAlert) {
            Button("取消", role: .cancel) { }
            Button("确认") {
                isProcessing = true
                onConfirm()
            }
        } message: {
            Text("确认已收到款项 \(request.amountText)？")
        }
        .alert("拒绝请求", isPresented: $showRejectAlert) {
            Button("取消", role: .cancel) { }
            Button("拒绝", role: .destructive) {
                isProcessing = true
                onReject()
            }
        } message: {
            Text("确定要拒绝此采购请求吗？")
        }
    }
}

// MARK: - 全部激活请求列表
struct AllActivationRequestsView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    
    @SwiftUI.Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationContainer {
            Group {
                if viewModel.pendingRequests.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(viewModel.pendingRequests) { request in
                            ActivationRequestRow(
                                request: request,
                                onConfirm: {
                                    Task { await handleConfirm(request: request) }
                                },
                                onReject: {
                                    Task { await handleReject(request: request) }
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("待处理请求")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .refreshable {
                await viewModel.loadPendingRequests()
            }
        }
    }
    
    // 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 52))
                .foregroundStyle(.green)
            
            Text("暂无待处理请求")
                .font(.headline)
            
            Text("当下级代理提交采购申请时，会出现在这里。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Actions
    
    @MainActor
    private func handleConfirm(request: ActivationRequest) async {
        let success = await viewModel.confirmActivation(requestId: request.id)
        if success {
            if viewModel.pendingRequests.isEmpty {
                dismiss()
            }
        }
    }
    
    @MainActor
    private func handleReject(request: ActivationRequest) async {
        _ = await viewModel.rejectActivation(requestId: request.id)
    }
}

// 预览
#Preview {
    let dummyRequest = ActivationRequest(
        id: "1",
        agentId: "agent1",
        endUserId: nil,
        packageId: "pkg1",
        productId: nil,
        productPlanId: nil,
        paymentMethod: nil,
        amountDisplay: 500.0,
        proofImageUrl: nil,
        status: "pending",
        createdAt: ISO8601DateFormatter().string(from: Date()),
        updatedAt: ISO8601DateFormatter().string(from: Date())
    )
    
    ActivationRequestRow(
        request: dummyRequest,
        onConfirm: {},
        onReject: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
