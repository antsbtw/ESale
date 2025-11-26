//
//  AppConfig.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import Foundation
import SwiftUICore

enum AppConfig {
    // ✅ 关键：确保baseURL正确
    static let baseURL = "https://saasapi.situstechnologies.com"
    
    // Keychain配置
    static let keychainService = "com.esale.auth"
    static let accessTokenKey = "accessToken"
    static let refreshTokenKey = "refreshToken"
    
    // 用户信息Key
    static let currentUserKey = "currentUser"
}

// MARK: - Environment切换
enum AppEnvironment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://dev.saasapi.situstechnologies.com/api/v1"
        case .staging:
            return "https://staging.saasapi.situstechnologies.com/api/v1"
        case .production:
            return "https://saasapi.situstechnologies.com/api/v1"
        }
    }
}

// 当前环境
extension AppConfig {
    static var currentEnvironment: AppEnvironment = .production
    static var apiBaseURL: String {
        currentEnvironment.baseURL
    }
}
