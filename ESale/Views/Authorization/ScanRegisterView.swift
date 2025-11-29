//
//  ScanRegisterView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct ScanRegisterView: View {
    let code: String
    @Binding var isPresented: Bool  // ✅ 改用 Binding
    
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var mobile = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // ✅ 添加 init 调试
    init(code: String, isPresented: Binding<Bool>) {
        self.code = code
        self._isPresented = isPresented
        print("🎨 ScanRegisterView init - code: \(code)")
    }
    
    var body: some View {
        print("🖼️ ScanRegisterView body 渲染")
        return NavigationContainer {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    Text("加入团队")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                        .onAppear {
                            print("✅ Text '加入团队' 显示了")
                        }
                    
                    Text("邀请码：\(code)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // 表单
                    VStack(spacing: 15) {
                        TextField("用户名", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                        
                        TextField("手机号", text: $mobile)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.phonePad)
                        
                        SecureField("密码", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("确认密码", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    
                    // 错误提示
                    if let error = errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                    
                    // 提交按钮
                    Button {
                        Task { await register() }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("提交申请")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isLoading || !isFormValid)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false  // ✅ 改用 Binding
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        !mobile.isEmpty
    }
    
    private func register() async {
        isLoading = true
        errorMessage = nil
        
        print("📝 准备注册: code=\(code), username=\(username)")
        
        do {
            let endpoint = APIEndpoint.registerViaQRCode(
                code: code,
                username: username,
                password: password,
                mobile: mobile,
                email: nil  // 如果需要邮箱，可以添加邮箱输入框
            )
            
            let response: RegisterResponse = try await APIClient.shared.post(endpoint)
            
            print("✅ 注册成功: \(response.message ?? "成功")")
            
            isLoading = false
            
            // 提示用户等待审批
            errorMessage = "注册成功！请等待上级审批"
            
            // 延迟关闭
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isPresented = false
            
        } catch {
            print("❌ 注册失败: \(error)")
            errorMessage = "注册失败：\(error.localizedDescription)"
            isLoading = false
        }
    }
    
}

#Preview {
    ScanRegisterView(code: "test-code-123", isPresented: .constant(true))
}

// MARK: - API Response
struct RegisterResponse: Codable {
    let token: String?
    let message: String?
    let user: UserInfo?
    
    struct UserInfo: Codable {
        let id: String
        let username: String
        let role: String
        let parentId: String?
    }
}
