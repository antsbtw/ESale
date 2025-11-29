//
//  AgentListViewModel.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import Foundation

@MainActor
class AgentListViewModel: ObservableObject {
    @Published var agents: [AgentSummary] = []
    @Published var agentTree: [AgentTreeNode] = []  // ✅ 添加树形结构
    @Published var pendingAgents: [AgentSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var selectedStatus: AgentStatus = .all
    @Published var currentUserId: String = ""
    
    private let pageSize = 20
    
    init() {}
    
    private func loadCurrentUser() async {
        do {
            let response: User = try await APIClient.shared.request(
                .me,
                responseType: User.self
            )
            currentUserId = response.id
        } catch {
            print("❌ 获取当前用户ID失败: \(error)")
        }
    }
    
    enum AgentStatus: Int, CaseIterable {
        case all = -1
        case active = 1
        case pending = 2
        case disabled = 0
        case rejected = 3
        
        var title: String {
            switch self {
            case .all: return "全部"
            case .active: return "正常"
            case .pending: return "待审批"
            case .disabled: return "已禁用"
            case .rejected: return "已拒绝"
            }
        }
    }
    
    // MARK: - 加载代理列表
    func loadAgents(status: AgentStatus? = nil) async {
        
        if currentUserId.isEmpty {
            await loadCurrentUser()
        }
        
        isLoading = true
        errorMessage = nil
        
        let filterStatus = (status ?? selectedStatus).rawValue
        let statusParam = filterStatus == -1 ? nil : filterStatus
        
        do {
            let response: PaginatedResponse<AgentSummary> = try await APIClient.shared.get(
                .agents(page: currentPage, pageSize: pageSize, status: statusParam)
            )
            
            self.agents = response.items
            
            // ✅ 添加调试信息
            print("📊 当前用户ID: \(currentUserId)")
            print("📊 返回代理总数: \(response.items.count)")
            print("📊 代理列表:")
            for agent in response.items {
                print("  - \(agent.username) (ID: \(agent.id), Parent: \(agent.parentId ?? "nil"))")
            }
            
            // 构建树
            self.agentTree = response.items.buildTree(rootParentId: currentUserId)
            
            print("📊 树形结构根节点数: \(self.agentTree.count)")
            for node in self.agentTree {
                print("  - 根节点: \(node.agent.username), 子节点数: \(node.children.count)")
            }
            
            self.totalPages = (response.total + pageSize - 1) / pageSize
            
        } catch {
            print("❌ 加载代理列表失败: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - 加载待审批列表
    func loadPendingAgents() async {
        do {
            let response: PaginatedResponse<AgentSummary> = try await APIClient.shared.get(
                .pendingAgents(page: 1, pageSize: 100)
            )
            
            self.pendingAgents = response.items
            
        } catch {
            print("❌ 加载待审批列表失败: \(error)")
        }
    }
    
    // MARK: - 审批代理
    func approveAgent(_ agent: AgentSummary, approved: Bool) async throws {
        struct ApproveResponse: Codable {
            let message: String
        }
        
        let _: ApproveResponse = try await APIClient.shared.post(
            .approveAgent(agentId: agent.id, approved: approved, remark: nil)
        )
        
        // 刷新列表
        await loadPendingAgents()
        await loadAgents()
    }
    
    // MARK: - 刷新
    func refresh() async {
        currentPage = 1
        await loadAgents()
        await loadPendingAgents()
    }
    
    // MARK: - 加载更多
    func loadMore() async {
        guard currentPage < totalPages else { return }
        currentPage += 1
        await loadAgents()
    }
    
    // MARK: - 切换状态
    func changeStatus(_ status: AgentStatus) async {
        selectedStatus = status
        currentPage = 1
        await loadAgents(status: status)
    }
}
