//
//  NotificationSettingsView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct NotificationSettingsView: View {
    // 订单相关
    @AppStorage("notification_newOrder") private var newOrderEnabled = true
    @AppStorage("notification_orderStatus") private var orderStatusEnabled = true
    
    // 审批相关
    @AppStorage("notification_agentApproval") private var agentApprovalEnabled = true
    @AppStorage("notification_purchaseApproval") private var purchaseApprovalEnabled = true
    
    // 配额相关
    @AppStorage("notification_quotaLow") private var quotaLowEnabled = true
    @AppStorage("notification_quotaChange") private var quotaChangeEnabled = false
    
    // 系统相关
    @AppStorage("notification_systemAnnouncement") private var systemAnnouncementEnabled = true
    @AppStorage("notification_appUpdate") private var appUpdateEnabled = true
    
    // 总开关
    @AppStorage("notification_masterSwitch") private var masterSwitchEnabled = true
    
    var body: some View {
        Form {
            // 总开关
            Section {
                Toggle(isOn: $masterSwitchEnabled) {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("接收通知")
                                .font(.body)
                            Text("关闭后将不会收到任何通知")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            
            if masterSwitchEnabled {
                // 订单通知
                Section {
                    NotificationToggle(
                        icon: "cart.fill",
                        color: .green,
                        title: "新订单通知",
                        subtitle: "下级代理商购买套餐时通知",
                        isOn: $newOrderEnabled
                    )
                    
                    NotificationToggle(
                        icon: "shippingbox.fill",
                        color: .green,
                        title: "订单状态变更",
                        subtitle: "我的订单状态更新时通知",
                        isOn: $orderStatusEnabled
                    )
                } header: {
                    Text("订单通知")
                }
                
                // 审批通知
                Section {
                    NotificationToggle(
                        icon: "person.badge.plus",
                        color: .orange,
                        title: "代理商审批",
                        subtitle: "新代理商申请加入时通知",
                        isOn: $agentApprovalEnabled
                    )
                    
                    NotificationToggle(
                        icon: "doc.text.magnifyingglass",
                        color: .orange,
                        title: "采购审批",
                        subtitle: "下级提交采购申请时通知",
                        isOn: $purchaseApprovalEnabled
                    )
                } header: {
                    Text("审批通知")
                }
                
                // 配额通知
                Section {
                    NotificationToggle(
                        icon: "exclamationmark.triangle.fill",
                        color: .red,
                        title: "配额不足提醒",
                        subtitle: "配额低于阈值时通知",
                        isOn: $quotaLowEnabled
                    )
                    
                    NotificationToggle(
                        icon: "arrow.up.arrow.down",
                        color: .purple,
                        title: "配额变动通知",
                        subtitle: "配额增加或减少时通知",
                        isOn: $quotaChangeEnabled
                    )
                } header: {
                    Text("配额通知")
                }
                
                // 系统通知
                Section {
                    NotificationToggle(
                        icon: "megaphone.fill",
                        color: .blue,
                        title: "系统公告",
                        subtitle: "平台重要公告和通知",
                        isOn: $systemAnnouncementEnabled
                    )
                    
                    NotificationToggle(
                        icon: "arrow.down.app.fill",
                        color: .blue,
                        title: "版本更新",
                        subtitle: "App 有新版本时通知",
                        isOn: $appUpdateEnabled
                    )
                } header: {
                    Text("系统通知")
                } footer: {
                    Text("通知设置仅保存在本设备，更换设备需重新设置。")
                        .padding(.top, 8)
                }
            }
        }
        .navigationTitle("通知设置")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut, value: masterSwitchEnabled)
    }
}

// MARK: - 通知开关组件
struct NotificationToggle: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
