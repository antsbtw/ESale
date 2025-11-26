//
//  ProductManagementViewModel.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//


import Foundation

@MainActor
class ProductManagementViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingSuccess = false
    @Published var successMessage = ""
    
    // MARK: - 加载产品列表
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let list: [Product] = try await APIClient.shared.get(.productList)
            self.products = list
        } catch {
            errorMessage = "加载失败: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - 创建产品
    func createProduct(name: String, code: String, description: String, iconUrl: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: SuccessResponse = try await APIClient.shared.post(
                .createProduct(name: name, code: code, description: description, iconUrl: iconUrl)
            )
            successMessage = "产品创建成功"
            showingSuccess = true
            await loadProducts()
            return true
        } catch {
            errorMessage = "创建失败: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - 更新产品
    func updateProduct(id: String, name: String, code: String, description: String, iconUrl: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: SuccessResponse = try await APIClient.shared.put(
                .updateProduct(id: id, name: name, code: code, description: description, iconUrl: iconUrl)
            )
            successMessage = "产品更新成功"
            showingSuccess = true
            await loadProducts()
            return true
        } catch {
            errorMessage = "更新失败: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - 更新产品状态
    func toggleProductStatus(_ product: Product) async {
        do {
            let _: SuccessResponse = try await APIClient.shared.put(
                .updateProductStatus(id: product.id, isActive: !product.isActive)
            )
            await loadProducts()
        } catch {
            errorMessage = "状态更新失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 删除产品
    func deleteProduct(id: String) async -> Bool {
        do {
            let _: SuccessResponse = try await APIClient.shared.delete(.deleteProduct(id: id))
            successMessage = "产品删除成功"
            showingSuccess = true
            await loadProducts()
            return true
        } catch {
            errorMessage = "删除失败: \(error.localizedDescription)"
            return false
        }
    }
}
