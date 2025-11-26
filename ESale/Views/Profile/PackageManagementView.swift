//
//  PackageManagementView.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//

import SwiftUI

struct PackageManagementView: View {
    @StateObject private var viewModel = PackageManagementViewModel()
    @State private var showingCreateSheet = false
    @State private var editingPackage: AgentPackage?
    @State private var showingDeleteAlert = false
    @State private var packageToDelete: AgentPackage?
    
    var body: some View {
        List {
            ForEach(viewModel.packages) { package in
                PackageManagementRowView(
                    package: package,
                    onEdit: {
                        editingPackage = package
                    },
                    onToggleStatus: {
                        Task {
                            await viewModel.togglePackageStatus(package)
                        }
                    },
                    onDelete: {
                        packageToDelete = package
                        showingDeleteAlert = true
                    }
                )
            }
        }
        .navigationTitle("套餐管理")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.packages.isEmpty {
                ProgressView("加载中...")
            } else if viewModel.packages.isEmpty {
                ContentUnavailableView(
                    "暂无套餐",
                    systemImage: "shippingbox",
                    description: Text("点击右上角添加套餐")
                )
            }
        }
        .refreshable {
            await viewModel.loadPackages()
        }
        .task {
            await viewModel.loadPackages()
            await viewModel.loadProducts()
        }
        .sheet(isPresented: $showingCreateSheet) {
            PackageEditView(viewModel: viewModel, package: nil)
        }
        .sheet(item: $editingPackage) { package in
            PackageEditView(viewModel: viewModel, package: package)
        }
        .alert("删除套餐", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let package = packageToDelete {
                    Task {
                        await viewModel.deletePackage(id: package.id)
                    }
                }
            }
        } message: {
            Text("确定要删除套餐「\(packageToDelete?.name ?? "")」吗？此操作不可恢复。")
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

// MARK: - 套餐行视图
struct PackageManagementRowView: View {
    let package: AgentPackage
    let onEdit: () -> Void
    let onToggleStatus: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题行
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(package.name)
                            .font(.headline)
                        
                        Text(package.code)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.purple.opacity(0.1))
                            .foregroundStyle(.purple)
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 12) {
                        Text(package.priceText)
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                        
                        Text(package.durationText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // 状态标签
                Text(package.isActive ? "启用" : "禁用")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(package.isActive ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .foregroundStyle(package.isActive ? .green : .gray)
                    .clipShape(Capsule())
            }
            
            // 配额信息
            if let quotas = package.productQuotas, !quotas.isEmpty {
                Text(package.packageDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            // 操作按钮
            HStack(spacing: 16) {
                Button {
                    onEdit()
                } label: {
                    Label("编辑", systemImage: "pencil")
                        .font(.caption)
                }
                
                Button {
                    onToggleStatus()
                } label: {
                    Label(package.isActive ? "禁用" : "启用", systemImage: package.isActive ? "xmark.circle" : "checkmark.circle")
                        .font(.caption)
                }
                .foregroundStyle(package.isActive ? .orange : .green)
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("删除", systemImage: "trash")
                        .font(.caption)
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PackageManagementView()
    }
}
