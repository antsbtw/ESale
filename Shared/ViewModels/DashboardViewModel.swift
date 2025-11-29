//
//  DashboardViewModel.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var stats: DashboardStats?
    @Published var pendingEndUserCount: Int = 0
    @Published var pendingPurchaseCount: Int = 0
    @Published var pendingItems: [PendingItem] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    func loadDashboard() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response: DashboardStats = try await APIClient.shared.get(.dashboardStats)
            self.stats = response
            // 加载待激活用户数量
            struct PendingResponse: Codable {
                let total: Int
            }
            if let pending: PendingResponse = try? await APIClient.shared.get(.pendingEndUsers) {
                self.pendingEndUserCount = pending.total
                
                // 新增：加载待审批采购数量
                let purchases: [PurchaseRequest] = (try? await APIClient.shared.get(.agentPurchasePending(status: "pending"))) ?? []
                self.pendingPurchaseCount = purchases.count
            }
        } catch let error as NetworkError {
            let appError = error.toAppError()
            errorMessage = appError.errorDescription
            showError = true
            
            // 如果是未授权，触发重新登录
            if appError.isUnauthorized {
                await AuthService.shared.logout()
            }
            
            print("❌ 加载Dashboard失败: \(error)")
        } catch {
            errorMessage = "加载失败，请重试"
            showError = true
            print("❌ 未知错误: \(error)")
        }
        
        isLoading = false
    }
    
    func refresh() async {
        isRefreshing = true
        await loadDashboard()
        isRefreshing = false
    }
}
