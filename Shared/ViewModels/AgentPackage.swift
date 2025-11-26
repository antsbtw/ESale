//
//  AgentPackage.swift
//  ESale
//
//  代理套餐模型（批发套餐包）
//

import Foundation

// MARK: - 套餐产品配额
struct PackageProductQuota: Codable, Identifiable {
    let id: String
    let packageId: String
    let productId: String
    let quota: Int
    let createdAt: String
    let updatedAt: String
    
    // 从后端JOIN得到的产品信息（可选）
    let productName: String?
    let productCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case packageId
        case productId
        case quota
        case createdAt
        case updatedAt
        case productName
        case productCode
    }
}

// MARK: - 代理套餐
struct AgentPackage: Codable, Identifiable {
    let id: String
    let name: String              // 套餐名称：基础套餐、专业套餐
    let code: String              // 套餐代码：BASIC、PRO
    let price: Double             // 批发价格（代理向平台采购的价格）
    let durationDays: Int         // 有效期（天数）
    let isActive: Bool            // 是否启用
    let createdAt: String
    let updatedAt: String
    
    // 套餐包含的产品配额列表
    let productQuotas: [PackageProductQuota]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
        case price
        case durationDays
        case isActive
        case createdAt
        case updatedAt
        case productQuotas
    }
    
    // 套餐描述
    var packageDescription: String {
        guard let quotas = productQuotas, !quotas.isEmpty else {
            return "暂无配额信息"
        }
        
        let quotaDescriptions = quotas.compactMap { quota -> String? in
            guard let productName = quota.productName else { return nil }
            return "\(productName) \(quota.quota)个"
        }
        
        return quotaDescriptions.joined(separator: " | ")
    }
    
    // 有效期描述
    var durationText: String {
        if durationDays >= 365 {
            let years = durationDays / 365
            return "\(years)年"
        } else if durationDays >= 30 {
            let months = durationDays / 30
            return "\(months)个月"
        } else {
            return "\(durationDays)天"
        }
    }
    
    // 价格显示
    var priceText: String {
        return String(format: "¥%.2f", price)
    }
}

// MARK: - API Response
struct AgentPackageListResponse: Codable {
    let packages: [AgentPackage]
}

struct AgentPackageDetailResponse: Codable {
    let package: AgentPackage
    let quotas: [PackageProductQuota]
}
