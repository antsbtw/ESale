//
//  CreateAgentView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct CreateAgentView: View {
    @Binding var isPresented: Bool  // ✅ 改用 Binding
    @ObservedObject var viewModel: AgentListViewModel
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var mobile: String = ""
    @State private var email: String = ""
    @State private var agentLevel: Int = 1
    
    @State private var isCreating: Bool = false
    @State private var errorMessage: String?
    @State private var showingSuccess: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("用户名", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("密码", text: $password)
                    
                    TextField("手机号", text: $mobile)
                        .keyboardType(.phonePad)
                    
                    TextField("邮箱", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }
                
                Section("代理等级") {
                    Picker("等级", selection: $agentLevel) {
                        ForEach(1...5, id: \.self) { level in
                            Text("Lv\(level)").tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("创建代理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") {
                        Task {
                            await createAgent()
                        }
                    }
                    .disabled(isCreating || !isValid)
                }
            }
            .disabled(isCreating)
            .overlay {
                if isCreating {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("创建成功", isPresented: $showingSuccess) {
                Button("确定") {
                    isPresented = false
                }
            } message: {
                Text("代理 \(username) 创建成功")
            }
        }
    }
    
    private var isValid: Bool {
        !username.isEmpty && !password.isEmpty && !mobile.isEmpty
    }
    
    private func createAgent() async {
        isCreating = true
        errorMessage = nil
        
        do {
            struct CreateAgentResponse: Codable {
                let id: String
                let username: String
                let role: String
            }
            
            let _: CreateAgentResponse = try await APIClient.shared.post(
                .createAgent(
                    username: username,
                    password: password,
                    mobile: mobile,
                    email: email,
                    agentLevel: agentLevel
                )
            )
            
            showingSuccess = true
            
            // 刷新列表
            await viewModel.refresh()
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isCreating = false
    }
}
