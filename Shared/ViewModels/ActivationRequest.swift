//
//  ActivationRequest.swift
//  ESale
//
//  用户激活请求模型（简化的订单概念）
//

import Foundation

// MARK: - 激活请求（基于 payment_session）
struct ActivationRequest: Codable, Identifiable {
    let id: String
    let agentId: String
    let endUserId: String?
    let packageId: String?
    let productId: String?
    let productPlanId: String?
    let paymentMethod: String?
    let amountDisplay: Double?
    let proofImageUrl: String?
    let status: String
    let createdAt: String
    let updatedAt: String
    
    // 状态显示
    var statusText: String {
        switch status {
        case "pending": return "待处理"
        case "paid": return "已确认"
        case "rejected": return "已拒绝"
        default: return "未知状态"
        }
    }
    
    // 金额显示
    var amountText: String {
        if let amount = amountDisplay {
            return String(format: "¥%.2f", amount)
        }
        return "¥0.00"
    }
    
    // 时间显示（相对时间）
    var timeAgo: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else {
            return createdAt
        }
        
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)分钟前"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)小时前"
        } else {
            let days = Int(interval / 86400)
            return "\(days)天前"
        }
    }
    
    // 请求类型
    var requestType: String {
        if packageId != nil {
            return "套餐采购"
        } else if productId != nil {
            return "产品激活"
        }
        return "未知类型"
    }
}

// MARK: - API Response
struct ActivationRequestListResponse: Codable {
    let requests: [ActivationRequest]
    let total: Int
    let page: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case requests
        case total
        case page
        case pageSize = "page_size"
    }
}
