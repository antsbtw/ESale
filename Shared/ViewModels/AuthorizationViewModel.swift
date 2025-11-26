//
//  AuthorizationViewModel.swift
//  ESale
//
//  授权管理 ViewModel
//

import Foundation
import Combine

// MARK: - 上级可售配额模型
struct ParentQuota: Codable {
    let productId: String
    let productName: String
    let productCode: String
    let available: Int
    let sellerId: String
}

struct ParentQuotasResponse: Codable {
    let parentId: String
    let quotas: [ParentQuota]
}

@MainActor
class AuthorizationViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // 配额相关
    @Published var quotas: [AgentQuota] = []
    @Published var quotaSummary: QuotaSummary?
    
    // 激活请求相关
    @Published var pendingRequests: [ActivationRequest] = []
    @Published var pendingCount: Int = 0
    
    // 套餐相关
    @Published var packages: [AgentPackage] = []
    
    // UI 状态
    @Published var isLoadingQuota = false
    @Published var isLoadingRequests = false
    @Published var isLoadingPackages = false
    @Published var errorMessage: String?
    
    // 上级配额相关
    @Published var parentQuotas: [ParentQuota] = []
    @Published var parentId: String?
    @Published var isLoadingParentQuotas = false
    
    private let apiClient = APIClient.shared
    
    // MARK: - Init
    init() {
        // 初始化时加载数据
        Task {
            await loadAll()
        }
    }
    
    // MARK: - Load All Data
    func loadAll() async {
        async let summary: () = loadQuotaSummary()
        async let requests: () = loadPendingRequests()
        async let packages: () = loadPackages()
        async let parentQuotas: () = loadParentQuotas()  // ⭐ 新增
        
        await summary
        await requests
        await packages
        await parentQuotas  // ⭐ 新增
    }
    
    // MARK: - 配额管理
    
    /// 加载配额汇总
    func loadQuotaSummary() async {
        isLoadingQuota = true
        defer { isLoadingQuota = false }
        
        do {
            let summary: QuotaSummary = try await apiClient.get(.quotaSummary)
            self.quotaSummary = summary
        } catch {
            self.errorMessage = "加载配额失败: \(error.localizedDescription)"
            print("❌ 加载配额汇总失败: \(error)")
        }
    }
    
    /// 加载配额详情列表
    func loadQuotaDetails() async {
        isLoadingQuota = true
        defer { isLoadingQuota = false }
        
        do {
            let quotas: [AgentQuota] = try await apiClient.get(.quotaList)
            self.quotas = quotas
        } catch {
            self.errorMessage = "加载配额详情失败: \(error.localizedDescription)"
            print("❌ 加载配额详情失败: \(error)")
        }
    }
    
    // MARK: - 激活请求管理
    
    /// 加载待激活请求列表
    func loadPendingRequests() async {
        isLoadingRequests = true
        defer { isLoadingRequests = false }
        
        do {
            let requests: [ActivationRequest] = try await apiClient.get(.pendingPayments(status: "pending"))
            self.pendingRequests = requests
            self.pendingCount = requests.count
        } catch {
            self.errorMessage = "加载激活请求失败: \(error.localizedDescription)"
            print("❌ 加载激活请求失败: \(error)")
        }
    }
    
    /// 确认激活（代理已收款）
    func confirmActivation(requestId: String, remark: String? = nil) async -> Bool {
        do {
            struct ConfirmResponse: Codable {
                let status: String
            }
            
            let response: ConfirmResponse = try await apiClient.post(.confirmPayment(sessionId: requestId, remark: remark))
            
            print("✅ 激活成功: \(response.status)")
            
            // 激活成功，刷新数据
            await loadPendingRequests()
            await loadQuotaSummary()
            
            return true
        } catch {
            self.errorMessage = "激活失败: \(error.localizedDescription)"
            print("❌ 激活失败: \(error)")
            return false
        }
    }
    
    /// 拒绝激活
    func rejectActivation(requestId: String, reason: String = "") async -> Bool {
        do {
            struct RejectResponse: Codable {
                let status: String
            }
            
            let response: RejectResponse = try await apiClient.post(.rejectPayment(sessionId: requestId, remark: reason))
            
            print("✅ 拒绝成功: \(response.status)")
            
            // 刷新列表
            await loadPendingRequests()
            
            return true
        } catch {
            self.errorMessage = "拒绝失败: \(error.localizedDescription)"
            print("❌ 拒绝失败: \(error)")
            return false
        }
    }
    
    // MARK: - 套餐管理
    
    /// 加载套餐列表
    func loadPackages() async {
        isLoadingPackages = true
        defer { isLoadingPackages = false }
        
        do {
            let packages: [AgentPackage] = try await apiClient.get(.packageList)
            self.packages = packages
        } catch {
            self.errorMessage = "加载套餐失败: \(error.localizedDescription)"
            print("❌ 加载套餐失败: \(error)")
        }
    }
    
    /// 采购套餐（创建支付会话）
    func purchasePackage(package: AgentPackage) async -> Bool {
        do {
            let _: SuccessResponse = try await apiClient.post(
                .createPaymentSession(
                    packageId: package.id,
                    amount: package.price
                )
            )
            
            print("✅ 采购请求已提交")
            
            // 刷新数据
            await loadPendingRequests()
            
            return true
        } catch {
            self.errorMessage = "采购失败: \(error.localizedDescription)"
            print("❌ 采购失败: \(error)")
            return false
        }
    }
    
    /// 检查配额是否充足
    func checkQuota(productId: String) async -> Bool {
        do {
            struct QuotaCheckResponse: Codable {
                let available: Bool
                let quotaId: String
                let productId: String
                let required: Int
            }
            
            let result: QuotaCheckResponse = try await apiClient.get(.quotaCheck(productId: productId))
            return result.available
        } catch {
            print("❌ 检查配额失败: \(error)")
            return false
        }
    }
    
    // MARK: - 加载上级可售配额
    func loadParentQuotas() async {
        isLoadingParentQuotas = true
        defer { isLoadingParentQuotas = false }
        
        do {
            let response: ParentQuotasResponse = try await apiClient.get(.parentQuotas)
            self.parentId = response.parentId
            self.parentQuotas = response.quotas
            print("📦 上级可售配额: \(response.quotas.count) 个产品")
        } catch {
            // 可能没有上级代理，这是正常的
            self.parentQuotas = []
            self.parentId = nil
            print("ℹ️ 无上级代理或配额: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 向上级采购
    func purchaseFromParent(productId: String, sellerId: String, quantity: Int, amount: Double) async -> Bool {
        do {
            let _: SuccessResponse = try await apiClient.post(
                .createPaymentSessionFromParent(
                    sellerId: sellerId,
                    productId: productId,
                    quantity: quantity,
                    amount: amount
                )
            )
            
            print("✅ 向上级采购请求已提交")
            return true
        } catch {
            self.errorMessage = "采购失败: \(error.localizedDescription)"
            print("❌ 向上级采购失败: \(error)")
            return false
        }
    }
    
    // MARK: - Refresh
    func refresh() async {
        await loadAll()
    }
}
