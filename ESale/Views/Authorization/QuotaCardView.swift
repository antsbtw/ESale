//
//  QuotaCardView.swift
//  ESale
//
//  配额卡片组件
//

import SwiftUI
import Combine

struct QuotaCardView: View {
    let summary: QuotaSummary
    
    var body: some View {
        VStack(spacing: 16) {
            // 总计统计
            HStack(spacing: 20) {
                StatItem(title: "总配额", value: "\(summary.totalQuota)", color: .blue)
                StatItem(title: "已使用", value: "\(summary.totalUsed)", color: .orange)
                StatItem(title: "剩余", value: "\(summary.totalRemaining)", color: .green)
            }
            
            Divider()
            
            // 各产品配额
            VStack(spacing: 12) {
                ForEach(Array(summary.products.keys.sorted()), id: \.self) { productName in
                    if let info = summary.products[productName] {
                        ProductQuotaRow(productName: productName, info: info)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))   // ← 修复
        .cornerRadius(12)
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProductQuotaRow: View {
    let productName: String
    let info: ProductQuotaInfo
    
    private var progress: Double {
        guard info.total > 0 else { return 0 }
        return Double(info.used) / Double(info.total)
    }
    
    private var isLowStock: Bool {
        return info.remaining < info.total / 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(productName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(info.remaining) / \(info.total)")
                    .font(.caption)
                    .foregroundColor(isLowStock ? .red : .secondary)
                
                if isLowStock {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    Rectangle()
                        .fill(Color(.systemGray5))     // ← 修复
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    // 进度
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }
    
    private var progressColor: Color {
        if progress >= 0.9 { return .red }
        else if progress >= 0.7 { return .orange }
        else { return .green }
    }
}

// MARK: - 配额详情页面
struct QuotaDetailView: View {
    @ObservedObject var viewModel: AuthorizationViewModel
    
    // ⛔️ 不要再用 presentationMode（iOS15 已废弃）
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {        // ← NavigationView → NavigationStack（iOS17/18 标准）
            List {
                if let summary = viewModel.quotaSummary {
                    Section {
                        HStack {
                            Text("总配额")
                            Spacer()
                            Text("\(summary.totalQuota)")
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("已使用")
                            Spacer()
                            Text("\(summary.totalUsed)")
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("剩余")
                            Spacer()
                            Text("\(summary.totalRemaining)")
                                .foregroundColor(.green)
                        }
                    } header: {
                        Text("总计")
                    }
                    
                    Section {
                        ForEach(Array(summary.products.keys.sorted()), id: \.self) { productName in
                            if let info = summary.products[productName] {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(productName)
                                        .font(.headline)
                                    
                                    HStack {
                                        Label("\(info.total)", systemImage: "square.stack.3d.up")
                                        Spacer()
                                        Label("\(info.used)", systemImage: "checkmark.circle")
                                        Spacer()
                                        Label("\(info.remaining)", systemImage: "cube.box")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    } header: {
                        Text("产品配额")
                    }
                }
            }
            .navigationTitle("配额详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") {
                        dismiss()      // ← 新写法
                    }
                }
            }
        }
    }
}

#Preview {
    QuotaCardView(
        summary: QuotaSummary(
            totalQuota: 1000,
            totalUsed: 623,
            totalRemaining: 377,
            products: [
                "VPN": ProductQuotaInfo(
                    productId: "1",
                    productCode: "VPN",
                    total: 500,
                    used: 123,
                    remaining: 377
                ),
                "OCR": ProductQuotaInfo(
                    productId: "2",
                    productCode: "OCR",
                    total: 200,
                    used: 40,
                    remaining: 160
                )
            ]
        )
    )
}
