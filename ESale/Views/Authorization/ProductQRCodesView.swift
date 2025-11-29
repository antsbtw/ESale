//
//  ProductQRCodesView.swift
//  ESale
//
//  产品注册二维码管理（终端用户扫码注册）
//

import SwiftUI

struct ProductQRCodesView: View {
    @StateObject private var viewModel = ProductQRCodesViewModel()
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
                        ProductQRCodeCard(qrCode: qrCode) {
                            await viewModel.deleteQRCode(qrCode.id)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("用户注册码")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.loadQRCodes()
        }
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
        .onAppear {
            Task {
                await viewModel.loadQRCodes()
            }
        }
        .sheet(isPresented: $showingGenerator) {
            ProductQRCodeGeneratorView(isPresented: $showingGenerator)
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
            
            Text("暂无用户注册码")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("生成二维码后分享给终端用户扫码注册")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            
            Button {
                showingGenerator = true
            } label: {
                Text("生成注册码")
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

// MARK: - Product QR Code Card
struct ProductQRCodeCard: View {
    let qrCode: ProductQRCodeInfo
    let onDelete: () async -> Void
    @State private var qrCodeImage: UIImage?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(qrCode.planName ?? "产品注册码")
                        .font(.headline)
                    
                    if let productName = qrCode.productName {
                        Text(productName)
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                    }
                    
                    Text("创建于 \(formatDate(qrCode.createdAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(qrCode.registerCount)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.green)
                    Text("已注册")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
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
                message: Text("扫码注册使用 \(qrCode.productName ?? "产品")")
            ) {
                Label("分享注册码", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.gradient)
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
        .alert("删除注册码", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                Task {
                    await onDelete()
                }
            }
        } message: {
            Text("确认要删除这个注册码吗？删除后无法恢复。")
        }
    }
    
    private func buildURL() -> String {
        return "esale://register?code=\(qrCode.id)&type=enduser"
    }
    
    private func formatDate(_ dateString: String) -> String {
        return String(dateString.prefix(10)).replacingOccurrences(of: "-", with: "/")
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
struct ProductQRCodeInfo: Identifiable, Codable {
    let id: String
    let agentId: String
    let purpose: String
    let productPlanId: String?
    let planName: String?
    let productName: String?
    let createdAt: String
    let expiresAt: String
    let registerCount: Int
}

// MARK: - ViewModel
@MainActor
class ProductQRCodesViewModel: ObservableObject {
    @Published var qrCodes: [ProductQRCodeInfo] = []
    @Published var isLoading = false
    
    func loadQRCodes() async {
        isLoading = true
        
        do {
            // 只获取 purpose = "enduser" 的二维码
            qrCodes = try await APIClient.shared.get(.productQRCodes)
        } catch {
            print("❌ 加载产品注册码失败: \(error)")
        }
        
        isLoading = false
    }
    
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
            qrCodes.removeAll { $0.id == id }
        } catch {
            print("❌ 删除失败: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ProductQRCodesView()
    }
}
