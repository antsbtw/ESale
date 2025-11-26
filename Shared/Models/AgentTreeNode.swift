//
//  AgentTreeNode.swift
//  ESale
//
//  Created by wenwu on 11/25/25.
//


import Foundation

// 树形节点
class AgentTreeNode: Identifiable, ObservableObject {
    let id: String
    let agent: AgentSummary
    @Published var children: [AgentTreeNode]
    @Published var isExpanded: Bool = false
    
    var hasChildren: Bool {
        !children.isEmpty
    }
    
    // ✅ 添加：计算整个子树的节点总数
    var totalDescendants: Int {
        var count = children.count
        for child in children {
            count += child.totalDescendants
        }
        return count
    }
    
    init(agent: AgentSummary, children: [AgentTreeNode] = []) {
        self.id = agent.id
        self.agent = agent
        self.children = children
    }
    
    // 计算树的深度（用于缩进）
    func depth(in allNodes: [String: AgentTreeNode]) -> Int {
        guard let parentId = agent.parentId,
              let parent = allNodes[parentId] else {
            return 0
        }
        return 1 + parent.depth(in: allNodes)
    }
}

// 构建树形结构的辅助方法
extension Array where Element == AgentSummary {
    func buildTree(rootParentId: String) -> [AgentTreeNode] {
        // 创建所有节点的映射
        var nodeMap: [String: AgentTreeNode] = [:]
        for agent in self {
            nodeMap[agent.id] = AgentTreeNode(agent: agent)
        }
        
        // 构建父子关系
        var rootNodes: [AgentTreeNode] = []
        
        for agent in self {
            guard let node = nodeMap[agent.id] else { continue }
            
            if let parentId = agent.parentId {
                if parentId == rootParentId {
                    // ✅ 直接下级，作为根节点
                    rootNodes.append(node)
                } else if let parent = nodeMap[parentId] {
                    // 有父节点在列表中，添加到父节点的children
                    parent.children.append(node)
                }
            }
        }
        
        // 对每个节点的children排序（按创建时间降序）
        for node in nodeMap.values {
            node.children.sort { $0.agent.createdAt > $1.agent.createdAt }
        }
        
        // 对根节点排序
        rootNodes.sort { $0.agent.createdAt > $1.agent.createdAt }
        
        return rootNodes
    }
}
