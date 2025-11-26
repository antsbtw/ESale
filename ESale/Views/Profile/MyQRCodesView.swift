//
//  MyQRCodesView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct MyQRCodesView: View {
    @StateObject private var viewModel = MyQRCodesViewModel()
    @State private var showingGenerator = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if viewModel.isLoading && viewModel.qrCodes.isEmpty {
                    ProgressView()
                        .padding(.top, 100)
                } else if viewModel.qrCodes.isEmpty {
                    emptyView
                } else {
                    ForEach(viewModel.qrCodes) { qrCode in
                        QRCodeCard(qrCode: qrCode) {
                            await viewModel.deleteQRCode(qrCode.id)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("我的二维码")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingGenerator = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .task {
            await viewModel.loadQRCodes()
        }
        .sheet(isPresented: $showingGenerator) {
            QRCodeGeneratorView(isPresented: $showingGenerator)
                .onDisappear {
                    Task {
                        await viewModel.loadQRCodes()
                    }
                }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "qrcode")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("暂无招商二维码")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("生成二维码后可以分享给其他人注册")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            
            Button {
                showingGenerator = true
            } label: {
                Text("生成二维码")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.gradient)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
        .padding()
    }
}

// MARK: - QR Code Card
struct QRCodeCard: View {
    let qrCode: QRCodeInfo
    let onDelete: () async -> Void
    @State private var qrCodeImage: UIImage?
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("招商二维码")
                        .font(.headline)
                    
                    Text("创建于 \(formatDate(qrCode.createdAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(qrCode.registerCount)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.blue)
                    Text("注册人数")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                // ✅ 删除按钮
                Button {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .padding(8)
                }
            }
            
            // 二维码图片
            if let image = qrCodeImage {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            
            // 分享按钮
            ShareLink(
                item: buildURL(),
                message: Text("扫码加入我的团队")
            ) {
                Label("分享二维码", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.gradient)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8)
        .onAppear {
            qrCodeImage = createQRCodeImage(from: buildURL())
        }
        .alert("删除二维码", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                Task {
                    isDeleting = true
                    await onDelete()
                }
            }
        } message: {
            Text("确认要删除这个二维码吗？删除后无法恢复。")
        }
    }
    
    private func buildURL() -> String {
        return "esale://register?code=\(qrCode.id)"
    }
    
    private func formatDate(_ dateString: String) -> String {
        // 简单格式化，你可以根据需要调整
        return dateString.prefix(10).replacingOccurrences(of: "-", with: "/")
    }
    
    private func createQRCodeImage(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Models
struct QRCodeInfo: Identifiable, Codable {
    let id: String
    let agentId: String      // ✅ 用 camelCase，自动转换会处理
    let purpose: String
    let createdAt: String
    let expiresAt: String
    let registerCount: Int
    
    // ❌ 删除 init(from decoder:)
    // ❌ 删除 CodingKeys
}

// MARK: - ViewModel
@MainActor
class MyQRCodesViewModel: ObservableObject {
    @Published var qrCodes: [QRCodeInfo] = []
    @Published var isLoading = false
    
    func loadQRCodes() async {
        isLoading = true
        
        do {
            qrCodes = try await APIClient.shared.get(.myQRCodes)
        } catch {
            print("❌ 加载二维码列表失败: \(error)")
        }
        
        isLoading = false
    }
    
    // ✅ 新增删除方法
    func deleteQRCode(_ id: String) async {
        do {
            struct DeleteResponse: Codable {
                let message: String
            }
            
            let _: DeleteResponse = try await APIClient.shared.request(
                .deleteQRCode(id: id),
                responseType: DeleteResponse.self
            )
            
            print("✅ 删除成功")
            
            // 从列表中移除
            qrCodes.removeAll { $0.id == id }
            
        } catch {
            print("❌ 删除失败: \(error)")
        }
    }
    
}

#Preview {
    NavigationStack {
        MyQRCodesView()
    }
}
