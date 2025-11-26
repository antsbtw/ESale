//
//  AgentQuota.swift
//  ESale
//
//  代理授权配额模型
//

import Foundation

// MARK: - 配额汇总（用于Dashboard）
struct QuotaSummary: Codable {
    let totalQuota: Int
    let totalUsed: Int
    let totalRemaining: Int
    let products: [String: ProductQuotaInfo]
    
    enum CodingKeys: String, CodingKey {
        case totalQuota
        case totalUsed
        case totalRemaining
        case products
    }
}

struct ProductQuotaInfo: Codable {
    let productId: String
    let productCode: String
    let total: Int
    let used: Int
    let remaining: Int
    
    enum CodingKeys: String, CodingKey {
        case productId
        case productCode
        case total
        case used
        case remaining
    }
}

// MARK: - 配额详情（单个产品）
struct AgentQuota: Codable, Identifiable {
    let id: String
    let subscriptionId: String
    let productId: String
    let productName: String
    let productCode: String
    let quotaTotal: Int
    let quotaUsed: Int
    let remaining: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case subscriptionId
        case productId
        case productName
        case productCode
        case quotaTotal
        case quotaUsed
        case remaining
        case createdAt
        case updatedAt
    }
    
    // 计算使用百分比
    var usagePercentage: Double {
        guard quotaTotal > 0 else { return 0 }
        return Double(quotaUsed) / Double(quotaTotal)
    }
    
    // 是否配额不足（剩余少于10%）
    var isLowStock: Bool {
        return remaining < quotaTotal / 10
    }
    
    // 配额状态描述
    var statusText: String {
        if remaining == 0 {
            return "已用完"
        } else if isLowStock {
            return "库存不足"
        } else {
            return "正常"
        }
    }
}

// MARK: - API Response
struct QuotaListResponse: Codable {
    let quotas: [AgentQuota]
}
