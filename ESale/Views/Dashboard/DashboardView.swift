//
//  DashboardView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @EnvironmentObject var authService: AuthService
    @Binding var selectedTab: Int
    
    @State private var showingQRCodes = false
    @State private var showingPurchaseApproval = false
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 用户头部
                userHeader
                
                if viewModel.isLoading && viewModel.stats == nil {
                    // 首次加载骨架屏
                    loadingSkeletons
                } else if let stats = viewModel.stats {
                    // 数据内容
                    statsSection(stats)
                    quickActionsSection
                } else {
                    // 错误状态
                    errorView
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.refresh()
        }
        // 在 .onAppear 后面添加
        .onAppear {
            Task {
                await viewModel.loadDashboard()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .purchaseDataChanged)) { _ in
            Task {
                await viewModel.loadDashboard()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .endUserDataChanged)) { _ in
            Task {
                await viewModel.loadDashboard()
            }
        }
        .sheet(isPresented: $showingQRCodes) {
            NavigationContainer {
                MyQRCodesView()
            }
        }
        .sheet(isPresented: $showingPurchaseApproval) {
            NavigationContainer {
                PurchaseApprovalView()
            }
        }
        .alert("提示", isPresented: $viewModel.showError) {
            Button("确定") {
                viewModel.showError = false
            }
            Button("重试") {
                Task {
                    await viewModel.loadDashboard()
                }
            }
        } message: {
            Text(viewModel.errorMessage ?? "未知错误")
        }
        .adaptiveMaxWidth(900)
    }
    
    // MARK: - 用户头部
    private var userHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.title2.weight(.bold))
                
                if let user = authService.currentUser {
                    Text(user.username)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 头像
                Circle()
                    .fill(Color.blue.compatGradient)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(authService.currentUser?.username.prefix(1).uppercased() ?? "U")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<6:
            return "深夜好"
        case 6..<12:
            return "早上好"
        case 12..<18:
            return "下午好"
        default:
            return "晚上好"
        }
    }
    
    // MARK: - 统计数据
    private func statsSection(_ stats: DashboardStats) -> some View {
        VStack(spacing: 16) {
            // 团队数据
            HStack(spacing: 12) {
                StatCard(
                    title: "下级代理",
                    value: "\(stats.childAgentCount)",
                    subtitle: "本月新增 +\(stats.monthNewAgents)",
                    icon: "person.3.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "最终用户",
                    value: "\(stats.endUserCount)",
                    subtitle: "本月新增 +\(stats.monthNewUsers)",
                    icon: "person.fill",
                    color: .green
                )
            }
            
            // 今日新增
            HStack(spacing: 12) {
                StatCard(
                    title: "今日新增",
                    value: "\(stats.todayNewUsers)",
                    subtitle: "用户数",
                    icon: "calendar",
                    color: .orange
                )
                
                StatCard(
                    title: "预估收入",
                    value: "¥" + formatNumber(Int(stats.estimatedRevenue)),
                    subtitle: "本月 \(stats.monthLicenseCount) 个授权",
                    icon: "yensign.circle.fill",
                    color: .purple
                )
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: 12) {
            Text("快捷操作")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    icon: "checkmark.circle.fill",
                    title: "审批授权",
                    subtitle: "待处理 \(viewModel.pendingEndUserCount) 项",
                    color: .blue,
                    action: {
                        selectedTab = 2
                    }
                )
                
                // 新增：采购审批
                QuickActionButton(
                    icon: "doc.text.magnifyingglass",
                    title: "采购审批",
                    subtitle: "待处理 \(viewModel.pendingPurchaseCount) 项",
                    color: .purple,
                    action: {
                        showingPurchaseApproval = true
                    }
                )
                
                QuickActionButton(
                    icon: "qrcode",
                    title: "扫码招商",
                    subtitle: "生成专属二维码",
                    color: .green,
                    action: {
                        showingQRCodes = true
                    }
                )
                
                QuickActionButton(
                    icon: "chart.bar.fill",
                    title: "数据分析",
                    subtitle: "查看团队业绩",
                    color: .orange,
                    action: {
                        // TODO: 跳转到数据页面
                    }
                )
            }
        }
    }
    
    // MARK: - 快捷操作
    struct QuickActionButton: View {
        let icon: String
        let title: String
        let subtitle: String
        let color: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                        .frame(width: 50, height: 50)
                        .background(color.opacity(0.1))
                        .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - 加载骨架屏
    private var loadingSkeletons: some View {
        VStack(spacing: 16) {
            // 统计卡片骨架
            HStack(spacing: 12) {
                ForEach(0..<2) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                }
            }
            
            HStack(spacing: 12) {
                ForEach(0..<2) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                }
            }
            
            // 快捷操作骨架
            VStack(spacing: 12) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 80)
                }
            }
        }
    }
    
    // MARK: - 错误视图
    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text(viewModel.errorMessage ?? "加载失败")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Button("重试") {
                Task {
                    await viewModel.loadDashboard()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Helper
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
        .environmentObject(AuthService.shared)
}
