//
//  DashboardStats.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import Foundation

// MARK: - Dashboard Statistics
struct DashboardStats: Codable {
    let childAgentCount: Int          // 下级代理数
    let endUserCount: Int             // 最终用户数
    let todayNewUsers: Int            // 今日新增
    let monthNewAgents: Int           // 本月新增代理
    let monthNewUsers: Int            // 本月新增用户
    let monthLicenseCount: Int        // 本月出货授权数
    let estimatedRevenue: Double      // 预估收入
    let averagePrice: Double          // 平均单价
    
    // 计算属性
    var totalTeamSize: Int {
        childAgentCount + endUserCount
    }
}

// MARK: - Pending Item (待处理事项)
struct PendingItem: Identifiable, Codable {
    let id: String
    let type: PendingType
    let applicantName: String
    let applicantId: String
    let details: String
    let createdAt: String
    let metadata: [String: String]?
    
    var timeAgo: String {
        // TODO: 实现时间格式化
        return "2小时前"
    }
}

enum PendingType: String, Codable {
    case agentApplication = "agent_application"      // 代理申请
    case licenseRequest = "license_request"          // 授权申请
    case quotaRequest = "quota_request"              // 额度申请
}