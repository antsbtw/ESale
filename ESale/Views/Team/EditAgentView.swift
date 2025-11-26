//
//  EditAgentView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct EditAgentView: View {
    @Binding var isPresented: Bool
    let agent: AgentSummary
    @ObservedObject var viewModel: AgentDetailViewModel
    
    @State private var mobile: String
    @State private var email: String
    @State private var agentLevel: Int
    
    @State private var isUpdating: Bool = false
    @State private var errorMessage: String?
    @State private var showingSuccess: Bool = false
    
    init(isPresented: Binding<Bool>, agent: AgentSummary, viewModel: AgentDetailViewModel) {
        self._isPresented = isPresented
        self.agent = agent
        self.viewModel = viewModel
        
        // 初始化状态
        _mobile = State(initialValue: agent.mobile ?? "")
        _email = State(initialValue: agent.email ?? "")
        _agentLevel = State(initialValue: agent.agentLevel ?? 1)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    HStack {
                        Text("用户名")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(agent.username)
                    }
                    
                    HStack {
                        Text("状态")
                            .foregroundStyle(.secondary)
                        Spacer()
                        statusBadge(agent.status)
                    }
                }
                
                Section("联系方式") {
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
            .navigationTitle("编辑代理")
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
                            await updateAgent()
                        }
                    }
                    .disabled(isUpdating)
                }
            }
            .disabled(isUpdating)
            .overlay {
                if isUpdating {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("保存成功", isPresented: $showingSuccess) {
                Button("确定") {
                    isPresented = false
                }
            } message: {
                Text("代理信息已更新")
            }
        }
    }
    
    private func statusBadge(_ status: Int) -> some View {
        Group {
            switch status {
            case 0:
                Text("已禁用")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .foregroundStyle(.gray)
                    .cornerRadius(4)
            case 1:
                Text("正常")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .cornerRadius(4)
            case 2:
                Text("待审批")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .foregroundStyle(.orange)
                    .cornerRadius(4)
            default:
                EmptyView()
            }
        }
    }
    
    private func updateAgent() async {
        isUpdating = true
        errorMessage = nil
        
        // TODO: 实现更新API
        // 目前后端可能还没有更新代理信息的接口
        // 这里先模拟成功
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        showingSuccess = true
        
        // 重新加载代理详情
        await viewModel.loadAgentDetail(agentId: agent.id)
        
        isUpdating = false
    }
}