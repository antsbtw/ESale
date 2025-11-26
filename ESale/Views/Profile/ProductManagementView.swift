//
//  ProductManagementView.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//


import SwiftUI

struct ProductManagementView: View {
    @StateObject private var viewModel = ProductManagementViewModel()
    @State private var showingCreateSheet = false
    @State private var editingProduct: Product?
    @State private var showingDeleteAlert = false
    @State private var productToDelete: Product?
    
    var body: some View {
        List {
            ForEach(viewModel.products) { product in
                ProductRowView(
                    product: product,
                    onEdit: {
                        editingProduct = product
                    },
                    onToggleStatus: {
                        Task {
                            await viewModel.toggleProductStatus(product)
                        }
                    },
                    onDelete: {
                        productToDelete = product
                        showingDeleteAlert = true
                    }
                )
            }
        }
        .navigationTitle("产品管理")
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
            if viewModel.isLoading && viewModel.products.isEmpty {
                ProgressView("加载中...")
            } else if viewModel.products.isEmpty {
                ContentUnavailableView(
                    "暂无产品",
                    systemImage: "cube.box",
                    description: Text("点击右上角添加产品")
                )
            }
        }
        .refreshable {
            await viewModel.loadProducts()
        }
        .task {
            await viewModel.loadProducts()
        }
        .sheet(isPresented: $showingCreateSheet) {
            ProductEditView(viewModel: viewModel, product: nil)
        }
        .sheet(item: $editingProduct) { product in
            ProductEditView(viewModel: viewModel, product: product)
        }
        .alert("删除产品", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let product = productToDelete {
                    Task {
                        await viewModel.deleteProduct(id: product.id)
                    }
                }
            }
        } message: {
            Text("确定要删除产品「\(productToDelete?.name ?? "")」吗？此操作不可恢复。")
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

// MARK: - 产品行视图
struct ProductRowView: View {
    let product: Product
    let onEdit: () -> Void
    let onToggleStatus: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(product.name)
                            .font(.headline)
                        
                        Text(product.code)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                    
                    if !product.description.isEmpty {
                        Text(product.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                // 状态标签
                Text(product.isActive ? "启用" : "禁用")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(product.isActive ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .foregroundStyle(product.isActive ? .green : .gray)
                    .clipShape(Capsule())
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
                    Label(product.isActive ? "禁用" : "启用", systemImage: product.isActive ? "xmark.circle" : "checkmark.circle")
                        .font(.caption)
                }
                .foregroundStyle(product.isActive ? .orange : .green)
                
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
        ProductManagementView()
    }
}