//
//  PackageEditView.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//


import SwiftUI

struct PackageEditView: View {
    @ObservedObject var viewModel: PackageManagementViewModel
    let package: AgentPackage?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var code: String = ""
    @State private var price: String = ""
    @State private var durationDays: String = ""
    @State private var isActive: Bool = true
    @State private var quotaInputs: [QuotaInput] = []
    @State private var isSaving = false
    
    private var isEditing: Bool {
        package != nil
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !code.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(price) != nil && Double(price)! > 0 &&
        Int(durationDays) != nil && Int(durationDays)! > 0 &&
        quotaInputs.contains { $0.quota > 0 }  // 新增：至少有一个产品配额大于0
    }
    
    var body: some View {
        NavigationContainer {
            Form {
                // 基本信息
                Section("基本信息") {
                    TextField("套餐名称", text: $name)
                    
                    TextField("套餐代码", text: $code)
                        .textInputAutocapitalization(.characters)
                    
                    HStack {
                        Text("¥")
                        TextField("价格", text: $price)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        TextField("有效期", text: $durationDays)
                            .keyboardType(.numberPad)
                        Text("天")
                            .foregroundStyle(.secondary)
                    }
                    
                    Toggle("启用套餐", isOn: $isActive)
                }
                
                // 产品配额
                Section {
                    if viewModel.products.isEmpty {
                        Text("暂无可用产品")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.products) { product in
                            PackageQuotaInputRow(
                                product: product,
                                quota: bindingForProduct(product.id)
                            )
                        }
                    }
                } header: {
                    Text("产品配额")
                } footer: {
                    Text("至少为一个产品设置配额（配额大于0），否则无法创建套餐")
                        .foregroundStyle(.secondary)
                }            }
            .navigationTitle(isEditing ? "编辑套餐" : "新增套餐")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "保存" : "创建") {
                        Task {
                            await savePackage()
                        }
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
            .task {
                // 先加载产品列表
                if viewModel.products.isEmpty {
                    await viewModel.loadProducts()
                }
                // 然后初始化数据
                setupInitialData()
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
    
    // MARK: - 初始化数据
    private func setupInitialData() {
        // 初始化配额输入（所有产品默认为0）
        quotaInputs = viewModel.products.map { product in
            QuotaInput(productId: product.id, quota: 0)
        }
        
        // 如果是编辑模式，填充现有数据
        if let package = package {
            name = package.name
            code = package.code
            price = String(format: "%.2f", package.price)
            durationDays = String(package.durationDays)
            isActive = package.isActive
            
            // 填充现有配额
            if let existingQuotas = package.productQuotas {
                for quota in existingQuotas {
                    if let index = quotaInputs.firstIndex(where: { $0.productId == quota.productId }) {
                        quotaInputs[index].quota = quota.quota
                    }
                }
            }
        }
    }
    
    // MARK: - 获取产品配额绑定
    private func bindingForProduct(_ productId: String) -> Binding<Int> {
        Binding(
            get: {
                quotaInputs.first(where: { $0.productId == productId })?.quota ?? 0
            },
            set: { newValue in
                if let index = quotaInputs.firstIndex(where: { $0.productId == productId }) {
                    quotaInputs[index].quota = newValue
                }
            }
        )
    }
    
    // MARK: - 保存套餐
    private func savePackage() async {
        isSaving = true
        
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedCode = code.trimmingCharacters(in: .whitespaces)
        let priceValue = Double(price) ?? 0
        let durationValue = Int(durationDays) ?? 0
        
        // 只保存配额大于0的产品
        let validQuotas = quotaInputs.filter { $0.quota > 0 }
        
        let success: Bool
        if let package = package {
            success = await viewModel.updatePackage(
                id: package.id,
                name: trimmedName,
                code: trimmedCode,
                price: priceValue,
                durationDays: durationValue,
                isActive: isActive,
                productQuotas: validQuotas
            )
        } else {
            success = await viewModel.createPackage(
                name: trimmedName,
                code: trimmedCode,
                price: priceValue,
                durationDays: durationValue,
                isActive: isActive,
                productQuotas: validQuotas
            )
        }
        
        isSaving = false
        
        if success {
            dismiss()
        }
    }
}

// MARK: - 产品配额输入行（管理员编辑套餐用）
struct PackageQuotaInputRow: View {
    let product: Product
    @Binding var quota: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.subheadline)
                
                Text(product.code)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    if quota > 0 {
                        quota -= 10
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(quota > 0 ? .blue : .gray)
                }
                .buttonStyle(.plain)
                
                TextField("0", value: $quota, format: .number)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    quota += 10
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    PackageEditView(viewModel: PackageManagementViewModel(), package: nil)
}
