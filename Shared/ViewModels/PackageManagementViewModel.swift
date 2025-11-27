//
//  PackageManagementViewModel.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//


import Foundation

@MainActor
class PackageManagementViewModel: ObservableObject {
    @Published var packages: [AgentPackage] = []
    @Published var products: [Product] = []  // 用于选择产品配额
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - 加载我的套餐列表
    func loadPackages() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 使用 /agent/package/mine 获取我创建的套餐
            let list: [AgentPackage] = try await APIClient.shared.get(.myPackages)
            self.packages = list
            print("📦 加载到 \(list.count) 个我的套餐")
        } catch {
            errorMessage = "加载失败: \(error.localizedDescription)"
            print("❌ 加载套餐失败: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - 加载产品列表（用于配额选择）
    func loadProducts() async {
        print("📦 开始加载产品列表...")
        do {
            let list: [Product] = try await APIClient.shared.get(.productList)
            print("📦 获取到 \(list.count) 个产品")
            for product in list {
                print("  - \(product.name) (ID: \(product.id), isActive: \(product.isActive))")
            }
            self.products = list.filter { $0.isActive }  // 只显示激活的产品
            print("📦 过滤后剩余 \(self.products.count) 个激活产品")
        } catch {
            print("❌ 加载产品列表失败: \(error)")
        }
    }
    
    // MARK: - 创建套餐
    func createPackage(name: String, code: String, price: Double, durationDays: Int, isActive: Bool, productQuotas: [QuotaInput]) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let quotasArray = productQuotas.map { ["productId": $0.productId, "quota": $0.quota] as [String: Any] }
        
        do {
            let _: SuccessResponse = try await APIClient.shared.post(
                .createPackage(name: name, code: code, price: price, durationDays: durationDays, isActive: isActive, productQuotas: quotasArray)
            )
            await loadPackages()
            return true
        } catch {
            errorMessage = "创建失败: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - 更新套餐
    func updatePackage(id: String, name: String, code: String, price: Double, durationDays: Int, isActive: Bool, productQuotas: [QuotaInput]) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        let quotasArray = productQuotas.map { ["productId": $0.productId, "quota": $0.quota] as [String: Any] }
        
        do {
            let _: SuccessResponse = try await APIClient.shared.put(
                .updatePackage(id: id, name: name, code: code, price: price, durationDays: durationDays, isActive: isActive, productQuotas: quotasArray)
            )
            await loadPackages()
            return true
        } catch {
            errorMessage = "更新失败: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - 更新套餐状态
    func togglePackageStatus(_ package: AgentPackage) async {
        do {
            let _: SuccessResponse = try await APIClient.shared.put(
                .updatePackageStatus(id: package.id, isActive: !package.isActive)
            )
            await loadPackages()
        } catch {
            errorMessage = "状态更新失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 删除套餐
    func deletePackage(id: String) async -> Bool {
        do {
            let _: SuccessResponse = try await APIClient.shared.delete(.deletePackage(id: id))
            await loadPackages()
            return true
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
            return false
        }
    }
}

// MARK: - 配额输入辅助结构
struct QuotaInput: Identifiable {
    let id = UUID()
    var productId: String
    var quota: Int
}
