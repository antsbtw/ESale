//
//  ESaleApp.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

@main
struct ESaleApp: App {
    @StateObject private var authService = AuthService.shared
    @State private var registrationCode: String? = nil
    @State private var showRegistration = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    MainTabView()
                        .environmentObject(authService)
                } else {
                    LoginView()
                        .environmentObject(authService)
                }
            }
            .sheet(isPresented: $showRegistration) {
                if let code = registrationCode {
                    ScanRegisterView(code: code, isPresented: $showRegistration)
                        .onAppear {
                            print("🎬 ScanRegisterView 显示了，code: \(code)")
                        }
                } else {
                    Text("错误：没有邀请码")
                        .onAppear {
                            print("❌ registrationCode 是 nil")
                        }
                }
            }
            .onOpenURL { url in
                handleIncomingURL(url)
            }
            .onChange(of: showRegistration) { oldValue, newValue in
                print("🔄 showRegistration 变化: \(oldValue) -> \(newValue)")
            }
            .onChange(of: registrationCode) { oldValue, newValue in
                print("🔄 registrationCode 变化: \(oldValue ?? "nil") -> \(newValue ?? "nil")")
            }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        print("📲 收到 URL: \(url.absoluteString)")
        
        guard url.scheme == "esale",
              url.host == "register" else {
            print("❌ 不是注册 URL")
            return
        }
        
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let code = components.queryItems?.first(where: { $0.name == "code" })?.value {
            print("✅ 获取到 code: \(code)")
            print("⏳ 准备设置状态")
            registrationCode = code
            showRegistration = true
            print("✅ 状态已设置")
        } else {
            print("❌ URL 中没有 code 参数")
        }
    }
}
