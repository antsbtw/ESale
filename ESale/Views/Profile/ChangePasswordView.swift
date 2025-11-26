//
//  ChangePasswordView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct ChangePasswordView: View {
    @Binding var isPresented: Bool  // ✅ 改用 Binding
    
    @State private var oldPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var isChanging: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showError: Bool = false
    @State private var showSuccess: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("原密码", text: $oldPassword)
                } header: {
                    Text("当前密码")
                }
                
                Section {
                    SecureField("新密码", text: $newPassword)
                    SecureField("确认新密码", text: $confirmPassword)
                } header: {
                    Text("新密码")
                } footer: {
                    Text("密码长度至少6位")
                        .font(.caption)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("修改密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await changePassword()
                        }
                    }
                    .disabled(isChanging || !isValid)
                }
            }
            .disabled(isChanging)
            .overlay {
                if isChanging {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("修改成功", isPresented: $showSuccess) {
                Button("确定") {
                    isPresented = false
                }
            } message: {
                Text("密码已成功修改")
            }
        }
    }
    
    private var isValid: Bool {
        !oldPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword
    }
    
    private func changePassword() async {
        isChanging = true
        errorMessage = nil
        
        do {
            struct ChangePasswordResponse: Codable {
                let message: String
            }
            
            let _: ChangePasswordResponse = try await APIClient.shared.post(
                .changePassword(oldPassword: oldPassword, newPassword: newPassword)
            )
            
            showSuccess = true
            
        } catch {
            errorMessage = "修改失败，请重试"
            showError = true
        }
        
        isChanging = false
    }
}

#Preview {
    ChangePasswordView(isPresented: .constant(true))
}
