//
//  APIClient.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let baseURL: String
    private let session: URLSession
    
    private init() {
        self.baseURL = AppConfig.baseURL
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        print("🌐 APIClient initialized with baseURL: \(baseURL)")
    }
    
    func request<T: Codable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        // 构建URL
        guard var urlComponents = URLComponents(string: baseURL + endpoint.path) else {
            print("❌ Invalid URL: \(baseURL + endpoint.path)")
            throw NetworkError.invalidURL
        }
        
        urlComponents.queryItems = endpoint.queryItems
        
        guard let url = urlComponents.url else {
            print("❌ Failed to construct URL")
            throw NetworkError.invalidURL
        }
        
        // ✅ 关键：使用 endpoint.method
        print("📡 Request: \(endpoint.method) \(url.absoluteString)")
        
        // 构建Request
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method  // ✅ 确保使用 endpoint 的 method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加Token
        if let token = KeychainHelper.shared.get(forKey: AppConfig.accessTokenKey) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Token added: \(token.prefix(20))...")
        }
        
        // ✅ 只在非GET请求时添加Body
        if endpoint.method != "GET", let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            print("📦 Body: \(body)")
        }
        
        // 发送请求
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Invalid response type")
                throw NetworkError.unknown
            }
            
            print("✅ Response: \(httpResponse.statusCode)")
            print("📄 Data: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            // 检查HTTP状态码
            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    print("❌ Server error: \(errorResponse.displayMessage)")
                    throw NetworkError.serverError(errorResponse.displayMessage)  // ✅ 改这里
                }
                print("❌ HTTP \(httpResponse.statusCode)")
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }
            
            // 解析响应
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                print("✅ Decoded successfully")
                return result
            } catch {
                print("❌ Decoding error: \(error)")
                print("📦 Raw data: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            print("❌ Network failure: \(error)")
            throw NetworkError.networkFailure(error)
        }
    }
    
    func get<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        try await request(endpoint, responseType: T.self)
    }
    
    func post<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        try await request(endpoint, responseType: T.self)
    }
    func put<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        try await request(endpoint, responseType: T.self)
    }
    
    func delete<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        try await request(endpoint, responseType: T.self)
    }
}
