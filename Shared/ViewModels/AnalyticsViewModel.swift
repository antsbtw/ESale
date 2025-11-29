//
//  AnalyticsOverview.swift
//  ESale
//
//  Created by wenwu on 11/28/25.
//


import Foundation

// MARK: - 数据模型

struct AnalyticsOverview: Codable {
    let newAgents: Int
    let newEndUsers: Int
    let totalAgents: Int
    let totalEndUsers: Int
    let period: String
    let activationRate: Double?
}

struct DailyTrendItem: Codable, Identifiable {
    let date: String
    let agents: Int
    let endUsers: Int
    
    var id: String { date }
}

struct TrendResponse: Codable {
    let days: Int
    let data: [DailyTrendItem]
}

struct RankingItem: Codable, Identifiable {
    let agentId: String
    let username: String
    let endUserCount: Int
    let agentCount: Int
    
    var id: String { agentId }
}

struct RankingResponse: Codable {
    let ranking: [RankingItem]
}

struct QuotaUsageItem: Codable, Identifiable {
    let productId: String
    let productName: String
    let quotaTotal: Int
    let quotaUsed: Int
    let quotaRemain: Int
    let usageRate: Double
    
    var id: String { productId }
}

struct QuotaUsageResponse: Codable {
    let quotas: [QuotaUsageItem]
}

// MARK: - ViewModel

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var overview: AnalyticsOverview?
    @Published var trendData: [DailyTrendItem] = []
    @Published var ranking: [RankingItem] = []
    @Published var quotaUsage: [QuotaUsageItem] = []
    
    @Published var selectedPeriod: String = "month"
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    // MARK: - 加载所有数据
    func loadAll() async {
        isLoading = true
        errorMessage = nil
        
        async let overview: () = loadOverview()
        async let trend: () = loadTrend()
        async let ranking: () = loadRanking()
        async let quota: () = loadQuotaUsage()
        
        await overview
        await trend
        await ranking
        await quota
        
        isLoading = false
    }
    
    // MARK: - 统计概览
    func loadOverview() async {
        do {
            let response: AnalyticsOverview = try await apiClient.get(.analyticsOverview(period: selectedPeriod))
            self.overview = response
            print("📊 概览数据加载成功")
        } catch {
            print("❌ 加载概览失败: \(error)")
            errorMessage = "加载统计数据失败"
        }
    }
    
    // MARK: - 趋势数据
    func loadTrend() async {
        do {
            let response: TrendResponse = try await apiClient.get(.analyticsTrend)
            self.trendData = response.data
            print("📈 趋势数据加载成功: \(response.data.count) 条")
        } catch {
            print("❌ 加载趋势失败: \(error)")
        }
    }
    
    // MARK: - 团队排行
    func loadRanking() async {
        do {
            let response: RankingResponse = try await apiClient.get(.analyticsTeamRanking)
            self.ranking = response.ranking
            print("🏆 排行数据加载成功: \(response.ranking.count) 条")
        } catch {
            print("❌ 加载排行失败: \(error)")
        }
    }
    
    // MARK: - 配额使用
    func loadQuotaUsage() async {
        do {
            let response: QuotaUsageResponse = try await apiClient.get(.analyticsQuotaUsage)
            self.quotaUsage = response.quotas
            print("📦 配额数据加载成功: \(response.quotas.count) 条")
        } catch {
            print("❌ 加载配额失败: \(error)")
        }
    }
    
    // MARK: - 切换时间周期
    func changePeriod(_ period: String) async {
        selectedPeriod = period
        await loadOverview()
    }
    
    // MARK: - 刷新
    func refresh() async {
        await loadAll()
    }
}