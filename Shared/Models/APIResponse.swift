//
//  APIResponse.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import Foundation

// MARK: - 通用API响应
struct APIResponse<T: Codable>: Codable {
    let code: String?
    let message: String?
    let data: T?
    
    var isSuccess: Bool {
        code == nil || code == "200" || code == "0"
    }
}

// MARK: - 错误响应
struct ErrorResponse: Codable {
    let code: String?
    let message: String?
    let error: String?  // ✅ 添加这个字段
    let details: [String: String]?
    
    // ✅ 添加计算属性，优先使用 error，其次 message
    var displayMessage: String {
        return error ?? message ?? "未知错误"
    }
}

// 分页响应 - 支持 items 为 null 的情况
struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]
    let total: Int
    let page: Int
    let pageSize: Int
    
    // 自定义解码，处理 items 为 null
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 如果 items 是 null，使用空数组
        self.items = (try? container.decode([T].self, forKey: .items)) ?? []
        self.total = try container.decode(Int.self, forKey: .total)
        self.page = try container.decode(Int.self, forKey: .page)
        self.pageSize = try container.decode(Int.self, forKey: .pageSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
        try container.encode(total, forKey: .total)
        try container.encode(page, forKey: .page)
        try container.encode(pageSize, forKey: .pageSize)
    }
    
    private enum CodingKeys: String, CodingKey {
        case items, total, page, pageSize
    }
}

// MARK: - 通用成功响应（用于 POST/PUT/DELETE 操作）
struct SuccessResponse: Codable {
    let status: String?
    let id: String?
    let message: String?
    
    // 允许所有字段为空
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        status = try? container?.decode(String.self, forKey: .status)
        id = try? container?.decode(String.self, forKey: .id)
        message = try? container?.decode(String.self, forKey: .message)
    }
    
    enum CodingKeys: String, CodingKey {
        case status, id, message
    }
}
