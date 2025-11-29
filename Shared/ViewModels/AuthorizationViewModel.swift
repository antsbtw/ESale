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

// MARK: - 待激活终端用户响应
struct PendingEndUsersResponse: Codable {
    let items: [AgentSummary]
    let total: Int
}


// MARK: - 已激活终端用户响应
struct EndUserListResponse: Codable {
    let items: [AgentSummary]
    let total: Int
    let page: Int
    let pageSize: Int
    let totalPages: Int
}

@MainActor
class AuthorizationViewModel: ObservableObject {
    // MARK: - Published Properties
    
    // 配额相关
    @Published var quotas: [AgentQuota] = []
    @Published var quotaSummary: QuotaSummary?
    
    // 激活请求相关（采购审批）
    @Published var pendingRequests: [ActivationRequest] = []
    @Published var pendingCount: Int = 0
    
    // 待激活终端用户（新增）
    @Published var pendingEndUsers: [AgentSummary] = []
    @Published var pendingEndUserCount: Int = 0
    @Published var isLoadingEndUsers = false
    
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
    
    // 已激活终端用户列表
    @Published var activeEndUsers: [AgentSummary] = []
    @Published var activeEndUserCount: Int = 0
    @Published var isLoadingActiveUsers = false
    
    private let apiClient = APIClient.shared
    
    // MARK: - Init
    init() {
    }
    
    // MARK: - Load All Data
    func loadAll() async {
        async let summary: () = loadQuotaSummary()
        async let requests: () = loadPendingRequests()
        async let packages: () = loadPackages()
        async let parentQuotas: () = loadParentQuotas()
        async let endUsers: () = loadPendingEndUsers()  // 新增
        async let activeUsers: () = loadActiveEndUsers()  // 新增
        
        await summary
        await requests
        await packages
        await parentQuotas
        await endUsers  // 新增
        await activeUsers
    }
    
    // MARK: - 配额管理
    
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
    
    // MARK: - 待激活终端用户管理（新增）
    
    func loadPendingEndUsers() async {
        isLoadingEndUsers = true
        defer { isLoadingEndUsers = false }
        
        do {
            let response: PendingEndUsersResponse = try await apiClient.get(.pendingEndUsers)
            self.pendingEndUsers = response.items
            self.pendingEndUserCount = response.total
            print("📱 待激活终端用户: \(response.total) 个")
        } catch {
            self.pendingEndUsers = []
            self.pendingEndUserCount = 0
            print("❌ 加载待激活终端用户失败: \(error)")
        }
    }
    
    /// 激活终端用户
    func activateEndUser(userId: String) async -> Bool {
        do {
            struct ApproveResponse: Codable {
                let message: String
            }
            
            let _: ApproveResponse = try await apiClient.post(
                .activateEndUser(userId: userId, approved: true, remark: nil)
            )
            
            print("✅ 终端用户激活成功")
            
            // 刷新数据
            await loadPendingEndUsers()
            await loadQuotaSummary()
            
            return true
        } catch {
            self.errorMessage = "激活失败: \(error.localizedDescription)"
            print("❌ 激活终端用户失败: \(error)")
            return false
        }
    }
    
    // MARK: - 已激活终端用户管理

    func loadActiveEndUsers() async {
        isLoadingActiveUsers = true
        defer { isLoadingActiveUsers = false }
        
        do {
            let response: EndUserListResponse = try await apiClient.get(.endUserList(page: 1, pageSize: 50))
            self.activeEndUsers = response.items
            self.activeEndUserCount = response.total
            print("👥 已激活终端用户: \(response.total) 个")
        } catch {
            self.activeEndUsers = []
            self.activeEndUserCount = 0
            print("❌ 加载已激活终端用户失败: \(error)")
        }
    }

    /// 停用终端用户
    func deactivateEndUser(userId: String, reason: String = "") async -> Bool {
        do {
            struct DeactivateResponse: Codable {
                let message: String
            }
            
            let _: DeactivateResponse = try await apiClient.post(
                .deactivateEndUser(userId: userId, reason: reason.isEmpty ? nil : reason)
            )
            
            print("✅ 终端用户已停用")
            
            // 刷新列表
            await loadActiveEndUsers()
            await loadQuotaSummary()
            
            return true
        } catch {
            self.errorMessage = "停用失败: \(error.localizedDescription)"
            print("❌ 停用终端用户失败: \(error)")
            return false
        }
    }
    
    /// 拒绝终端用户
    func rejectEndUser(userId: String, reason: String = "") async -> Bool {
        do {
            struct ApproveResponse: Codable {
                let message: String
            }
            
            let _: ApproveResponse = try await apiClient.post(
                .activateEndUser(userId: userId, approved: false, remark: reason)
            )
            
            print("✅ 终端用户已拒绝")
            
            await loadPendingEndUsers()
            
            return true
        } catch {
            self.errorMessage = "拒绝失败: \(error.localizedDescription)"
            print("❌ 拒绝终端用户失败: \(error)")
            return false
        }
    }
    
    // MARK: - 激活请求管理（采购审批）
    
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
    
    func confirmActivation(requestId: String, remark: String? = nil) async -> Bool {
        do {
            struct ConfirmResponse: Codable {
                let status: String
            }
            
            let response: ConfirmResponse = try await apiClient.post(.confirmPayment(sessionId: requestId, remark: remark))
            
            print("✅ 激活成功: \(response.status)")
            
            await loadPendingRequests()
            await loadQuotaSummary()
            
            return true
        } catch {
            self.errorMessage = "激活失败: \(error.localizedDescription)"
            print("❌ 激活失败: \(error)")
            return false
        }
    }
    
    func rejectActivation(requestId: String, reason: String = "") async -> Bool {
        do {
            struct RejectResponse: Codable {
                let status: String
            }
            
            let response: RejectResponse = try await apiClient.post(.rejectPayment(sessionId: requestId, remark: reason))
            
            print("✅ 拒绝成功: \(response.status)")
            
            await loadPendingRequests()
            
            return true
        } catch {
            self.errorMessage = "拒绝失败: \(error.localizedDescription)"
            print("❌ 拒绝失败: \(error)")
            return false
        }
    }
    
    // MARK: - 套餐管理
    
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
    
    func purchasePackage(package: AgentPackage) async -> Bool {
        do {
            let sellerId = AuthService.shared.currentUser?.parentId
            
            let _: SuccessResponse = try await apiClient.post(
                .createPaymentSession(
                    packageId: package.id,
                    amount: package.price,
                    sellerId: sellerId
                )
            )
            
            print("✅ 采购请求已提交")
            
            await loadPendingRequests()
            
            return true
        } catch {
            self.errorMessage = "采购失败: \(error.localizedDescription)"
            print("❌ 采购失败: \(error)")
            return false
        }
    }
    
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
            self.parentQuotas = []
            self.parentId = nil
            print("ℹ️ 无上级代理或配额: \(error.localizedDescription)")
        }
    }
    
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
