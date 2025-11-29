//
//  AppNotification.swift
//  ESale
//
//  Created by wenwu on 11/28/25.
//

import Foundation

extension Notification.Name {
    /// 采购审批数据变化（新请求、审批通过、拒绝等）
    static let purchaseDataChanged = Notification.Name("purchaseDataChanged")
    
    /// 终端用户数据变化（激活、停用等）
    static let endUserDataChanged = Notification.Name("endUserDataChanged")
    
    /// 代理数据变化（审批、新增等）
    static let agentDataChanged = Notification.Name("agentDataChanged")
}
