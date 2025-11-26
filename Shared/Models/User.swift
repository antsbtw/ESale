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
    let agentLevel: Int?
    let parentId: String?
    var childCount: Int?
    let status: Int
    let createdAt: String
    
    var displayLevel: String {
        if let level = agentLevel {
            return "Lv\(level)"
        }
        return "Lv0"
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
}
