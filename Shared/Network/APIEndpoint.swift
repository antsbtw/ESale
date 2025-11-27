//
//  APIEndpoint.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import Foundation

enum APIEndpoint {
    // Auth
    case login(username: String, password: String)
    case me
    
    // Agents
    case agents(page: Int, pageSize: Int, status: Int?)
    case createAgent(username: String, password: String, mobile: String, email: String, agentLevel: Int)
    case agentDetail(id: String)
    case updateAgentStatus(agentId: String, status: Int)
    case changePassword(oldPassword: String, newPassword: String)
    
    // 审批相关
    case pendingAgents(page: Int, pageSize: Int)
    case approveAgent(agentId: String, approved: Bool, remark: String?)
    case registerViaQRCode(code: String, username: String, password: String, mobile: String, email: String?)
    
    // 二维码
    case createQRCode(productPlanId: String?, scene: String, remark: String?)
    case myQRCodes
    case qrCodeInfo(code: String)
    case deleteQRCode(id: String)
    
    // Dashboard
    case dashboardStats
    
    // ⭐⭐⭐ 授权管理（新增）
    case quotaSummary
    case quotaList
    case quotaCheck(productId: String)
    case packageList
    case packageDetail(id: String)
    case pendingPayments(status: String)
    case confirmPayment(sessionId: String, remark: String?)
    case rejectPayment(sessionId: String, remark: String?)
    
    // ⭐⭐⭐ 产品管理（管理员）
    case productList
    case productDetail(id: String)
    case createProduct(name: String, code: String, description: String, iconUrl: String?)
    case updateProduct(id: String, name: String, code: String, description: String, iconUrl: String?)
    case updateProductStatus(id: String, isActive: Bool)
    case deleteProduct(id: String)
    
