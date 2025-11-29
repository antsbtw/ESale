//
//  ProductQRCodeGeneratorView.swift
//  ESale
//
//  生成产品注册二维码
//

import SwiftUI

struct ProductQRCodeGeneratorView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = ProductQRCodeGeneratorViewModel()
    @State private var selectedPlanId: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section("选择产品套餐") {
                    if viewModel.isLoadingPlans {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if viewModel.productPlans.isEmpty {
                        Text("暂无可用产品套餐")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.productPlans) { plan in
                            Button {
                                selectedPlanId = plan.id
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(plan.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text("\(plan.productName ?? "产品") · \(plan.durationDays)天")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedPlanId == plan.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        Task {
                            let success = await viewModel.generateQRCode(planId: selectedPlanId)
                            if success {
                                isPresented = false
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isGenerating {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text("生成注册码")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(selectedPlanId == nil || viewModel.isGenerating)
                } footer: {
                    Text("生成后可分享给终端用户扫码注册")
                }
            }
            .navigationTitle("生成注册码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
            }
            .task {
                await viewModel.loadProductPlans()
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
}

// MARK: - Product Plan Model
struct ProductPlanItem: Identifiable, Codable {
    let id: String
    let productId: String
    let name: String
    let durationDays: Int
    let defaultPrice: Double?
    let productName: String?
}

// MARK: - ViewModel
@MainActor
class ProductQRCodeGeneratorViewModel: ObservableObject {
    @Published var productPlans: [ProductPlanItem] = []
    @Published var isLoadingPlans = false
    @Published var isGenerating = false
    @Published var errorMessage: String?
    
    func loadProductPlans() async {
        isLoadingPlans = true
        
        do {
            productPlans = try await APIClient.shared.get(.productPlans)
        } catch {
            print("❌ 加载产品套餐失败: \(error)")
            errorMessage = "加载产品套餐失败"
        }
        
        isLoadingPlans = false
    }
    
    func generateQRCode(planId: String?) async -> Bool {
        guard let planId = planId else {
            errorMessage = "请选择产品套餐"
            return false
        }
        
        isGenerating = true
        
        do {
            struct CreateResponse: Codable {
                let qrcodeId: String
                let agentId: String?
                let url: String?
            }
            
            let _: CreateResponse = try await APIClient.shared.post(
                .createProductQRCode(planId: planId)
            )
            
            print("✅ 生成注册码成功")
            isGenerating = false
            return true
        } catch {
            print("❌ 生成注册码失败: \(error)")
            errorMessage = "生成失败: \(error.localizedDescription)"
            isGenerating = false
            return false
        }
    }
}

#Preview {
    ProductQRCodeGeneratorView(isPresented: .constant(true))
}
