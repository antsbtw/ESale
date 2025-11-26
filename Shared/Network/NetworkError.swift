//
//  NetworkError.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case unauthorized
    case networkFailure(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .noData:
            return "服务器未返回数据"
        case .decodingError(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .serverError(let message):
            return "服务器错误: \(message)"
        case .unauthorized:
            return "未授权，请重新登录"
        case .networkFailure(let error):
            return "网络请求失败: \(error.localizedDescription)"
        case .unknown:
            return "未知错误"
        }
    }
}