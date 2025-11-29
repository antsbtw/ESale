//
//  PrivacyPolicyView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 标题
                VStack(alignment: .leading, spacing: 8) {
                    Text("隐私政策")
                        .font(.largeTitle.bold())
                    
                    Text("生效日期：2025年12月1日")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 引言
                PolicySection(title: "引言") {
                    Text("Situs Technologies LLC（以下简称“我们”）非常重视用户的隐私保护。本隐私政策旨在向您说明我们如何收集、使用、存储和保护您在使用 eSale-M 应用程序（以下简称“本应用”）时提供的个人信息。")
                    
                    Text("请您在使用本应用之前，仔细阅读并理解本隐私政策的全部内容。一旦您开始使用本应用，即表示您已阅读并同意本隐私政策的所有条款。")
                }
                
                // 信息收集
                PolicySection(title: "一、我们收集的信息") {
                    Text("为向您提供服务，我们可能会收集以下类型的信息：")
                    
                    PolicySubSection(title: "1. 您主动提供的信息") {
                        BulletPoint("账户信息：用户名、密码、手机号码、电子邮箱")
                        BulletPoint("身份信息：代理商等级、所属上级代理")
                        BulletPoint("业务信息：套餐订购记录、配额使用情况")
                    }
                    
                    PolicySubSection(title: "2. 自动收集的信息") {
                        BulletPoint("设备信息：设备型号、操作系统版本、唯一设备标识符")
                        BulletPoint("日志信息：访问时间、操作记录、错误日志")
                        BulletPoint("网络信息：IP 地址、网络运营商信息")
                    }
                }
                
                // 信息使用
                PolicySection(title: "二、信息的使用") {
                    Text("我们收集的信息将用于以下目的：")
                    
                    BulletPoint("提供、维护和改进我们的服务")
                    BulletPoint("处理您的订单和交易")
                    BulletPoint("验证您的身份和管理您的账户")
                    BulletPoint("向您发送服务通知和更新")
                    BulletPoint("检测、预防和解决技术问题及安全问题")
                    BulletPoint("遵守法律法规的要求")
                }
                
                // 信息存储
                PolicySection(title: "三、信息的存储与保护") {
                    Text("我们采取业界标准的安全措施来保护您的个人信息：")
                    
                    BulletPoint("使用 SSL/TLS 加密技术传输敏感数据")
                    BulletPoint("对用户密码进行加密存储")
                    BulletPoint("实施严格的数据访问权限控制")
                    BulletPoint("定期进行安全评估和漏洞扫描")
                    
                    Text("您的个人信息将存储在位于安全数据中心的服务器上。我们会根据业务需要和法律要求确定信息的存储期限。")
                        .padding(.top, 8)
                }
                
                // 信息共享
                PolicySection(title: "四、信息的共享与披露") {
                    Text("我们不会将您的个人信息出售给第三方。在以下情况下，我们可能会共享您的信息：")
                    
                    BulletPoint("经您明确同意")
                    BulletPoint("与我们的关联公司共享，以提供更好的服务")
                    BulletPoint("与授权合作伙伴共享，以完成特定服务")
                    BulletPoint("根据法律法规要求或政府部门的强制性要求")
                    BulletPoint("为保护我们或公众的权利、财产或安全")
                }
                
                // 用户权利
                PolicySection(title: "五、您的权利") {
                    Text("根据适用的法律法规，您对您的个人信息享有以下权利：")
                    
                    BulletPoint("访问权：您有权访问我们持有的关于您的个人信息")
                    BulletPoint("更正权：您有权要求更正不准确或不完整的个人信息")
                    BulletPoint("删除权：在特定情况下，您有权要求删除您的个人信息")
                    BulletPoint("账户注销：您有权随时注销您的账户")
                    
                    Text("如需行使上述权利，请通过本政策末尾的联系方式与我们联系。")
                        .padding(.top, 8)
                }
                
                // 未成年人保护
                PolicySection(title: "六、未成年人保护") {
                    Text("本应用主要面向企业用户和成年个人用户。我们不会故意收集未满 18 周岁未成年人的个人信息。如果您是未成年人，请在监护人的陪同下阅读本政策，并在监护人同意的情况下使用本应用。")
                }
                
                // 政策更新
                PolicySection(title: "七、隐私政策的更新") {
                    Text("我们可能会不时更新本隐私政策。当我们进行重大变更时，我们会在应用内通知您。建议您定期查看本政策以了解最新的隐私保护措施。")
                }
                
                // 联系我们
                PolicySection(title: "八、联系我们") {
                    Text("如果您对本隐私政策有任何疑问、意见或建议，请通过以下方式与我们联系：")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundStyle(.blue)
                            Text("Situs Technologies LLC")
                        }
                        
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundStyle(.blue)
                            Text("service@situstechnologies.com")
                        }
                    }
                    .padding(.top, 8)
                }
                
                // 底部声明
                Text("© 2025 Situs Technologies LLC. 保留所有权利。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 辅助组件

struct PolicySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .font(.body)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct PolicySubSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            
            content
        }
        .padding(.top, 4)
    }
}

struct BulletPoint: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
