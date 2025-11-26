//
//  NotificationSettingsView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//


import SwiftUI

struct NotificationSettingsView: View {
    @State private var enablePush = true
    @State private var enableEmail = false
    
    var body: some View {
        Form {
            Section("推送通知") {
                Toggle("启用推送通知", isOn: $enablePush)
                Toggle("邮件通知", isOn: $enableEmail)
            }
        }
        .navigationTitle("通知设置")
    }
}