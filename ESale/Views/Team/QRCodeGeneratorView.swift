//
//  QRCodeGeneratorView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGeneratorView: View {
    @Binding var isPresented: Bool  // ✅ 改用 Binding
    @State private var qrCodeImage: UIImage?
    @State private var isGenerating: Bool = false
    @State private var shareURL: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                if isGenerating {
                    ProgressView()
                        .scaleEffect(1.5)
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
            .padding(.top, 40)
            .navigationTitle("招商二维码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        isPresented = false
                    }
                }
            }
        }
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
            
            Text("有效期：永久有效")
                .font(.caption)
                .foregroundStyle(.secondary)
            
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
        }
    }
    
    // MARK: - 生成按钮
    private var generateButton: some View {
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
        .padding(.horizontal)
    }
    
    // MARK: - 生成二维码
    private func generateQRCode() async {
        isGenerating = true
        
        print("🚀 开始生成二维码...")
        
        do {
            let endpoint = APIEndpoint.createQRCode(
                productPlanId: nil,
                scene: "register_agent",
                remark: nil
            )
            
            print("📡 准备请求:")
            print("   路径: \(endpoint.path)")
            print("   方法: \(endpoint.method)")
            print("   参数: \(endpoint.body ?? [:])")
            
            let response: QRCodeResponse = try await APIClient.shared.post(endpoint)
            
            print("✅ 后端返回成功:")
            print("   qrcodeId: \(response.qrcodeId)")
            print("   url: \(response.url)")
            
            shareURL = response.url
            qrCodeImage = createQRCodeImage(from: shareURL)
            
        } catch {
            print("❌ 请求失败:")
            print("   错误类型: \(type(of: error))")
            print("   错误详情: \(error)")
            print("   错误描述: \(error.localizedDescription)")
            
            // 临时使用假数据
            shareURL = "https://esale.app/join/\(UUID().uuidString)"
            qrCodeImage = createQRCodeImage(from: shareURL)
        }
        
        isGenerating = false
        print("🏁 生成流程结束\n")
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
        
        // iPad 支持
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
}
