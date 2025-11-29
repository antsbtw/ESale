//
//  TermsOfServiceView.swift
//  ESale
//
//  Created by wenwu on 11/24/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 标题
                VStack(alignment: .leading, spacing: 8) {
                    Text("用户协议")
                        .font(.largeTitle.bold())
                    
                    Text("生效日期：2025年12月1日")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // 引言
                PolicySection(title: "引言") {
                    Text("欢迎使用 eSale-M！本用户协议（以下简称“本协议”）是您与 Situs Technologies LLC（以下简称“我们”）之间关于使用 eSale-M 应用程序及相关服务的法律协议。")
                    
                    Text("请您在使用本服务之前，仔细阅读并充分理解本协议的全部内容。如果您不同意本协议的任何条款，请勿注册或使用本服务。")
                }
                
                // 服务说明
                PolicySection(title: "一、服务说明") {
                    Text("eSale-M 是一款多级代理销售管理平台，主要提供以下服务：")
                    
                    BulletPoint("代理商管理：支持多级代理商的注册、审批和管理")
                    BulletPoint("配额管理：产品授权配额的分配、转让和追踪")
                    BulletPoint("终端用户管理：终端用户的注册、激活和服务管理")
                    BulletPoint("数据分析：销售数据统计和业绩分析")
                    
                    Text("我们保留随时修改、暂停或终止部分或全部服务的权利，恕不另行通知。")
                        .padding(.top, 8)
                }
                
                // 用户账户
                PolicySection(title: "二、用户账户") {
                    PolicySubSection(title: "1. 账户注册") {
                        Text("您需要注册账户才能使用本服务的完整功能。注册时，您应提供真实、准确、完整的信息，并及时更新。")
                    }
                    
                    PolicySubSection(title: "2. 账户安全") {
                        Text("您应妥善保管账户信息和密码，对账户下的所有活动负责。如发现账户被盗用或其他安全问题，请立即通知我们。")
                    }
                    
                    PolicySubSection(title: "3. 账户类型") {
                        BulletPoint("管理员账户：拥有系统最高权限")
                        BulletPoint("代理商账户：可发展下级代理和终端用户")
                        BulletPoint("终端用户账户：使用授权产品服务")
                    }
                }
                
                // 用户行为规范
                PolicySection(title: "三、用户行为规范") {
                    Text("在使用本服务时，您同意遵守以下规定：")
                    
                    BulletPoint("遵守所有适用的法律法规")
                    BulletPoint("不得利用本服务从事任何违法或不正当活动")
                    BulletPoint("不得干扰或破坏本服务的正常运行")
                    BulletPoint("不得未经授权访问他人账户或数据")
                    BulletPoint("不得传播恶意软件、病毒或有害代码")
                    BulletPoint("不得进行任何可能损害我们或其他用户利益的行为")
                    
                    Text("如您违反上述规定，我们有权暂停或终止您的账户，并保留追究法律责任的权利。")
                        .padding(.top, 8)
                }
                
                // 配额与授权
                PolicySection(title: "四、配额与授权") {
                    PolicySubSection(title: "1. 配额购买") {
                        Text("代理商可通过本平台购买产品配额。购买后，配额将添加到您的账户中，用于激活终端用户服务。")
                    }
                    
                    PolicySubSection(title: "2. 配额使用") {
                        BulletPoint("配额一经使用，不可撤销或退还")
                        BulletPoint("配额可转让给下级代理商")
                        BulletPoint("已分配的配额按约定规则生效")
                    }
                    
                    PolicySubSection(title: "3. 授权激活") {
                        Text("终端用户需经代理商激活后方可使用服务。激活后的授权受相应产品套餐条款约束。")
                    }
                }
                
                // 费用与支付
                PolicySection(title: "五、费用与支付") {
                    BulletPoint("所有费用以订购时显示的价格为准")
                    BulletPoint("支付完成后，请等待上级代理或管理员确认")
                    BulletPoint("因您个人原因导致的交易问题，责任由您自行承担")
                    BulletPoint("我们保留调整价格的权利，调整前会提前通知")
                }
                
                // 知识产权
                PolicySection(title: "六、知识产权") {
                    Text("本应用的所有内容，包括但不限于文字、图片、标识、界面设计、软件代码等，均为 Situs Technologies LLC 或其授权方所有，受知识产权法律保护。")
                    
                    Text("未经我们书面许可，您不得复制、修改、传播、出售或以其他方式使用本应用的任何内容。")
                        .padding(.top, 8)
                }
                
                // 免责声明
                PolicySection(title: "七、免责声明") {
                    BulletPoint("本服务按“现状”提供，我们不对服务的适用性、可靠性作任何明示或暗示的保证")
                    BulletPoint("因不可抗力、网络故障、系统维护等原因导致的服务中断，我们不承担责任")
                    BulletPoint("您通过本服务获得的任何信息，其风险由您自行承担")
                    BulletPoint("对于第三方提供的内容或服务，我们不承担任何责任")
                }
                
                // 责任限制
                PolicySection(title: "八、责任限制") {
                    Text("在法律允许的最大范围内，我们对因使用或无法使用本服务而导致的任何直接、间接、附带、特殊或后果性损害不承担责任，包括但不限于利润损失、数据丢失、业务中断等。")
                }
                
                // 协议变更
                PolicySection(title: "九、协议变更") {
                    Text("我们保留随时修改本协议的权利。修改后的协议将在本应用内公布。如您在协议变更后继续使用本服务，即表示您接受修改后的协议。")
                    
                    Text("建议您定期查看本协议，以了解最新条款。")
                        .padding(.top, 8)
                }
                
                // 终止
                PolicySection(title: "十、服务终止") {
                    Text("在以下情况下，我们可能终止或暂停您对服务的访问：")
                    
                    BulletPoint("您违反本协议的任何条款")
                    BulletPoint("应法律法规或政府部门的要求")
                    BulletPoint("出于安全或技术原因")
                    BulletPoint("您的账户长期不活跃")
                    
                    Text("服务终止后，您账户中的数据可能被删除，我们对此不承担责任。")
                        .padding(.top, 8)
                }
                
                // 争议解决
                PolicySection(title: "十一、争议解决") {
                    Text("因本协议引起的或与本协议有关的任何争议，双方应首先通过友好协商解决。协商不成的，任何一方均可向有管辖权的法院提起诉讼。")
                }
                
                // 联系我们
                PolicySection(title: "十二、联系我们") {
                    Text("如果您对本协议有任何疑问，请通过以下方式与我们联系：")
                    
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
        .navigationTitle("用户协议")
        .navigationBarTitleDisplayMode(.inline)
    }
}

