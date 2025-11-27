//
//  User.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    let username: String
    let mobile: String?
    let email: String?
    let role: UserRole
    let agentLevel: Int?
    let parentId: String?
    let status: Int
    let createdAt: String
    let updatedAt: String
    
    var displayName: String {
        username
    }
    
    var roleDisplayName: String {
        switch role {
        case .admin:
            return "管理员"
        case .agent:
            return "代理商 Lv\(agentLevel ?? 0)"
        case .enduser:
            return "最终用户"
        }
    }
}

// MARK: - User Role
enum UserRole: String, Codable {
    case admin
    case agent
    case enduser
}

// MARK: - Agent Summary
struct AgentSummary: Codable, Identifiable {
    let id: String
    let username: String
    let mobile: String?
    let email: String?
    let role: String?
    let agentLevel: Int?
    let parentId: String?
    var childCount: Int?
    let status: Int
    let createdAt: String
    
    // 终端用户激活相关（新增）
    let requestedPlanId: String?
    let planName: String?
    let productName: String?
    
    var displayLevel: String {
        if let level = agentLevel {
            return "Lv\(level)"
        }
        return "Lv0"
    }
    
    var isEndUser: Bool {
        return role == "enduser"
    }
    
    var roleText: String {
        switch role {
        case "admin": return "管理员"
        case "agent": return "代理"
        case "enduser": return "终端用户"
        default: return role ?? "未知"
        }
    }
    
    var statusText: String {
        switch status {
        case 0: return "已禁用"
        case 1: return "正常"
        case 2: return "待审批"
        case 3: return "已拒绝"
        default: return "未知"
        }
    }
}

// MARK: - Login Response
struct LoginResponse: Codable {
    let token: String
    let user: LoginUser
}

// MARK: - Login User (简化版)
struct LoginUser: Codable {
    let id: String
    let username: String
    let role: String
    let parentId: String? 
}
