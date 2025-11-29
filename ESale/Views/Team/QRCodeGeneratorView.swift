//  QRCodeGeneratorView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGeneratorView: View {
    @EnvironmentObject var authService: AuthService
    @Binding var isPresented: Bool
    
    @State private var qrCodeImage: UIImage?
    @State private var isGenerating: Bool = false
    @State private var shareURL: String = ""
    
    // 试用设置（仅管理员）
    @State private var isTrial: Bool = false
    @State private var trialDays: Int = 7
    @State private var selectedPlanId: String?
    @State private var plans: [ProductPlanItem] = []
    @State private var isLoadingPlans: Bool = false
    
    private var isAdmin: Bool {
        authService.currentUser?.role == .admin
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 管理员试用设置
                    if isAdmin {
                        trialSettingsSection
                    }
                    
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(.top, 40)
                    } else {
                        // 二维码显示
                        if let image = qrCodeImage {
                            qrCodeContent(image: image)
                        } else {
                            generateButton
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("招商二维码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        isPresented = false
                    }
                }
            }
            .onAppear {
                if isAdmin {
                    Task {
                        await loadPlans()
                    }
                }
            }
        }
    }
    
    // MARK: - 试用设置区域（仅管理员）
    private var trialSettingsSection: some View {
        VStack(spacing: 16) {
            // 试用开关
            Toggle(isOn: $isTrial) {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("试用模式")
                            .font(.body)
                        Text("扫码用户自动激活，无需审批")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            if isTrial {
                // 试用天数选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("试用天数")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack {
                        Text("\(trialDays) 天")
                            .font(.title2.bold())
                            .foregroundStyle(.blue)
                        
                        Spacer()
                        
                        Stepper("", value: $trialDays, in: 1...365)
                            .labelsHidden()
                    }
                    
                    // 快捷选择
                    HStack(spacing: 8) {
                        ForEach([7, 14, 30, 90], id: \.self) { days in
                            Button {
                                trialDays = days
                            } label: {
                                Text("\(days)天")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(trialDays == days ? Color.blue : Color(.systemGray5))
                                    .foregroundStyle(trialDays == days ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 套餐选择
                VStack(alignment: .leading, spacing: 8) {
                    Text("试用套餐")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if isLoadingPlans {
                        ProgressView()
                    } else if plans.isEmpty {
                        Text("暂无可用套餐")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("选择套餐", selection: $selectedPlanId) {
                            Text("请选择").tag(nil as String?)
                            ForEach(plans, id: \.id) { plan in
                                Text("\(plan.name) (\(plan.durationDays)天)")
                                    .tag(plan.id as String?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: isTrial)
    }
    
    // MARK: - 二维码内容
    private func qrCodeContent(image: UIImage) -> some View {
        VStack(spacing: 20) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 10)
            
            Text("扫描二维码加入团队")
                .font(.headline)
            
            if isTrial {
                HStack {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(.orange)
                    Text("试用 \(trialDays) 天")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            } else {
                Text("有效期：30天")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // 分享按钮
            Button {
                shareImage(image)
            } label: {
                Label("分享二维码", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.gradient)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // 重新生成
            Button {
                qrCodeImage = nil
            } label: {
                Text("重新生成")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
    }
    
    // MARK: - 生成按钮
    private var generateButton: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await generateQRCode()
                }
            } label: {
                Label("生成招商二维码", systemImage: "qrcode")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.gradient)
                    .cornerRadius(12)
            }
            .disabled(isTrial && selectedPlanId == nil)
            
            if isTrial && selectedPlanId == nil {
                Text("请先选择试用套餐")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 加载套餐列表
    private func loadPlans() async {
        isLoadingPlans = true
        do {
            plans = try await APIClient.shared.get(.productPlans)
            if let first = plans.first {
                selectedPlanId = first.id
            }
        } catch {
            print("❌ 加载套餐失败: \(error)")
        }
        isLoadingPlans = false
    }
    
    // MARK: - 生成二维码
    private func generateQRCode() async {
        isGenerating = true
        
        print("🚀 开始生成二维码...")
        print("   试用模式: \(isTrial)")
        print("   试用天数: \(trialDays)")
        print("   套餐ID: \(selectedPlanId ?? "无")")
        
        do {
            let endpoint = APIEndpoint.createQRCode(
                productPlanId: isTrial ? selectedPlanId : nil,
                purpose: "register_agent",
                isTrial: isTrial,
                trialDays: isTrial ? trialDays : 0
            )
            
            let response: QRCodeResponse = try await APIClient.shared.post(endpoint)
            
            print("✅ 后端返回成功:")
            print("   qrcodeId: \(response.qrcodeId)")
            print("   url: \(response.url)")
            
            shareURL = response.url
            qrCodeImage = createQRCodeImage(from: shareURL)
            
        } catch {
            print("❌ 请求失败: \(error)")
            // 临时使用假数据
            shareURL = "esale://register?code=\(UUID().uuidString)"
            qrCodeImage = createQRCodeImage(from: shareURL)
        }
        
        isGenerating = false
    }
    
    // MARK: - 创建二维码图片
    private func createQRCodeImage(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - 分享图片
    private func shareImage(_ image: UIImage) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = window
            popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityVC, animated: true)
    }
}

struct QRCodeResponse: Codable {
    let qrcodeId: String
    let agentId: String
    let url: String
    let isTrial: Bool?
    let trialDays: Int?
}
