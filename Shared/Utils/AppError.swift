//
//  AppError.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import Foundation

enum AppError: LocalizedError {
    case networkError(String)
    case unauthorized
    case serverError(String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "网络错误：\(message)"
        case .unauthorized:
            return "登录已过期，请重新登录"
        case .serverError(let message):
            return "服务器错误：\(message)"
        case .decodingError:
            return "数据解析失败"
        case .unknown:
            return "未知错误"
        }
    }
    
    var isUnauthorized: Bool {
        if case .unauthorized = self {
            return true
        }
        return false
    }
}

extension NetworkError {
    func toAppError() -> AppError {
        switch self {
        case .unauthorized:
            return .unauthorized
        case .serverError(let message):
            return .serverError(message)
        case .decodingError:
            return .decodingError
        case .networkFailure(let error):
            return .networkError(error.localizedDescription)
        default:
            return .unknown
        }
    }
}