//
//  EndUserListView.swift
//  ESale
//
//  终端用户列表
//

import SwiftUI

struct EndUserListView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    @State private var searchText = ""
    
    var filteredUsers: [AgentSummary] {
        if searchText.isEmpty {
            return viewModel.activeEndUsers
        }
        return viewModel.activeEndUsers.filter {
            $0.username.localizedCaseInsensitiveContains(searchText) ||
            ($0.mobile?.contains(searchText) ?? false)
        }
    }
    
    var body: some View {
        List {
            if viewModel.isLoadingActiveUsers && viewModel.activeEndUsers.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else if filteredUsers.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "暂无用户" : "未找到用户",
                    systemImage: searchText.isEmpty ? "person.crop.circle.badge.questionmark" : "magnifyingglass",
                    description: Text(searchText.isEmpty ? "您还没有激活任何终端用户" : "尝试其他搜索关键词")
                )
            } else {
                ForEach(filteredUsers) { user in
                    NavigationLink(destination: EndUserDetailView(user: user, viewModel: viewModel)) {
                        EndUserRowView(user: user)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜索用户名或手机号")
        .navigationTitle("用户列表")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.loadActiveEndUsers()
        }
        .onAppear {
            Task {
                await viewModel.loadActiveEndUsers()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(viewModel.activeEndUserCount) 人")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - 用户行视图
struct EndUserRowView: View {
    let user: AgentSummary
    
    var body: some View {
        HStack(spacing: 12) {
            // 头像
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(user.username.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.green)
                )
            
            // 用户信息
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(user.username)
                        .font(.headline)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                // 套餐信息
                if let productName = user.productName, let planName = user.planName {
                    Text("\(productName) · \(planName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // 手机号
                if let mobile = user.mobile, !mobile.isEmpty {
                    Text(mobile)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        EndUserListView(viewModel: AuthorizationViewModel())
    }
}