    // ⭐⭐⭐ 套餐管理（管理员）
    case packageListAll
    case createPackage(name: String, code: String, price: Double, durationDays: Int, isActive: Bool, productQuotas: [[String: Any]])
    case updatePackage(id: String, name: String, code: String, price: Double, durationDays: Int, isActive: Bool, productQuotas: [[String: Any]])
    case updatePackageStatus(id: String, isActive: Bool)
    case deletePackage(id: String)
    // ⭐⭐⭐ 采购（创建支付会话）
    case createPaymentSession(packageId: String, amount: Double, sellerId: String?)
    // ⭐⭐⭐ 管理员采购审批
    case adminPendingPayments(status: String)
    case adminConfirmPayment(sessionId: String, remark: String?)
    // ⭐⭐⭐ 代理商批发给下级
    case agentPurchasePending(status: String)
    case agentPurchaseConfirm(sessionId: String, remark: String?)
    case agentPurchaseReject(sessionId: String, remark: String?)
    // ⭐⭐⭐ 查询上级可售配额
    case parentQuotas
    case createPaymentSessionFromParent(sellerId: String, productId: String, quantity: Int, amount: Double)
    case myPackages  // 我创建的套餐（套餐管理用）
    case pendingEndUsers  // 待激活终端用户
    case activateEndUser(userId: String, approved: Bool, remark: String?)
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .me:
            return "/agent/me"
        case .agents:
            return "/agent/list"
        case .createAgent:
            return "/agent/create"
        case .agentDetail(let id):
            return "/agent/detail/\(id)"
        case .updateAgentStatus:
            return "/agent/status"
        case .pendingAgents:
            return "/agent/pending"
        case .approveAgent:
            return "/agent/approve"
        case .createQRCode:
            return "/agent/qrcode/create"
        case .myQRCodes:
            return "/agent/qrcode/list"  // ✅ 改成这个
        case .deleteQRCode(let id):
            return "/agent/qrcode/\(id)"
        case .qrCodeInfo(let code):
            return "/agent/qrcode/info?code=\(code)"
        case .dashboardStats:
            return "/agent/dashboard/stats"
        case .changePassword:
            return "/agent/change-password"
        case .registerViaQRCode:
            return "/auth/register-via-qrcode"
            // ⭐⭐⭐ 授权管理（新增）
        case .quotaSummary:
            return "/agent/quota/summary"
        case .quotaList:
            return "/agent/quota/list"
        case .quotaCheck:
            return "/agent/quota/check"
        case .packageList:
            return "/agent/package/list"
        case .packageDetail(let id):
            return "/agent/package/detail?id=\(id)"
        case .pendingPayments:
            return "/payment/session/list"
        case .confirmPayment:
            return "/payment/session/confirm"
        case .rejectPayment:
            return "/payment/session/reject"
            // ⭐⭐⭐ 产品管理（管理员）
        case .productList:
            return "/product/list"
        case .productDetail(let id):
            return "/product/detail?id=\(id)"
        case .createProduct:
            return "/product/create"
        case .updateProduct:
            return "/product/update"
        case .updateProductStatus:
            return "/product/status"
        case .deleteProduct(let id):
            return "/product/\(id)"
            // ⭐⭐⭐ 套餐管理（管理员）
        case .packageListAll:
            return "/agent/package/list/all"
        case .createPackage:
            return "/agent/package/create"
        case .updatePackage:
            return "/agent/package/update"
        case .updatePackageStatus:
            return "/agent/package/status"
        case .deletePackage(let id):
            return "/agent/package/\(id)"
        case .createPaymentSession:
            return "/payment/session/create"
        case .adminPendingPayments:
            return "/admin/payment/pending"
        case .adminConfirmPayment:
            return "/admin/payment/confirm"
        case .agentPurchasePending:
            return "/payment/purchase/pending"
        case .agentPurchaseConfirm:
            return "/payment/purchase/confirm"
        case .agentPurchaseReject:
            return "/payment/purchase/reject"
        case .parentQuotas:
            return "/agent/parent/quotas"
        case .createPaymentSessionFromParent:
            return "/payment/session/create"
        case .myPackages:
            return "/agent/package/mine"
        case .pendingEndUsers:
            return "/agent/enduser/pending"
        case .activateEndUser:
            return "/agent/approve"  // 复用审批接口
        }
    }
    
    var method: String {
        switch self {
        case .login, .createAgent, .createQRCode, .approveAgent, .changePassword, .registerViaQRCode,
                .confirmPayment, .rejectPayment, .createProduct, .createPackage, .createPaymentSession,
                .adminConfirmPayment, .agentPurchaseConfirm, .agentPurchaseReject, .createPaymentSessionFromParent:
            return "POST"
        case .updateAgentStatus, .updateProduct, .updateProductStatus, .updatePackage, .updatePackageStatus:  // ✅ 添加 .updatePackage, .updatePackageStatus
            return "PUT"
        case .deleteQRCode, .deleteProduct, .deletePackage:  // ✅ 添加 .deletePackage
            return "DELETE"
        default:
            return "GET"
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .login(let username, let password):
            return ["username": username, "password": password]
        case .createAgent(let username, let password, let mobile, let email, let agentLevel):
            return [
                "username": username,
                "password": password,
                "mobile": mobile,
                "email": email,
                "agentLevel": agentLevel
            ]
        case .updateAgentStatus(let agentId, let status):
            return ["agentId": agentId, "status": status]
        case .approveAgent(let agentId, let approved, let remark):
            var params: [String: Any] = ["agentId": agentId, "approved": approved]
            if let remark = remark { params["remark"] = remark }
            return params
        case .createQRCode(let productPlanId, let scene, let remark):
            var params: [String: Any] = ["scene": scene]
            if let productPlanId = productPlanId { params["productPlanId"] = productPlanId }
            if let remark = remark { params["remark"] = remark }
            return params
        case .changePassword(let oldPassword, let newPassword):
            return ["oldPassword": oldPassword, "newPassword": newPassword]
        case .registerViaQRCode(let code, let username, let password, let mobile, let email):
            var params: [String: Any] = [
                "code": code,
                "username": username,
                "password": password,
                "role": "agent"
            ]
            if !mobile.isEmpty {
                params["mobile"] = mobile
            }
            if let email = email, !email.isEmpty {
                params["email"] = email
            }
            return params
            // ⭐⭐⭐ 授权管理（新增）
        case .confirmPayment(let sessionId, let remark):
            var params: [String: Any] = ["sessionId": sessionId]
            if let remark = remark {
                params["remark"] = remark
            }
            return params
            
        case .rejectPayment(let sessionId, let remark):
            var params: [String: Any] = ["sessionId": sessionId]
            if let remark = remark {
                params["remark"] = remark
            }
            return params
            // ⭐⭐⭐ 产品管理（管理员）
        case .createProduct(let name, let code, let description, let iconUrl):
            var params: [String: Any] = [
                "name": name,
                "code": code,
                "description": description
            ]
            if let iconUrl = iconUrl {
                params["icon_url"] = iconUrl
            }
            return params
            
        case .updateProduct(let id, let name, let code, let description, let iconUrl):
            var params: [String: Any] = [
                "id": id,
                "name": name,
                "code": code,
                "description": description
            ]
            if let iconUrl = iconUrl {
                params["icon_url"] = iconUrl
            }
            return params
            
        case .updateProductStatus(let id, let isActive):
            return ["id": id, "is_active": isActive]
            // ⭐⭐⭐ 套餐管理（管理员）
        case .createPackage(let name, let code, let price, let durationDays, let isActive, let productQuotas):
            return [
                "name": name,
                "code": code,
                "price": price,
                "durationDays": durationDays,
                "isActive": isActive,
                "productQuotas": productQuotas
            ]
            
        case .updatePackage(let id, let name, let code, let price, let durationDays, let isActive, let productQuotas):
            return [
                "id": id,
                "name": name,
                "code": code,
                "price": price,
                "durationDays": durationDays,
                "isActive": isActive,
                "productQuotas": productQuotas
            ]
            
        case .updatePackageStatus(let id, let isActive):
            return ["id": id, "isActive": isActive]
        case .createPaymentSession(let packageId, let amount, let sellerId):
            var params: [String: Any] = [
                "packageId": packageId,
                "amount": amount
            ]
            if let sellerId = sellerId {
                params["sellerId"] = sellerId
            }
            return params
        case .adminConfirmPayment(let sessionId, let remark):
            var params: [String: Any] = ["sessionId": sessionId]
            if let remark = remark {
                params["remark"] = remark
            }
            return params
        case .agentPurchaseConfirm(let sessionId, let remark):
            var params: [String: Any] = ["sessionId": sessionId]
            if let remark = remark {
                params["remark"] = remark
            }
            return params
            
        case .agentPurchaseReject(let sessionId, let remark):
            var params: [String: Any] = ["sessionId": sessionId]
            if let remark = remark {
                params["remark"] = remark
            }
            return params
        case .createPaymentSessionFromParent(let sellerId, let productId, let quantity, let amount):
            return [
                "sellerId": sellerId,
                "productId": productId,
                "quantity": quantity,
                "amount": amount,
                "buyerType": "agent"
            ]
        case .activateEndUser(let userId, let approved, let remark):
            var params: [String: Any] = ["agentId": userId, "approved": approved]
            if let remark = remark { params["remark"] = remark }
            return params
        default:
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .agents(let page, let pageSize, let status):
            var items = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)")
            ]
            if let status = status {
                items.append(URLQueryItem(name: "status", value: "\(status)"))
            }
            return items
        case .pendingAgents(let page, let pageSize):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)")
            ]
            
            // ⭐⭐⭐ 授权管理（新增）
        case .quotaCheck(let productId):
            return [URLQueryItem(name: "product_id", value: productId)]
            
        case .pendingPayments(let status):
            return [URLQueryItem(name: "status", value: status)]
        case .adminPendingPayments(let status):
            return [URLQueryItem(name: "status", value: status)]
        case .agentPurchasePending(let status):
            return [URLQueryItem(name: "status", value: status)]
        case .createPaymentSessionFromParent:
            return nil
        default:
            return nil
        }
    }
}
