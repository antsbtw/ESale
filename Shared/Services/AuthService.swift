//
//  AuthService.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import Foundation

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let _ = KeychainHelper.shared.get(forKey: AppConfig.accessTokenKey) {
            isAuthenticated = true
            Task {
                await fetchCurrentUser()
            }
        }
    }
    
    func login(username: String, password: String) async throws {
        let response: LoginResponse = try await APIClient.shared.post(.login(username: username, password: password))
        
        _ = KeychainHelper.shared.save(response.token, forKey: AppConfig.accessTokenKey)
        
        // 登录成功后获取完整用户信息
        await fetchCurrentUser()
        
        self.isAuthenticated = true
    }
    
    func fetchCurrentUser() async {
        do {
            let user: User = try await APIClient.shared.get(.me)
            self.currentUser = user
        } catch {
            print("❌ 获取用户信息失败: \(error)")
            if case NetworkError.unauthorized = error {
                await logout()
            }
        }
    }
    
    func logout() async {
        KeychainHelper.shared.clearAll()
        self.currentUser = nil
        self.isAuthenticated = false
    }
    
}

