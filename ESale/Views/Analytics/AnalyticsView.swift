//
//  AnalyticsView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("数据分析")
                        .font(.largeTitle.bold())
                    
                    Text("即将推出")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.indigo.gradient)
                        .padding(.top, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("数据")
        }
    }
}

#Preview {
    AnalyticsView()
}