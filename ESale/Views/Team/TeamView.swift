//
//  TeamView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct TeamView: View {
    @StateObject private var viewModel = AgentListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 状态筛选标签
                statusFilterBar
                
                // 代理列表
                if viewModel.isLoading && viewModel.agentTree.isEmpty && viewModel.pendingAgents.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.selectedStatus == .pending && viewModel.pendingAgents.isEmpty {
                    emptyView
                } else if viewModel.selectedStatus != .pending && viewModel.agentTree.isEmpty {
                    emptyView
                } else {
                    agentList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("团队管理")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadAgents()
                await viewModel.loadPendingAgents()
            }
        }
        .badge(viewModel.pendingAgents.count)
    }
    
    // MARK: - 状态筛选栏
    private var statusFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AgentListViewModel.AgentStatus.allCases, id: \.self) { status in
                    statusFilterButton(status)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    private func statusFilterButton(_ status: AgentListViewModel.AgentStatus) -> some View {
        Button {
            Task {
                await viewModel.changeStatus(status)
            }
        } label: {
            HStack(spacing: 4) {
                Text(status.title)
                    .font(.subheadline.weight(.medium))
                
                if status == .pending && !viewModel.pendingAgents.isEmpty {
                    Text("\(viewModel.pendingAgents.count)")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(viewModel.selectedStatus == status ? Color.blue : Color(.systemGray6))
            .foregroundStyle(viewModel.selectedStatus == status ? .white : .primary)
            .cornerRadius(20)
        }
    }
    
    // MARK: - 代理列表
    private var agentList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if viewModel.selectedStatus == .pending {
                    // 待审批：显示平铺列表
                    ForEach(viewModel.pendingAgents) { agent in
                        NavigationLink(destination: AgentDetailView(agentId: agent.id)) {
                            AgentRowView(agent: agent)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if agent.id != viewModel.pendingAgents.last?.id {
                            Divider()
                                .padding(.leading, 70)
                        }
                    }
                } else {
                    // 其他状态：显示树形列表
                    ForEach(viewModel.agentTree) { node in
                        NavigationLink(destination: AgentDetailView(agentId: node.agent.id)) {
                            AgentTreeRowView(node: node, depth: 0)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if node.id != viewModel.agentTree.last?.id {
                            Divider()
                                .padding(.leading, 70)
                        }
                    }
                }
                
                // 加载更多（待审批状态不需要分页）
                if viewModel.selectedStatus != .pending && viewModel.currentPage < viewModel.totalPages {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                    .onAppear {
                        Task {
                            await viewModel.loadMore()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 空状态
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("暂无代理")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TeamView()
}
