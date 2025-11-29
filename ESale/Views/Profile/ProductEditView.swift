//
//  ProductEditView.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//


import SwiftUI

struct ProductEditView: View {
    @ObservedObject var viewModel: ProductManagementViewModel
    @State private var isActive: Bool = true
    let product: Product?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var code: String = ""
    @State private var description: String = ""
    @State private var iconUrl: String = ""
    @State private var isSaving = false
    
    private var isEditing: Bool {
        product != nil
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !code.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationContainer {
            Form {
                Section("基本信息") {
                    TextField("产品名称", text: $name)
                    
                    TextField("产品代码", text: $code)
                        .textInputAutocapitalization(.characters)
                        .disabled(isEditing) // 编辑时不允许修改代码
                    
                    descriptionInput
                    
                    // 新增：启用开关
                    Toggle("启用产品", isOn: $isActive)
                }
                Section("图标") {
                    TextField("图标URL（可选）", text: $iconUrl)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                }
            }
            .navigationTitle(isEditing ? "编辑产品" : "新增产品")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
            .onAppear {
                if let product = product {
                    name = product.name
                    code = product.code
                    description = product.description
                    iconUrl = product.iconUrl ?? ""
                    isActive = product.isActive  // 新增
                }
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
            .adaptiveMaxWidth(720)
        }
    }
    
    @ViewBuilder
    private var descriptionInput: some View {
        if #available(iOS 16.0, *) {
            TextField("产品描述（可选）", text: $description, axis: .vertical)
                .lineLimit(3...6)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text("产品描述（可选）")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextEditor(text: $description)
                    .frame(minHeight: 90, maxHeight: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
    }
    
    private func saveProduct() async {
        isSaving = true
        
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedCode = code.trimmingCharacters(in: .whitespaces)
        let trimmedDescription = description.trimmingCharacters(in: .whitespaces)
        let trimmedIconUrl = iconUrl.trimmingCharacters(in: .whitespaces)
        
        let success: Bool
        if let product = product {
            // 更新产品
            success = await viewModel.updateProduct(
                id: product.id,
                name: trimmedName,
                code: trimmedCode,
                description: trimmedDescription,
                iconUrl: trimmedIconUrl.isEmpty ? nil : trimmedIconUrl
            )
            
            // 如果状态改变了，额外更新状态
            if success && product.isActive != isActive {
                await viewModel.toggleProductStatus(Product(
                    id: product.id,
                    name: trimmedName,
                    code: trimmedCode,
                    description: trimmedDescription,
                    iconUrl: trimmedIconUrl.isEmpty ? nil : trimmedIconUrl,
                    isActive: !isActive,  // 传入当前相反的状态，因为 toggle 会取反
                    createdAt: product.createdAt,
                    updatedAt: product.updatedAt
                ))
            }
        } else {
            // 创建产品（创建后如果需要禁用，再调用状态更新）
            success = await viewModel.createProduct(
                name: trimmedName,
                code: trimmedCode,
                description: trimmedDescription,
                iconUrl: trimmedIconUrl.isEmpty ? nil : trimmedIconUrl
            )
        }
        
        isSaving = false
        
        if success {
            dismiss()
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("取消") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(isEditing ? "保存" : "创建") {
                Task {
                    await saveProduct()
                }
            }
            .disabled(!isFormValid || isSaving)
        }
    }
}

#Preview {
    ProductEditView(viewModel: ProductManagementViewModel(), product: nil)
}
