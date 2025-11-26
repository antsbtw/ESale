//
//  AgentDetailView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct AgentDetailView: View {
    let agentId: String
    @StateObject private var viewModel = AgentDetailViewModel()
    @State private var showingApprovalAlert: Bool = false
    @State private var approvalAction: Bool = true
    @State private var showingEditSheet: Bool = false
    @State private var showingDisableAlert: Bool = false
    @State private var showingEnableAlert: Bool = false
    
    var body: some View {
        contentView
            .background(Color(.systemGroupedBackground))
            .navigationTitle("代理详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .task { await viewModel.loadAgentDetail(agentId: agentId) }
            .sheet(isPresented: $showingEditSheet) { editSheet }
            .alert("审批确认", isPresented: $showingApprovalAlert) { approvalAlert } message: { approvalMessage }
            .alert("禁用代理", isPresented: $showingDisableAlert) { disableAlert } message: { disableMessage }
            .alert("启用代理", isPresented: $showingEnableAlert) { enableAlert } message: { enableMessage }
    }
    
    // MARK: - Main Content
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let agent = viewModel.agent {
                    agentContent(agent)
                } else if viewModel.isLoading {
                    loadingView
                } else {
                    errorView
                }
            }
            .padding()
        }
    }
    
    private func agentContent(_ agent: AgentSummary) -> some View {
        Group {
            agentHeaderCard(agent)
            statsSection(agent)
            if !viewModel.children.isEmpty {
                childrenSection
            }
            if agent.status == 2 {
                approvalSection(agent)
            }
        }
    }
    
    private func approvalSection(_ agent: AgentSummary) -> some View {
        Group {
            if let parentId = agent.parentId, parentId == viewModel.currentUserId {
                approvalButtonsView
            } else {
                waitingForApprovalView
            }
        }
    }
    
    private var loadingView: some View {
        ProgressView().padding(.top, 100)
    }
    
    private var errorView: some View {
        Text("加载失败")
            .foregroundStyle(.secondary)
            .padding(.top, 100)
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if let agent = viewModel.agent {
                Menu {
                    menuContent(agent)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    @ViewBuilder
    private func menuContent(_ agent: AgentSummary) -> some View {
        if agent.status == 1 {
            Button { showingEditSheet = true } label: {
                Label("编辑信息", systemImage: "pencil")
            }
            Button(role: .destructive) { showingDisableAlert = true } label: {
                Label("禁用代理", systemImage: "xmark.circle")
            }
        } else if agent.status == 0 {
            Button { showingEnableAlert = true } label: {
                Label("启用代理", systemImage: "checkmark.circle")
            }
        }
    }
    
    // MARK: - Sheets & Alerts
    @ViewBuilder
    private var editSheet: some View {
        if let agent = viewModel.agent {
            EditAgentView(isPresented: $showingEditSheet, agent: agent, viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    private var approvalAlert: some View {
        Button("取消", role: .cancel) { }
        Button(approvalAction ? "通过" : "拒绝", role: approvalAction ? .none : .destructive) {
            Task { await performApproval() }
        }
    }
    
    private var approvalMessage: some View {
        Text(approvalAction ? "确认通过该代理申请？" : "确认拒绝该代理申请？")
    }
    
    @ViewBuilder
    private var disableAlert: some View {
        Button("取消", role: .cancel) { }
        Button("确认禁用", role: .destructive) {
            Task { await disableAgent() }
        }
    }
    
    private var disableMessage: some View {
        Text("确认要禁用该代理吗？禁用后该代理将无法登录。")
    }
    
    @ViewBuilder
    private var enableAlert: some View {
        Button("取消", role: .cancel) { }
        Button("确认启用") {
            Task { await enableAgent() }
        }
    }
    
    private var enableMessage: some View {
        Text("确认要启用该代理吗？启用后该代理可以正常登录。")
    }
    
    // MARK: - 头部信息卡片
    private func agentHeaderCard(_ agent: AgentSummary) -> some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(agent.username.prefix(1).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                )
            
            VStack(spacing: 4) {
                Text(agent.username)
                    .font(.title2.weight(.bold))
                
                if let level = agent.agentLevel {
                    Text("代理商 Lv\(level)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            statusBadge(agent.status)
            
            VStack(spacing: 8) {
                if let mobile = agent.mobile, !mobile.isEmpty {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundStyle(.blue)
                        Text(mobile)
                    }
                    .font(.subheadline)
                }
                
                if let email = agent.email, !email.isEmpty {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.blue)
                        Text(email)
                    }
                    .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
    
    // MARK: - 统计信息
    private func statsSection(_ agent: AgentSummary) -> some View {
        HStack(spacing: 16) {
            statBox(title: "下级代理", value: "\(agent.childCount ?? 0)")
            statBox(title: "注册时间", value: formatDate(agent.createdAt))
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8)
    }
    
    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.blue)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - 下级列表
    private var childrenSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("下级代理 (\(viewModel.children.count))")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(viewModel.children) { child in
                    NavigationLink(destination: AgentDetailView(agentId: child.id)) {
                        AgentRowView(agent: child)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    
                    if child.id != viewModel.children.last?.id {
                        Divider()
                            .padding(.leading, 70)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 8)
        }
    }
    
    // MARK: - 审批相关视图
    private var approvalButtonsView: some View {
        HStack(spacing: 16) {
            Button {
                approvalAction = false
                showingApprovalAlert = true
            } label: {
                Text("拒绝")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .cornerRadius(12)
            }
            
            Button {
                approvalAction = true
                showingApprovalAlert = true
            } label: {
                Text("通过")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }

    private var waitingForApprovalView: some View {
        VStack(spacing: 8) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 40))
                .foregroundStyle(.orange)
            Text("此代理正在等待上级审批")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Helper
    private func statusBadge(_ status: Int) -> some View {
        Group {
            switch status {
            case 0:
                Label("已禁用", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.gray)
            case 1:
                Label("正常", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case 2:
                Label("待审批", systemImage: "clock.fill")
                    .foregroundStyle(.orange)
            case 3:
                Label("已拒绝", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
            default:
                EmptyView()
            }
        }
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MM-dd"
        return displayFormatter.string(from: date)
    }
    
    private func performApproval() async {
        guard let agent = viewModel.agent else { return }
        
        do {
            struct ApproveResponse: Codable {
                let message: String
            }
            
            let _: ApproveResponse = try await APIClient.shared.post(
                .approveAgent(agentId: agent.id, approved: approvalAction, remark: nil)
            )
            
            await viewModel.loadAgentDetail(agentId: agentId)
            
        } catch {
            print("❌ 审批失败: \(error)")
        }
    }
    
    private func disableAgent() async {
        guard let agent = viewModel.agent else { return }
        
        do {
            struct UpdateStatusResponse: Codable {
                let message: String
            }
            
            let _: UpdateStatusResponse = try await APIClient.shared.request(
                .updateAgentStatus(agentId: agent.id, status: 0),
                responseType: UpdateStatusResponse.self
            )
            
            await viewModel.loadAgentDetail(agentId: agentId)
            
        } catch {
            print("❌ 禁用失败: \(error)")
        }
    }
    
    private func enableAgent() async {
        guard let agent = viewModel.agent else { return }
        
        do {
            struct UpdateStatusResponse: Codable {
                let message: String
            }
            
            let _: UpdateStatusResponse = try await APIClient.shared.request(
                .updateAgentStatus(agentId: agent.id, status: 1),
                responseType: UpdateStatusResponse.self
            )
            
            await viewModel.loadAgentDetail(agentId: agentId)
            
        } catch {
            print("❌ 启用失败: \(error)")
        }
    }
}

// MARK: - ViewModel
@MainActor
class AgentDetailViewModel: ObservableObject {
    @Published var agent: AgentSummary?
    @Published var children: [AgentSummary] = []
    @Published var isLoading = false
    @Published var currentUserId: String = ""
    
    init() {
        Task {
            await loadCurrentUser()
        }
    }
    
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
    
    func loadAgentDetail(agentId: String) async {
        isLoading = true
        
        do {
            self.agent = try await APIClient.shared.get(.agentDetail(id: agentId))
            
            let response: PaginatedResponse<AgentSummary> = try await APIClient.shared.get(
                .agents(page: 1, pageSize: 100, status: nil)
            )
            
            self.children = response.items.filter { child in
                child.parentId == agentId
            }
            
        } catch {
            print("❌ 加载代理详情失败: \(error)")
        }
        
        isLoading = false
    }
}
