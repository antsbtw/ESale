//
//  LoginView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationContainer {
            VStack(spacing: 30) {
                // Logo区域
                VStack(spacing: 16) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.blue.compatGradient)
                    
                    Text("ESale 销售管理")
                        .font(.title.bold())
                    
                    Text("多级代理销售平台")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
                
                // 登录表单
                VStack(spacing: 20) {
                    // 用户名
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(.blue)
                            .frame(width: 30)
                        
                        TextField("用户名 / 手机号 / 邮箱", text: $username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 密码
                    HStack {
                        Image(systemName: "lock.circle.fill")
                            .foregroundStyle(.blue)
                            .frame(width: 30)
                        
                        SecureField("密码", text: $password)
                            .textContentType(.password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 登录按钮
                    Button(action: handleLogin) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("登录")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(loginButtonBackground)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                    .disabled(isLoginDisabled)
                  /*
                    // 在登录按钮下方添加：
                    #if DEBUG
                    Button("使用测试数据登录") {
                        authService.loginWithMockData()
                    }
                    .font(.caption)
                    .padding(.top, 8)
                    #endif
                   */
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // 底部提示
                VStack(spacing: 8) {
                    Text("首次使用？请联系上级代理")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Text("v1.0.0")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.bottom, 32)
            }
            .alert("登录失败", isPresented: $showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
        .adaptiveMaxWidth(520)
    }
    
    // MARK: - Computed Properties
    private var isLoginDisabled: Bool {
        username.isEmpty || password.isEmpty || isLoading
    }
    
    private var loginButtonBackground: some ShapeStyle {
        isLoginDisabled ? AnyShapeStyle(.gray) : AnyShapeStyle(Color.blue.compatGradient)
    }
    
    // MARK: - Actions
    private func handleLogin() {
        isLoading = true
        
        Task {
            do {
                try await authService.login(username: username, password: password)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isLoading = false
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService.shared)
}
