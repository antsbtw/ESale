//
//  MainTabView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 首页
            DashboardView()
                .tabItem {
                    Label("首页", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tab 2: 团队
            TeamView()
                .tabItem {
                    Label("团队", systemImage: "person.3.fill")
                }
                .tag(1)
            
            // Tab 3: 授权
            AuthorizationView()
                .tabItem {
                    Label("授权", systemImage: "key.fill")
                }
                .tag(2)
            
            // Tab 4: 数据
            AnalyticsView()
                .tabItem {
                    Label("数据", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            // Tab 5: 我的
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthService.shared)
}
