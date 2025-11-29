//
//  AnalyticsView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        NavigationContainer {
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.isLoading && viewModel.overview == nil {
                        ProgressView()
                            .padding(.top, 100)
                    } else {
                        // 时间周期选择
                        periodSelector
                        
                        // 统计概览
                        if let overview = viewModel.overview {
                            overviewSection(overview)
                        }
                        
                        // 趋势图表
                        if !viewModel.trendData.isEmpty {
                            trendSection
                        }
                        
                        // 团队排行
                        if !viewModel.ranking.isEmpty {
                            rankingSection
                        }
                        
                        // 配额使用
                        if !viewModel.quotaUsage.isEmpty {
                            quotaSection
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("数据分析")
            .refreshable {
                await viewModel.refresh()
            }
            .onAppear {
                Task {
                    await viewModel.loadAll()
                }
            }
        }
    }
    
    // MARK: - 时间周期选择
    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(["week", "month", "quarter", "year"], id: \.self) { period in
                    Button {
                        Task {
                            await viewModel.changePeriod(period)
                        }
                    } label: {
                        Text(periodTitle(period))
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedPeriod == period ? Color.blue : Color(.systemGray6))
                            .foregroundStyle(viewModel.selectedPeriod == period ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    private func periodTitle(_ period: String) -> String {
        switch period {
        case "week": return "本周"
        case "month": return "本月"
        case "quarter": return "本季度"
        case "year": return "本年"
        default: return period
        }
    }
    
    // MARK: - 统计概览
    private func overviewSection(_ overview: AnalyticsOverview) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                AnalyticsStatCard(
                    title: "新增代理",
                    value: "\(overview.newAgents)",
                    icon: "person.badge.plus",
                    color: .blue
                )
                
                AnalyticsStatCard(
                    title: "新增用户",
                    value: "\(overview.newEndUsers)",
                    icon: "person.fill.badge.plus",
                    color: .green
                )
            }
            
            HStack(spacing: 12) {
                AnalyticsStatCard(
                    title: "代理总数",
                    value: "\(overview.totalAgents)",
                    icon: "person.3.fill",
                    color: .purple
                )
                
                AnalyticsStatCard(
                    title: "用户总数",
                    value: "\(overview.totalEndUsers)",
                    icon: "person.2.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - 趋势图表
    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📈 增长趋势")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(viewModel.trendData.suffix(7)) { item in
                    HStack {
                        Text(formatDate(item.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)
                        
                        // 代理柱状图
                        HStack(spacing: 4) {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: CGFloat(item.agents) * 20, height: 16)
                                .cornerRadius(4)
                            
                            if item.agents > 0 {
                                Text("\(item.agents)")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                        }
                        
                        Spacer()
                        
                        // 用户柱状图
                        HStack(spacing: 4) {
                            if item.endUsers > 0 {
                                Text("\(item.endUsers)")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                            }
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: CGFloat(item.endUsers) * 10, height: 16)
                                .cornerRadius(4)
                        }
                    }
                }
                
                // 图例
                HStack(spacing: 20) {
                    HStack(spacing: 4) {
                        Circle().fill(Color.blue).frame(width: 8, height: 8)
                        Text("代理").font(.caption).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 8, height: 8)
                        Text("用户").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        // "2025-11-28" -> "11-28"
        let components = dateString.split(separator: "-")
        if components.count >= 3 {
            return "\(components[1])-\(components[2])"
        }
        return dateString
    }
    
    // MARK: - 团队排行
    private var rankingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏆 团队排行")
                .font(.headline)
            
            VStack(spacing: 0) {
                ForEach(Array(viewModel.ranking.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: 12) {
                        // 排名
                        Text("\(index + 1)")
                            .font(.headline)
                            .foregroundStyle(index < 3 ? .orange : .secondary)
                            .frame(width: 30)
                        
                        // 头像
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(item.username.prefix(1).uppercased())
                                    .font(.subheadline.weight(.bold))
                                    .foregroundStyle(.blue)
                            )
                        
                        // 名称
                        Text(item.username)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        // 数据
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(item.endUserCount) 用户")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text("\(item.agentCount) 代理")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    if index < viewModel.ranking.count - 1 {
                        Divider()
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    // MARK: - 配额使用
    private var quotaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📦 配额使用")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(viewModel.quotaUsage) { item in
                    VStack(spacing: 8) {
                        HStack {
                            Text(item.productName)
                                .font(.subheadline.weight(.medium))
                            
                            Spacer()
                            
                            Text("\(item.quotaUsed)/\(item.quotaTotal)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        // 进度条
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(progressColor(item.usageRate))
                                    .frame(width: geometry.size.width * CGFloat(item.usageRate / 100), height: 8)
                            }
                        }
                        .frame(height: 8)
                        
                        HStack {
                            Text("剩余 \(item.quotaRemain)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f%%", item.usageRate))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(progressColor(item.usageRate))
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private func progressColor(_ rate: Double) -> Color {
        if rate >= 80 {
            return .red
        } else if rate >= 50 {
            return .orange
        } else {
            return .green
        }
    }
}

// MARK: - 统计卡片组件
struct AnalyticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(value)
                        .font(.title.weight(.bold))
                    
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    AnalyticsView()
}
